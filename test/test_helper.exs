# :e2e tests spawn real subprocesses (slow); run them with: mix test --include e2e
ExUnit.start(exclude: [:e2e])
