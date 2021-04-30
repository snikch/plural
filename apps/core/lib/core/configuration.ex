defmodule Core.Configuration do
  defstruct [:stripe_connect_id, :stripe_publishable_key, :registry]

  def new() do
    %__MODULE__{
      stripe_connect_id: Core.conf(:stripe_connect_id),
      stripe_publishable_key: Core.conf(:stripe_publishable_key),
      registry: Core.conf(:registry)
    }
  end
end