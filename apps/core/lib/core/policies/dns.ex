defmodule Core.Policies.Dns do
  use Piazza.Policy
  alias Core.Services.Rbac
  alias Core.Schema.{User, DnsDomain, DnsRecord}

  def can?(%User{id: uid}, %DnsDomain{creator_id: uid}, :edit),
    do: :pass
  def can?(_, %DnsDomain{}, :edit), do: {:error, :forbidden}

  def can?(%User{account_id: aid}, %DnsDomain{account_id: aid}, _),
    do: :pass

  def can?(%User{id: id}, %DnsRecord{creator_id: id}, :delete), do: :pass
  def can?(%User{account_id: id} = user, %DnsRecord{} = record, action) when action != :delete do
    case Core.Repo.preload(record, [domain: [access_policy: :bindings]]) do
      %{domain: %DnsDomain{account_id: ^id, access_policy: nil}} -> :pass
      %{domain: %DnsDomain{account_id: ^id, access_policy: policy}} ->
        Rbac.evaluate_policy(user, policy)
      _ -> {:error, :forbidden}
    end
  end

  def can?(user, %Ecto.Changeset{} = cs, action),
    do: can?(user, apply_changes(cs), action)
  def can?(_, _, _), do: {:error, :forbidden}
end