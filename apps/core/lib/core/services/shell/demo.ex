defmodule Core.Services.Shell.Demo do
  use Core.Services.Base
  alias Core.Schema.{User, DemoProject}
  alias Core.Services.Locks
  alias GoogleApi.CloudResourceManager.V3.Api.{Projects, Operations}
  alias GoogleApi.CloudResourceManager.V3.Model.{Project, Operation, SetIamPolicyRequest}
  alias GoogleApi.CloudResourceManager.V3.Connection, as: ProjectsConnection
  alias GoogleApi.IAM.V1.Connection, as: IAMConnection
  alias GoogleApi.IAM.V1.Api.Projects, as: IAMProjects
  alias GoogleApi.IAM.V1.Model.{CreateServiceAccountRequest, Policy, Binding}

  @type error :: {:error, term}

  @lock "demo-projects"

  @spec get_demo_project(binary) :: DemoProject.t | nil
  def get_demo_project(id), do: Core.Repo.get(DemoProject, id)

  @doc """
  Returns at most `limit` demo projects for deletion.  This operation should be atomic, and will mark each project with
  a heartbeat ts to track status in the deletion pipeline.
  """
  @spec poll(integer) :: {:ok, [DemoProject.t]} | error
  def poll(limit) do
    owner = Ecto.UUID.generate()

    start_transaction()
    |> add_operation(:lock, fn _ -> Locks.acquire(@lock, owner) end)
    |> add_operation(:fetch, fn _ ->
      DemoProject.expired()
      |> DemoProject.dequeue(limit)
      |> Core.Repo.all()
      |> ok()
    end)
    |> add_operation(:mark, fn %{fetch: projects} ->
      projects
      |> Enum.map(& &1.id)
      |> DemoProject.for_ids()
      |> DemoProject.selected()
      |> Core.Repo.update_all(set: [heartbeat: Timex.now()])
      |> elem(1)
      |> ok()
    end)
    |> add_operation(:release, fn _ -> Locks.release(@lock) end)
    |> execute(extract: :mark)
  end

  @doc """
  Creates a new demo project.  GCP project creation is a long-running operation, so you'll
  need to poll the project afterwards.
  """
  @spec create_demo_project(User.t) :: {:ok, DemoProject.t} | error
  def create_demo_project(%User{id: user_id} = user) do
    projs = projects_conn()
    start_transaction()
    |> add_operation(:db, fn _ ->
      %DemoProject{user_id: user_id}
      |> DemoProject.changeset(%{project_id: project_id(user)})
      |> Core.Repo.insert()
    end)
    |> add_operation(:project, fn %{db: %{project_id: proj_id}} ->
      Projects.cloudresourcemanager_projects_create(projs, body: %Project{
        projectId: proj_id,
        displayName: proj_id,
        parent: "organizations/#{org_id()}"
      })
    end)
    |> add_operation(:final, fn %{db: demo, project: %{name: "operations/" <> op_id}} ->
      DemoProject.changeset(demo, %{ready: false, operation_id: op_id})
      |> Core.Repo.update()
    end)
    |> execute(extract: :final)
  end

  @doc """
  Deletes the demo project and its associated gcp project
  """
  @spec delete_demo_project(DemoProject.t) :: {:ok, DemoProject.t} | error
  def delete_demo_project(%DemoProject{project_id: proj_id} = proj) do
    start_transaction()
    |> add_operation(:proj, fn _ ->
      projects_conn()
      |> Projects.cloudresourcemanager_projects_delete(proj_id)
    end)
    |> add_operation(:db, fn _ -> Core.Repo.delete(proj) end)
    |> execute(extract: :db)
  end

  @doc """
  Will check the create project operation for completion, and if completed, will provision a service account for
  that project to be used in the cloud shell
  """
  @spec poll_demo_project(DemoProject.t) :: {:ok, DemoProject.t} | error
  def poll_demo_project(%DemoProject{ready: true} = proj), do: {:ok, proj}

  def poll_demo_project(%DemoProject{operation_id: op_id} = proj) do
    projects_conn()
    |> Operations.cloudresourcemanager_operations_get(op_id)
    |> case do
      {:ok, %Operation{done: true}} -> provision(proj)
      _ -> {:ok, proj}
    end
  end

  def poll_demo_project(id) when is_binary(id) do
    get_demo_project(id)
    |> poll_demo_project()
  end

  defp provision(%DemoProject{project_id: proj_id} = demo) do
    projs = projects_conn()
    iams  = iam_conn()

    start_transaction()
    |> add_operation(:service_account, fn _ ->
      IAMProjects.iam_projects_service_accounts_create(iams, proj_id, body: %CreateServiceAccountRequest{accountId: "plural"})
    end)
    |> add_operation(:policy, fn _ ->
      Projects.cloudresourcemanager_projects_get_iam_policy(projs, proj_id)
    end)
    |> add_operation(:iam, fn %{service_account: %{email: email}, policy: %{bindings: bindings}} ->
      Projects.cloudresourcemanager_projects_set_iam_policy(projs, proj_id, body: %SetIamPolicyRequest{
        policy: %Policy{
          bindings: add_binding(bindings, email, "roles/owner") |> add_binding(email, "roles/storage.admin")
        }
      })
    end)
    |> add_operation(:creds, fn %{service_account: %{uniqueId: id}} ->
      IAMProjects.iam_projects_service_accounts_keys_create(iams, proj_id, id)
    end)
    |> add_operation(:final, fn %{creds: creds} ->
      DemoProject.changeset(demo, %{ready: true, credentials: Poison.encode!(creds)})
      |> Core.Repo.update()
    end)
    |> execute(extract: :final)
  end

  defp add_binding(bindings, email, role) do
    case Enum.split_with(bindings, & &1.role == role) do
      {[%Binding{members: members} = bind], bindings} ->
        [%{bind | members: ["serviceAccount:#{email}" | members]} | bindings]
      {_, bindings} -> [binding(email, role) | bindings]
    end
  end

  defp binding(email, role), do: %Binding{members: ["serviceAccount:#{email}"], role: role}

  defp project_id(%User{id: user_id}), do: "plrl-demo-#{user_id}"

  defp projects_conn(), do: ProjectsConnection.new(oauth_token())

  defp iam_conn(), do: IAMConnection.new(oauth_token())

  defp oauth_token() do
    {:ok, token} = Goth.Token.for_scope("https://www.googleapis.com/auth/cloud-platform")
    token.token
  end

  defp org_id(), do: Core.conf(:gcp_organization)
end