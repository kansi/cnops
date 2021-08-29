use Mix.Config

config :logger, :console,
  format: "$time [$level] $message $metadata\n",
  level: :debug,
  metadata: :all

config :cnops, Cnops.Scheduler,
  debug_logging: false,
  overlap: false,
  state: (System.get_env("CONTROL_MODE") == "MANAGE" && :active) || :inactive,
  jobs: [
    [
      schedule: {:extended, "*/15"},
      run_strategy: Quantum.RunStrategy.Local,
      task: {Cnops.Deploy, :hello_testing, []}
    ],
    [
      schedule: {:extended, "*/15"},
      run_strategy: Quantum.RunStrategy.Local,
      task: {Cnops.Deploy, :hello_production, []}
    ],
    [
      schedule: {:extended, "*/15"},
      run_strategy: Quantum.RunStrategy.Local,
      task: {Cnops.Deploy, :hello_go_testing, []}
    ]
  ]
