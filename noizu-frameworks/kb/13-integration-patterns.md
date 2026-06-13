# Integration Patterns

Cross-library compositions showing how Noizu libraries work together.

## Entity + GenAI: Persisting Conversations

```elixir
defmodule MyApp.Entity.Conversation do
  use Noizu.Entity
  @vsn 1.0
  @sref "conversation"
  @persistence ecto_store(MyApp.Schema.Conversation, MyApp.Repo)

  def_entity do
    id :uuid
    field :user_ref, nil, Noizu.Entity.UUIDReference
    field :model, :atom
    field :messages, []  # List of GenAI.Message structs
    field :time_stamp, nil, Noizu.Entity.TimeStamp

    @transient true
    field :thread  # Active GenAI.Thread (not persisted)
  end
end

# Rebuild thread from persisted messages
def resume_conversation(conversation) do
  thread = GenAI.Thread.Standard.new()
  |> GenAI.with_model(conversation.model)

  Enum.reduce(conversation.messages, thread, fn msg, t ->
    GenAI.with_message(t, msg)
  end)
end
```

## Weaviate + GenAI: RAG Pipeline

```elixir
defmodule MyApp.RAG do
  def query(user_question, context) do
    # 1. Search Weaviate for relevant documents
    query = Noizu.Weaviate.GraphQL.Get.new("Document")
    |> Noizu.Weaviate.GraphQL.Get.with_fields([:title, :content])
    |> Noizu.Weaviate.GraphQL.Where.add_near_text(%{concepts: [user_question], certainty: 0.7})
    |> Noizu.Weaviate.GraphQL.Additional.with_additional([:certainty])

    {:ok, results} = Noizu.Weaviate.GraphQL.execute(query)
    docs = extract_documents(results)

    # 2. Build GenAI thread with retrieved context
    context_text = Enum.map_join(docs, "\n\n", & &1.content)

    thread = GenAI.Thread.Standard.new()
    |> GenAI.with_model(:"claude-sonnet-4-20250514")
    |> GenAI.with_message(:system, "Answer based on the following context:\n\n#{context_text}")
    |> GenAI.with_message(:user, user_question)
    |> GenAI.with_setting(:max_tokens, 2048)

    # 3. Get completion
    GenAI.run(thread, context)
  end
end
```

## Services + Entities: Worker Pools Processing Entities

```elixir
# Entity as worker state
defmodule MyApp.Entity.Job do
  use Noizu.Entity
  @vsn 1.0
  @sref "job"
  @persistence ecto_store(MyApp.Schema.Job, MyApp.Repo)

  def_entity do
    id :uuid
    field :status, :pending
    field :payload, %{}
    field :result, nil
    field :time_stamp, nil, Noizu.Entity.TimeStamp
  end
end

# Worker pool for job processing
defmodule MyApp.JobPool do
  use Noizu.Service
  def __pool__(), do: __MODULE__
  def __worker__(), do: MyApp.JobPool.Worker
  def __server__(), do: MyApp.JobPool.Server
end

# Submit job via pool
ctx = Noizu.Context.system()
ref = {:ref, MyApp.JobPool.Worker, job_id}
MyApp.JobPool.s_cast!(ref, {:process, job_entity}, ctx, [], 30_000)
```

## FragmentedKeys + Entities: Auto Cache Invalidation

```elixir
defmodule MyApp.Cache do
  def user_profile_key(user_id) do
    tag_user = FragmentedKeys.Tag.Standard.new("User", to_string(user_id))
    tag_site = FragmentedKeys.Tag.Constant.new("Site", "main", 1.0)
    FragmentedKeys.Key.new("UserProfile", [tag_user, tag_site])
  end

  def get_profile(user_id) do
    key = user_profile_key(user_id)
    cache_key = FragmentedKeys.Key.get_key_str(key)

    case MyApp.Cache.Store.get(cache_key) do
      nil ->
        profile = load_profile(user_id)
        MyApp.Cache.Store.set(cache_key, profile, ttl: 3600)
        profile
      cached -> cached
    end
  end

  def invalidate_user(user_id) do
    tag = FragmentedKeys.Tag.Standard.new("User", to_string(user_id))
    FragmentedKeys.Tag.increment(tag)
    # All keys containing this user tag now produce different hashes
  end
end
```

## SmartToken + Auth Flow

```elixir
# Generate verification email
def send_verification(user, context) do
  token = SmartToken.account_verification_token()
  |> SmartToken.validity_period({:unbound, {:relative, [{:day, 3}]}})

  {:ok, saved} = SmartToken.bind!(token, %{recipient: user}, context)
  key = SmartToken.encoded_key(saved)

  SendGrid.Email.build()
  |> SendGrid.Email.add_to(user.email)
  |> SendGrid.Email.put_from("noreply@myapp.com")
  |> SendGrid.Email.put_subject("Verify your account")
  |> SendGrid.Email.put_html("<a href='https://myapp.com/verify?token=#{key}'>Verify</a>")
  |> SendGrid.Mail.send()
end

# Verify token in controller
def verify(conn, %{"token" => token_key}) do
  case SmartToken.authorize!(token_key, conn, Noizu.Context.system()) do
    {:ok, _token} -> activate_account(conn)
    {:error, reason} -> render_error(conn, reason)
  end
end
```

## Key Takeaways
1. Entities provide the data model, GenAI provides the intelligence, Services provide the scale
2. Weaviate + GenAI = RAG pipeline with vector search → context injection → completion
3. FragmentedKeys enable fine-grained cache invalidation without bulk deletes
4. SmartToken + SendGrid = complete auth token email flow
5. All libraries share Context for consistent auth/audit threading
