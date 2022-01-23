defmodule GraphQl.Schema.Shell do
  use GraphQl.Schema.Base
  alias GraphQl.Resolvers.Shell

  input_object :cloud_shell_attributes do
    field :provider,        :provider
    field :workspace,       non_null(:workspace_attributes)
    field :credentials,     non_null(:shell_credentials_attributes)
    field :scm,             :scm_attributes
  end

  enum :scm_provider do
    value :github
  end

  input_object :scm_attributes do
    field :provider, :scm_provider
    field :token,    non_null(:string)
    field :name,     non_null(:string)
    field :org,      :string
  end

  input_object :workspace_attributes do
    field :cluster,       non_null(:string)
    field :bucket_prefix, non_null(:string)
    field :region,        non_null(:string)
    field :project,       :string
    field :subdomain,     non_null(:string)
  end

  input_object :shell_credentials_attributes do
    field :aws, :aws_shell_credentials_attributes
  end

  input_object :aws_shell_credentials_attributes do
    field :access_key_id,     non_null(:string)
    field :secret_access_key, non_null(:string)
  end

  object :cloud_shell do
    field :id,          non_null(:id)
    field :provider,    non_null(:provider)
    field :git_url,     non_null(:string)
    field :aes_key,     non_null(:string)

    field :alive,       non_null(:boolean), resolve: fn
      shell, _, _ -> Shell.liveness(shell)
    end

    field :status, :shell_status, resolve: fn
      shell, _, _ -> Shell.status(shell)
    end

    timestamps()
  end

  object :shell_status do
    field :ready,            :boolean
    field :initialized,      :boolean
    field :containers_ready, :boolean
    field :pod_scheduled,    :boolean
  end

  object :authorization_url do
    field :provider, non_null(:scm_provider)
    field :url,      non_null(:string)
  end

  object :shell_queries do
    field :shell, :cloud_shell do
      middleware Authenticated
      resolve &Shell.resolve_shell/2
    end

    field :scm_authorization, list_of(:authorization_url) do
      middleware Authenticated
      resolve &Shell.authorize_urls/2
    end

    field :scm_token, :string do
      middleware Authenticated
      arg :provider, non_null(:scm_provider)
      arg :code,     non_null(:string)

      resolve &Shell.get_token/2
    end
  end

  object :shell_mutations do
    field :create_shell, :cloud_shell do
      middleware Authenticated
      arg :attributes, non_null(:cloud_shell_attributes)

      resolve &Shell.create_shell/2
    end

    field :reboot_shell, :cloud_shell do
      middleware Authenticated
      resolve &Shell.reboot/2
    end

    field :delete_shell, :cloud_shell do
      middleware Authenticated
      resolve &Shell.delete_shell/2
    end
  end
end