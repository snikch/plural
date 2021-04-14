use Mix.Config

config :piazza_core,
  shutdown_delay: 14_000

config :api, ApiWeb.Endpoint,
  http: [port: 4000, compress: true],
  cache_static_manifest: "priv/static/cache_manifest.json",
  server: true

config :rtc, RtcWeb.Endpoint,
  http: [port: 4000, compress: true],
  cache_static_manifest: "priv/static/cache_manifest.json",
  server: true

config :email, EmailWeb.Endpoint,
  url: [port: 4001],
  cache_static_manifest: "priv/static/cache_manifest.json",
  server: false

config :logger, level: :info

config :goth, json: {:system, "GCP_CREDENTIALS"}

config :core, :consumers, [
  Core.PubSub.Consumers.Fanout,
  Core.PubSub.Consumers.Upgrade,
  Core.PubSub.Consumers.Rtc,
  Core.PubSub.Consumers.Notification,
  Core.PubSub.Consumers.IntegrationWebhook,
  Core.PubSub.Consumers.Audits
]

config :email, :consumers, [
  Email.PubSub.Consumer
]

config :core, Core.Email.Mailer,
  adapter: Bamboo.SendGridAdapter,
  api_key: {:system, "SENGRID_API_KEY"}

config :worker, docker_env: [
  # {"DOCKER_HOST", "tcp://localhost:2376"},
  # {"DOCKER_CERT_PATH", "/certs/client"},
  # {"DOCKER_TLS_VERIFY", "1"},
]

config :ex_aws,
  region: {:system, "AWS_REGION"},
  secret_access_key: [{:system, "AWS_ACCESS_KEY_ID"}, {:awscli, "profile_name", 30}],
  access_key_id: [{:system, "AWS_SECRET_ACCESS_KEY"}, {:awscli, "profile_name", 30}],
  awscli_auth_adapter: ExAws.STS.AuthCache.AssumeRoleWebIdentityAdapter

config :cron, run: true
