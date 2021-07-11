use Mix.Config

config :logger, :console,
  format: "$time [$level] $message $metadata\n",
  level: :debug,
  metadata: :all

# config :cnops, Cnops.Scheduler,
#   jobs: [
#     {"*/10 * * * * *", {Cnops.Deploy, :rollout_new_vsn, [:testing]}},
#     {"*/10 * * * * *", {Cnops.Deploy, :rollout_new_vsn, [:production]}}
#   ]
