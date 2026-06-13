defmodule CodefreshWeb.Router do
  use CodefreshWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :authenticated do
    plug CodefreshWeb.AuthPipeline
  end

  pipeline :api_token_authenticated do
    plug :accepts, ["json"]
    plug CodefreshWeb.Plugs.ApiTokenAuth
  end

  scope "/", CodefreshWeb do
    pipe_through :api
    get "/health", HealthController, :index
  end

  # OTLP ingest (US-081) — authenticated via CodeFresh API token header.
  scope "/otel/v1", CodefreshWeb do
    pipe_through :api_token_authenticated
    post "/traces", OtelController, :ingest_spans
    post "/logs", OtelController, :ingest_logs
  end

  scope "/api/v1", CodefreshWeb do
    pipe_through :api
    post "/auth/register", AuthController, :register
    post "/auth/login", AuthController, :login
    post "/auth/refresh", AuthController, :refresh
  end

  scope "/api/v1", CodefreshWeb do
    pipe_through [:api, :authenticated]
    get "/auth/me", AuthController, :me

    get "/organizations", OrganizationController, :index
    post "/organizations", OrganizationController, :create
    get "/organizations/:id", OrganizationController, :show

    get "/organizations/:organization_id/invites", InviteController, :index
    post "/organizations/:organization_id/invites", InviteController, :create
    delete "/organizations/:organization_id/invites/:id", InviteController, :revoke

    get "/organizations/:organization_id/api-tokens", ApiTokenController, :index
    post "/organizations/:organization_id/api-tokens", ApiTokenController, :create
    post "/organizations/:organization_id/api-tokens/:id/revoke", ApiTokenController, :revoke
    post "/organizations/:organization_id/api-tokens/:id/rotate", ApiTokenController, :rotate

    # Prompts (Stage 1: US-009, US-010, US-011, US-048, US-050)
    get "/organizations/:organization_id/prompts", PromptController, :index
    post "/organizations/:organization_id/prompts", PromptController, :create
    get "/organizations/:organization_id/prompts/:id", PromptController, :show
    patch "/organizations/:organization_id/prompts/:id", PromptController, :update
    delete "/organizations/:organization_id/prompts/:id", PromptController, :archive
    post "/organizations/:organization_id/prompts/:id/publish", PromptController, :publish

    get "/organizations/:organization_id/prompts/:id/current-version",
        PromptController,
        :current_version

    post "/organizations/:organization_id/prompts/:id/sandbox", PromptController, :sandbox

    # Rubrics (Stage 2a: US-033, US-034)
    get "/organizations/:organization_id/rubrics", RubricController, :index
    post "/organizations/:organization_id/rubrics", RubricController, :create
    get "/organizations/:organization_id/rubrics/:id", RubricController, :show
    patch "/organizations/:organization_id/rubrics/:id", RubricController, :update
    delete "/organizations/:organization_id/rubrics/:id", RubricController, :archive
    post "/organizations/:organization_id/rubrics/:id/publish", RubricController, :publish

    get "/organizations/:organization_id/rubrics/:id/current-version",
        RubricController,
        :current_version

    post "/organizations/:organization_id/rubrics/:id/preview", RubricController, :preview

    # Marketplace (US-119)
    get "/marketplace/rubrics", MarketplaceController, :rubrics_index

    post "/organizations/:organization_id/marketplace/rubrics/:id/import",
         MarketplaceController,
         :import_rubric

    # Personas (Stage 2b: US-035, US-036, US-051, US-053, US-055)
    get "/organizations/:organization_id/personas", PersonaController, :index
    post "/organizations/:organization_id/personas", PersonaController, :create
    get "/organizations/:organization_id/personas/:id", PersonaController, :show
    patch "/organizations/:organization_id/personas/:id", PersonaController, :update
    delete "/organizations/:organization_id/personas/:id", PersonaController, :archive
    post "/organizations/:organization_id/personas/:id/publish", PersonaController, :publish

    get "/organizations/:organization_id/personas/:id/current-version",
        PersonaController,
        :current_version

    # Persona expectations (US-051) — nested under a persona version
    get "/organizations/:organization_id/personas/:id/versions/:version_id/expectations",
        PersonaController,
        :list_expectations

    post "/organizations/:organization_id/personas/:id/versions/:version_id/expectations",
         PersonaController,
         :create_expectation

    # Starter library (US-055)
    get "/persona-library", PersonaController, :starters_index

    post "/organizations/:organization_id/persona-library/:starter_slug/import",
         PersonaController,
         :import_starter

    # Attach persona to run (US-036)
    post "/organizations/:organization_id/runs/:run_id/personas",
         PersonaController,
         :attach_to_run

    # Agents (Stage 4: US-012, US-013, US-014, US-061, US-062, US-063, US-064, US-065)
    get "/organizations/:organization_id/agents", AgentController, :index
    post "/organizations/:organization_id/agents", AgentController, :create
    get "/organizations/:organization_id/agents/:id", AgentController, :show
    patch "/organizations/:organization_id/agents/:id", AgentController, :update
    delete "/organizations/:organization_id/agents/:id", AgentController, :archive
    post "/organizations/:organization_id/agents/:id/publish", AgentController, :publish

    get "/organizations/:organization_id/agents/:id/current-version",
        AgentController,
        :current_version

    get "/organizations/:organization_id/agents/:id/health", AgentController, :health

    # Scripts + Graph (Stage 3: US-001, US-002, US-003, US-004, US-005)
    get "/organizations/:organization_id/scripts", ScriptController, :index
    post "/organizations/:organization_id/scripts", ScriptController, :create
    get "/organizations/:organization_id/scripts/:id", ScriptController, :show
    patch "/organizations/:organization_id/scripts/:id", ScriptController, :update
    delete "/organizations/:organization_id/scripts/:id", ScriptController, :archive

    post "/organizations/:organization_id/scripts/:id/nodes",
         ScriptController,
         :add_node

    patch "/organizations/:organization_id/scripts/:id/nodes/:node_id/prompt",
          ScriptController,
          :attach_prompt

    patch "/organizations/:organization_id/scripts/:id/nodes/:node_id",
          ScriptController,
          :update_node

    get "/organizations/:organization_id/scripts/:id/nodes/:node_id/expectations",
        ScriptController,
        :list_node_expectations

    post "/organizations/:organization_id/scripts/:id/nodes/:node_id/expectations",
         ScriptController,
         :add_expectation

    post "/organizations/:organization_id/scripts/:id/edges",
         ScriptController,
         :add_edge

    # Scripts publish/import/export (US-006, US-007, US-008)
    post "/organizations/:organization_id/scripts/:id/publish", ScriptController, :publish

    get "/organizations/:organization_id/scripts/:id/current-version",
        ScriptController,
        :current_version

    post "/organizations/:organization_id/scripts/import", ScriptController, :import_yaml
    get "/organizations/:organization_id/scripts/:id/export", ScriptController, :export_yaml

    # Stage 3 polish (US-041, US-042, US-043, US-044, US-045, US-046, US-047)
    post "/organizations/:organization_id/scripts/:id/fork", ScriptController, :fork

    get "/organizations/:organization_id/scripts/:id/diff",
        ScriptController,
        :diff_versions

    post "/organizations/:organization_id/scripts/:id/nodes/bulk",
         ScriptController,
         :bulk_nodes

    post "/organizations/:organization_id/scripts/:id/auto-layout",
         ScriptController,
         :auto_layout

    get "/organizations/:organization_id/nodes/:node_id/comments",
        ScriptController,
        :list_node_comments

    post "/organizations/:organization_id/nodes/:node_id/comments",
         ScriptController,
         :add_node_comment

    get "/organizations/:organization_id/scripts/:id/lineage",
        ScriptController,
        :export_lineage

    get "/organizations/:organization_id/scripts/:id/validate",
        ScriptController,
        :validate_draft

    # Runs + Freeball (Stage 5: US-015, US-016, US-017, US-018, US-019, US-020,
    #                   US-021, US-022, US-023, US-024)
    get "/organizations/:organization_id/runs", RunController, :index
    post "/organizations/:organization_id/runs", RunController, :create
    get "/organizations/:organization_id/runs/:id", RunController, :show

    get "/organizations/:organization_id/runs/:id/steps", RunController, :list_steps

    get "/organizations/:organization_id/runs/:id/steps/:step_index",
        RunController,
        :show_step

    get "/organizations/:organization_id/runs/:id/scores", RunController, :list_scores

    post "/organizations/:organization_id/runs/:id/cancel", RunController, :cancel
    post "/organizations/:organization_id/runs/:id/retry", RunController, :retry

    get "/organizations/:organization_id/runs/:id/freeball-nodes",
        RunController,
        :freeball_nodes

    # Results + Dashboards (Stage 6: US-025..US-032, US-077..US-080, US-129, US-130)
    get "/organizations/:organization_id/results/runs", ResultsController, :index_runs
    get "/organizations/:organization_id/results/runs/diff", ResultsController, :diff_runs
    get "/organizations/:organization_id/results/trend", ResultsController, :trend
    get "/organizations/:organization_id/results/cohort", ResultsController, :cohort

    get "/organizations/:organization_id/results/runs/:run_id",
        ResultsController,
        :show_run

    get "/organizations/:organization_id/results/runs/:run_id/steps/:step_index",
        ResultsController,
        :show_step

    get "/organizations/:organization_id/results/runs/:run_id/freeball",
        ResultsController,
        :show_freeball_chain

    get "/organizations/:organization_id/results/runs/:run_id/expectations",
        ResultsController,
        :expectation_breakdown

    get "/organizations/:organization_id/results/runs/:run_id/regressions",
        ResultsController,
        :regressions

    get "/organizations/:organization_id/results/runs/:run_id/export",
        ResultsController,
        :export_run

    get "/organizations/:organization_id/results/dashboards",
        ResultsController,
        :index_dashboards

    post "/organizations/:organization_id/results/dashboards",
         ResultsController,
         :save_dashboard

    get "/organizations/:organization_id/results/dashboards/:id",
        ResultsController,
        :show_dashboard

    delete "/organizations/:organization_id/results/dashboards/:id",
           ResultsController,
           :delete_dashboard

    # OTel query + sampling (Stage 10: US-098, US-099, US-132)
    get "/organizations/:organization_id/runs/:run_id/otel-spans",
        OtelController,
        :spans_by_run

    get "/organizations/:organization_id/otel-spans", OtelController, :spans_by_attr
    post "/organizations/:organization_id/otel/spans", OtelController, :spans_by_attr
    post "/organizations/:organization_id/otel/logs", OtelController, :logs_by_attr

    get "/organizations/:organization_id/otel/sampling-policies",
        OtelController,
        :list_sampling_policies

    get "/organizations/:organization_id/otel-sampling-policies",
        OtelController,
        :list_policies

    put "/organizations/:organization_id/otel-sampling-policies",
        OtelController,
        :upsert_policy

    # Review + Promotion (Stage 8: US-088, US-089, US-090, US-137, US-138, US-139, US-140, US-141)
    get "/organizations/:organization_id/review", ReviewController, :index
    post "/organizations/:organization_id/review/bulk", ReviewController, :bulk
    post "/organizations/:organization_id/review/:id/claim", ReviewController, :claim
    post "/organizations/:organization_id/review/:id/resolve", ReviewController, :resolve
    post "/organizations/:organization_id/review/:id/approve", ReviewController, :resolve
    post "/organizations/:organization_id/review/:id/reject", ReviewController, :resolve
    post "/organizations/:organization_id/review/:id/dismiss", ReviewController, :resolve
    post "/organizations/:organization_id/review/:id/assign", ReviewController, :assign
    post "/organizations/:organization_id/review/:id/promote", ReviewController, :promote

    # Datasets (Stage 9: US-101, US-102, US-103, US-104, US-110, US-125, US-149, US-150)
    get "/organizations/:organization_id/datasets", DatasetController, :index
    post "/organizations/:organization_id/datasets", DatasetController, :create
    get "/organizations/:organization_id/datasets/:id", DatasetController, :show
    patch "/organizations/:organization_id/datasets/:id", DatasetController, :update
    delete "/organizations/:organization_id/datasets/:id", DatasetController, :archive
    post "/organizations/:organization_id/datasets/:id/publish", DatasetController, :publish

    get "/organizations/:organization_id/datasets/:id/current-version",
        DatasetController,
        :current_version

    post "/organizations/:organization_id/datasets/:id/entries", DatasetController, :add_entry

    post "/organizations/:organization_id/datasets/:id/import/csv",
         DatasetController,
         :import_csv

    post "/organizations/:organization_id/datasets/:id/import/jsonl",
         DatasetController,
         :import_jsonl

    post "/organizations/:organization_id/datasets/:id/import/huggingface",
         DatasetController,
         :import_huggingface

    get "/organizations/:organization_id/datasets/:id/export/parquet",
        DatasetController,
        :export_plan

    post "/organizations/:organization_id/datasets/run-fanout/validate",
         DatasetController,
         :validate_fanout

    # Flagged captures (Stage 9: US-106, US-107, US-108, US-109, US-147 manual)
    get "/organizations/:organization_id/captures", CaptureController, :index
    post "/organizations/:organization_id/captures", CaptureController, :create
    get "/organizations/:organization_id/captures/:id", CaptureController, :show

    post "/organizations/:organization_id/captures/:id/promote",
         CaptureController,
         :promote_to_dataset_entry

    post "/organizations/:organization_id/captures/:id/promote/script-node",
         CaptureController,
         :promote_to_script_node

    post "/organizations/:organization_id/captures/:id/promote/dataset-entry",
         CaptureController,
         :promote_to_dataset_entry

    # Auto-flag rules (Stage 10+: US-147)
    get "/organizations/:organization_id/autoflag-rules", AutoflagController, :index
    post "/organizations/:organization_id/autoflag-rules", AutoflagController, :create
    get "/organizations/:organization_id/autoflag-rules/:id", AutoflagController, :show
    patch "/organizations/:organization_id/autoflag-rules/:id", AutoflagController, :update
    delete "/organizations/:organization_id/autoflag-rules/:id", AutoflagController, :delete

    # Enterprise: SSO config (US-142) + Audit log export (US-143)
    get "/organizations/:organization_id/sso-config", EnterpriseController, :get_sso_config
    put "/organizations/:organization_id/sso-config", EnterpriseController, :put_sso_config
    get "/organizations/:organization_id/audit-log.csv", EnterpriseController, :export_audit_log

    # Webhooks (Stage 11: US-144, US-145, US-146) + delivery audit (US-095)
    get "/organizations/:organization_id/webhooks", WebhookController, :index
    post "/organizations/:organization_id/webhooks", WebhookController, :create
    patch "/organizations/:organization_id/webhooks/:id", WebhookController, :update
    delete "/organizations/:organization_id/webhooks/:id", WebhookController, :delete

    get "/organizations/:organization_id/webhooks/:webhook_id/deliveries",
        WebhookController,
        :deliveries

    post "/organizations/:organization_id/webhooks/:webhook_id/deliveries/:delivery_id/retry",
         WebhookController,
         :retry_delivery
  end

  if Application.compile_env(:codefresh, :dev_routes) do
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through [:fetch_session, :protect_from_forgery]
      live_dashboard "/dashboard", metrics: CodefreshWeb.Telemetry
    end
  end
end
