# Project Layout Summary — derobot.is/backend

```
backend/
├── lib/
│   ├── derobot.ex
│   ├── derobot/
│   │   ├── application.ex
│   │   ├── repo.ex
│   │   ├── accounts.ex
│   │   ├── accounts/user.ex
│   │   └── guardian.ex
│   ├── derobot_web.ex
│   ├── derobot_web/
│   │   ├── endpoint.ex
│   │   ├── router.ex
│   │   ├── telemetry.ex
│   │   ├── controllers/
│   │   │   ├── auth_controller.ex
│   │   │   ├── health_controller.ex
│   │   │   └── error_json.ex
│   │   └── plugs/
│   │       ├── auth_pipeline.ex
│   │       ├── auth_error_handler.ex
│   │       └── cors.ex
│   └── supports/types.ex
├── config/
│   ├── config.exs
│   ├── dev.exs
│   ├── test.exs
│   ├── prod.exs
│   └── runtime.exs
├── priv/repo/
│   ├── migrations/
│   ├── seeds.exs
│   └── seeds/
├── test/
│   ├── test_helper.exs
│   └── support/
├── docs/
├── .tool-versions
├── .formatter.exs
├── .gitignore
├── .dockerignore
├── Dockerfile
├── Dockerfile.dev
├── mix.exs
└── mix.lock
```
