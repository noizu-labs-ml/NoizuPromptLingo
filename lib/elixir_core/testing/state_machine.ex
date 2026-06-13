

defmodule Noizu.StateMachine.Records do
  require Record
  Record.defrecord(:nsm, [global: nil, module: nil, scenario: nil, modules: %{}, local: nil, other: nil, handle: nil, state: :not_loaded])
end

defmodule Noizu.StateMachine.Module do
  import Macro
  require Noizu.StateMachine.Records
  import Noizu.StateMachine.Records


  defmacro __before_compile__(env) do
    m = env.module
    quote  do


      states = Enum.group_by(@__nsm__states || [], & elem(&1, 0) |> elem(1) )

      initial_states = Enum.group_by(@__nsm__initial_state || [], & elem(&1, 0))


      for {module, entries} <- states do
        case module do
          m = [] ->
            for {_, {name, arity, q}} <- Enum.reverse(entries) do
              q = q
                  |> Macro.expand(__ENV__)
                  |> Macro.to_string()
                  |> Code.string_to_quoted!()
                  |> Code.compile_quoted()
            end

            wrappers = for {_, {name, arity, _}} <- Enum.reverse(entries) do
              {name, arity, :"__nsm_def__#{name}"}
            end
            |> Enum.uniq()



            for {name, arity, call} <- wrappers do
              call_args = Macro.generate_arguments(arity, __MODULE__)

              mod = __MODULE__
              invoke = quote do
                apply(__MODULE__, unquote(name), unquote(call_args))
              end
              quote do
                def unquote(name)(unquote_splicing(call_args)) do
                  # TODO LOAD STATE THEN CALL
                  state = unquote(List.first(call_args))
                  state = nsm(state, module: __MODULE__)
                  state = Noizu.StateMachine.Module.__nsm_load__(state)
                  apply(__MODULE__, unquote(call), [state| unquote(Enum.slice(call_args, 1..-1))])
                end
              end
              |> Macro.expand(__ENV__)
              |> Macro.to_string()
              |> Code.string_to_quoted!()
              |> Code.compile_quoted()

            end


            m_initial_states = get_in(initial_states, [Access.key(m, [])])
              for {_, scenario, docs, block} <- m_initial_states do
                {:def, [], [{:scenario, [], [scenario]}, [do: block]]}
                |> Macro.expand(__ENV__)
                |> Macro.to_string()
                |> Code.string_to_quoted!()
                |> Code.compile_quoted()
              end

            d = for {_, scenario, docs, block} <- m_initial_states do
              if docs do
                """
                \# :#{scenario}
                #{docs}
                """
              end
            end |> Enum.reject(&is_nil/1) |> Enum.join("\n\n")

            @doc """
            #{unless d == "", do: d, else: "Default Empty State"}
            """
            def scenario(scenario) when scenario !== :default do
              scenario(:default)
            end
            def scenario(_), do: %{}

          m when is_list(m) ->
            mod = Module.concat([__MODULE__| m])
            entries = Enum.reverse(entries)

            m_initial_states = get_in(initial_states, [Access.key(m, [])])


            @__nsm__modules mod
            defmodule mod do
              for {_, {name, arity, q}} <- entries do
                q
                |> Macro.expand(__ENV__)
                |> Macro.to_string()
                |> Code.string_to_quoted!()
                |> Code.compile_quoted()
              end

              wrappers = for {_, {name, arity, _}} <- Enum.reverse(entries) do
                           {name, arity, :"__nsm_def__#{name}"}
                         end
                         |> Enum.uniq()



              for {name, arity, call} <- wrappers do
                call_args = Macro.generate_arguments(arity, mod)

                quote do
                  def unquote(name)(unquote_splicing(call_args)) do
                    # TODO LOAD STATE THEN CALL
                    state = unquote(List.first(call_args))
                    state = nsm(state, module: __MODULE__)
                    state = Noizu.StateMachine.Module.__nsm_load__(state)
                    #IO.puts "LOAD STATE THEN CALL"
                    apply(__MODULE__, unquote(call), [state| unquote(Enum.slice(call_args, 1..-1))])
                  end
                end
                |> Macro.expand(__ENV__)
                |> Macro.to_string()
                |> Code.string_to_quoted!()
                |> Code.compile_quoted()

              end


              for {_, scenario, docs, block} <- m_initial_states do
                {:def, [], [{:scenario, [], [scenario]}, [do: block]]}
                |> Macro.expand(__ENV__)
                |> Macro.to_string()
                |> Code.string_to_quoted!()
                |> Code.compile_quoted()
              end

              d = for {_, scenario, docs, block} <- m_initial_states do
                    if docs do
                      """
                      \# :#{scenario}
                      #{docs}
                      """
                    end
                  end |> Enum.reject(&is_nil/1) |> Enum.join("\n\n")
              @doc """
              #{unless d == "", do: d, else: "Default Empty State"}
              """
              def scenario(scenario) when scenario !== :default do
                scenario(:default)
              end
              def scenario(_), do: %{}

              @methods (for {_, {name, arity, q}} <- entries do
                {name, arity}
              end)

              def __nsm_info__(:methods) do
                @methods
              end

              def bind(Elixir.Mock) do
                # Construct List of method overrides
                # in mark format
                #{:ok, current} = Process.get({__MODULE__, scenario}, {:error, :not_initialized})
                #handle = nsm(current, :handle)
                #{module, [:passthrough], [
                #method(construct_args) -> __nsm_def__method(nsm, construct_args)
                #])
                []
              end

              def scenario(scenario) do
                %{}
              end
            end
        end
      end

      def __nsm_info__(:modules) do
        @__nsm__modules
      end
      def __nsm_info__(:macros) do
        @__nsm__states
      end
    end
  end


  def __nsm_load__(nsm(handle: handle, module: module, state: :not_loaded) = nsm) do
    nsm(modules: modules, global: global) = state = Agent.get(handle, &(&1))
    nsm(state, module: module, local: modules[module] || %{}, state: :loaded)
  end

  def __nsm_init_module_state__(nsm(handle: handle, module: module), module_state) do
    Agent.get_and_update(handle, fn(nsm(modules: modules) = state) ->
      modules = put_in(modules, [module], module_state)
      state = nsm(state, modules: modules)
      {state, state}
    end)
  end


  defmacro nsm_set_global_state(path, value) do
    quote do
      case var!(nsm) do
        nsm(handle: handle) ->
          Agent.get_and_update(handle,
            fn(state = nsm(global: global)) ->
              global = put_in(global, unquote(path), unquote(value))
              state = nsm(state, global: global)
              {state, state}
            end
          )
      end
    end
  end

  defmacro nsm_set_local_state(path, value) do
    quote do
      case var!(nsm) do
        nsm(module: module, handle: handle) ->
          Agent.get_and_update(handle,
            fn(state = nsm(modules: modules)) ->
              modules = put_in(modules, [Access.key(module) | unquote(path)], unquote(value))
              state = nsm(state, modules: modules)
              {state, state}
            end
          )
      end
    end
  end


  defmacro nsm_set_module_state(module, path, value) do
    quote do
      case var!(nsm) do
        nsm(handle: handle) ->
          Agent.get_and_update(handle,
            fn(state = nsm(modules: modules)) ->
              modules = put_in(modules, [Access.key(unquote(module)) | unquote(path)], unquote(value))
              state = nsm(state, modules: modules)
              {state, state}
            end
          )
      end
    end
  end


  defmacro nsm_local_state() do
    quote do
      case var!(nsm) do
        nsm(handle: handle, module: module) ->
          Agent.get(handle, fn(state) ->
            nsm(state, :global)[module]
          end)
#        nsm(handle: handle, module: module, state: :not_loaded) ->
#          state = Agent.get(handle, &(&1))
#          nsm(modules: modules) = state
#          modules[module] || %{}
#        nsm(handle: handle, module: module, modules: modules, state: :loaded) ->
#          nsm(modules: modules) = state
#          modules[module] || %{}
        _ -> throw "nsm var not set"
      end
    end
  end

  defmacro nsm_global_state() do
    quote do
      case var!(nsm) do
        nsm(handle: handle) ->
         Agent.get(handle, fn(state) ->
          nsm(state, :global)
         end)
#        nsm(handle: handle, state: :not_loaded) ->
#          state = Agent.get(handle, &(&1))
#          #Process.put({:nsm, __MODULE__}, state)
#          nsm(global: global) = state
#          global
#        nsm(handle: handle, state: state) ->
#          #Process.put({:nsm, __MODULE__}, state)
#          nsm(global: global) = state
#          global
#        _ -> throw "nsm var not set"
      end
#
#      case Process.get({:nsm, __MODULE__}, :__nsm_not_set__) do
#        :__nsm_not_set__ ->
#          case var!(nsm) do
#            nsm(handle: handle, state: :not_loaded) ->
#              state = Agent.get(handle, &(&1))
#              Process.put({:nsm, __MODULE__}, state)
#              nsm(global: global) = state
#              global
#            nsm(handle: handle, state: state) ->
#              Process.put({:nsm, __MODULE__}, state)
#              nsm(global: global) = state
#              global
#              _ -> throw "nsm var not set"
#          end
#        nsm(handle: handle, state: :not_loaded) ->
#          state = Agent.get(handle, &(&1))
#          Process.put({:nsm, __MODULE__}, state)
#          nsm(global: global) = state
#          global
#        nsm(state: state) ->
#          Process.put({:nsm, __MODULE__}, state)
#          nsm(global: global) = state
#          global
#      end
    end
  end


  defmacro unpackme(name, args, guards, block) do
    unless guards == [] do
      quote do
        unquote({:def, [], [{:when, [], [{name, [], args}, guards]}, [do: block]]})
      end
    else
      quote do
        unquote({:def, [], [{name, [], args}, [do: block]]})
      end
    end
  end

  defmacro unpackme(block) do
    block
  end


  defmacro defsm_module(name, do: block) do
    quote do
      m = Module.get_attribute(__MODULE__, :__nsm_module_queue, [])
      @__nsm_module_queue [unquote(name) | m]
      unquote(block)
      @__nsm_module_queue Enum.slice(@__nsm_module_queue, 1..-1)
    end
  end

  def check_header(name, args) do
    IO.puts "HAS #{name}/#{length(args)} been pushed already?"
    :ok
  end

  defmacro blowitup(name, meta, prefix, args, guards, block) do
    gg = case guards do
      [gg] -> gg
      gg -> gg
    end

    quote do
      q = Macro.expand(unquote(prefix),__ENV__)
      args = unquote(Macro.escape(args))

      effective_guards =
        (Module.get_attribute(__MODULE__, :__sm_withguards, [])
         |> List.flatten()
         |> case do
              [] -> nil
              prefix_guard when is_list(prefix_guard) ->
                p = prefix_guard
                    |> Enum.reduce([], fn(x, acc) ->
                  cond do
                    acc == [] -> x
                    :else -> {:and, unquote(meta), [x,acc]}
                  end
                end)
                guards = unquote(Macro.escape(guards))
                unless guards == [] do
                  {:and, [], [p| guards]}
                else
                  p
                end

            end)

      unless g_pre = effective_guards do
        name = unquote(name)
        [qq] = q
        {qq2,_} = qq
                  |> Macro.prewalk(nil,
                       fn
                         ({:=, [lhs, rhs]}, acc) ->
                           inject = quote do
                             unquote(lhs) = unquote(rhs)
                           end
                           {inject, acc}
                         (ast, acc) ->
                           {ast, acc}
                       end
                     )


        iargs = [{:=, [], [{:nsm, [], nil}, qq2]}| unquote(Macro.escape(args))]
                |> Macro.expand(__ENV__)
        block = unquote(Macro.escape(block))

        q = unless unquote(Macro.escape(gg)) == [] do
          {:def, [], [{:when, [], [{:"__nsm_def__#{unquote(name)}", [], (quote do: unquote(iargs))}, unquote(Macro.escape(gg))]}, [do: block]]}
              |> Macro.to_string()
              |> Code.string_to_quoted!()
        else
          {:def, [], [{:"__nsm_def__#{unquote(name)}", [], (quote do: unquote(iargs))}, [do: block]]}
              |> Macro.to_string()
              |> Code.string_to_quoted!()
        end
        sm_ms = @__nsm_module_queue || []
        @__nsm__states {{:context, sm_ms}, {unquote(name), length(iargs), q}}



      else
        name = unquote(name)
        [qq] = q
        {qq2,_} = qq
                  |> Macro.prewalk(nil,
                       fn
                         ({:=, [lhs, rhs]}, acc) ->
                           inject = quote do
                             unquote(lhs) = unquote(rhs)
                           end
                           {inject, acc}
                         (ast, acc) ->
                           {ast, acc}
                       end
                     )


        iargs = [{:=, [], [{:nsm, [], nil}, qq2]}| unquote(Macro.escape(args))]
                |> Macro.expand(__ENV__)
        block = unquote(Macro.escape(block))

        q = unless g_pre == [] do
           {:def, [], [{:when, [], [{:"__nsm_def__#{unquote(name)}", [], (quote do: unquote(iargs))}, g_pre]}, [do: block]]}
              |> Macro.to_string()
              |> Code.string_to_quoted!()
        else
          {:def, [], [{:"__nsm_def__#{unquote(name)}", [], (quote do: unquote(iargs))}, [do: block]]}
              |> Macro.to_string()
              |> Code.string_to_quoted!()
        end
        sm_ms = @__nsm_module_queue || []
        @__nsm__states {{:context, sm_ms}, {unquote(name), length(iargs), q}}
      end



    end
  end


  def merge_nsm_ast(nil, outer), do: outer
  def merge_nsm_ast(inner, nil), do: inner
  def merge_nsm_ast(match, match), do: match
  def merge_nsm_ast(inner, outer) do
    # Check if inner has a catch all assignment, if so replace
    # Check if outer has a catch all assignment, if so replace
    case [inner, outer] do
      [{:=, inner_m, [inner_lhs, inner_rhs]}, {:=, outer_m, [outer_lhs, outer_rhs]}] ->
        m = Keyword.merge(inner_m, outer_m)
        Enum.uniq([inner_lhs, inner_rhs, outer_lhs, outer_rhs])
        |> Enum.reject(& is_tuple(&1) && elem(&1, 0) == :_ && elem(&1, 2) == nil)
        |> case do
             [] -> {:_, [], nil}
             [a] -> a
             [a,b] -> {:=, m, [a,b]}
             [a,b,c] -> {:=, m, [a,{:=, m, [b,c]}]}
             [_,_,_,_] -> {:=, [], [inner, outer]}
           end
      [check = {:=, m, [lhs, rhs]}, keep] ->
        Enum.uniq([lhs, rhs])
        |> Enum.reject(& is_tuple(&1) && elem(&1, 0) == :_ && elem(&1, 2) == nil)
        |> case do
             [] -> keep
             [a] -> {:=, m, [a, keep]}
             [_,_] -> {:=, [], [check, keep]}
           end
      [keep, check = {:=, m, [lhs, rhs]}] ->
        Enum.uniq([lhs, rhs])
        |> Enum.reject(& is_tuple(&1) && elem(&1, 0) == :_ && elem(&1, 2) == nil)
        |> case do
             [] -> keep
             [a] -> {:=, m, [a, keep]}
             [_,_] -> {:=, [], [keep, check]}
           end
      _ ->
        {:=, [], [inner, outer]}
    end
  end

  def merge_nsm([[]], outer) do
    outer
  end
  def merge_nsm([], outer) do
    outer
  end
  def merge_nsm(inner, [[]]) do
    inner
  end
  def merge_nsm(inner, []) do
    inner
  end
  def merge_nsm([inner], [outer]) do
    inner_keys = List.flatten(inner) |> Enum.map(fn
      ({key, _}) when is_atom(key) -> key
      _ -> nil
    end) |> Enum.reject(&is_nil/1)
    outer_keys = List.flatten(outer) |> Enum.map(fn
      ({key, _}) when is_atom(key) -> key
      _ -> nil
    end) |> Enum.reject(&is_nil/1)
    keys = (inner_keys ++ outer_keys)
           |> Enum.uniq()
    merged = Enum.map(keys, & {&1, merge_nsm_ast(inner[&1], outer[&1])})
    [merged]
  end

  def combine_attributes() do
    qq = quote do
      {:nsm, [], []}
    end
    quote do
      (Module.get_attribute(__MODULE__, :__sm_withargs, [])
      |> Macro.postwalk(nil,
           fn
             (ast = {:nsm, m, args}, nil) ->
               {ast, args}
             ({:nsm, m, args}, acc) ->
               args = merge_nsm(args, acc)
               {{:nsm, m, args}, args}
             (ast, acc) ->
               {ast, acc}
           end
         )
      |> elem(0)
      |> List.last()
       ) || [unquote(qq)]
    end
  end




  defmacro defsm({:when, _, [{:state_behaviour, meta, args} = signature | guards]}, do: body) do
    # Disallow default args
    # Replace global_state, local_state with nsm__internal_global nsm__internal_local
    {p_args, f} =
      cond do
        args == [] || args == nil ->
          m = meta
          nargs = [global: {:=, m, [{:global, m, nil}, {:_, m, nil}]}, local: {:=, [{:local, m, nil}, {:_, m, nil}]}]
          {[{:nsm, meta, [nargs]}], :set}
        length(args) == 1 ->
          Macro.postwalk(args || [], nil,
            fn
              (ast = {:nsm, m, [nargs]}, acc) when is_list(nargs) ->
                m = Keyword.delete(m, :line)
                gi = Enum.find_index(nargs, &(elem(&1, 0) == :global))
                nargs = case gi do
                  nil -> nargs ++ [global: {:=, m, [{:global, m, nil}, {:_, m, nil}]}]
                  index -> update_in(nargs, [Access.at(index)],
                             fn({:global, v}) ->
                               {:global, {:=, m, [{:global, m, nil}, v]}}
                             end
                           )
                end
                li = Enum.find_index(nargs, &(elem(&1, 0) == :local))
                nargs = case li do
                  nil -> nargs ++ [local: {:=, m, [{:local, m, nil}, {:_, m, nil}]}]
                  index -> update_in(nargs, [Access.at(index)],
                             fn({:local, v}) ->
                               {:local, {:=, m, [{:local, m, nil}, v]}}
                             end
                           )
                end
                {{:nsm, m, [nargs]}, :updated}

              (ast = {:nsm, m, []}, acc) ->
                m = Keyword.delete(m, :line)
                nargs = [global: {:=, m, [{:global, m, nil}, {:_, m, nil}]}, local: {:=, m, [{:local, m, nil}, {:_, m, nil}]}]
                {{:nsm, m, [nargs]}, :injected}

              (ast = {:nsm, m, nil}, acc) ->
                m = Keyword.delete(m, :line)
                nargs = [global: {:=, m, [{:global, m, nil}, {:_, m, nil}]}, local: {:=, m, [{:local, m, nil}, {:_, m, nil}]}]
                {{:nsm, m, [nargs]}, :injected}

              ({type, m, args}, acc) ->
                m = Keyword.delete(m, :line)
                {{type, m, args}, acc}
              (ast, acc) -> {ast, acc}
            end
          )
      end
    IO.puts "ENTER STATE CONSTRAINT SECTION| #{f}"
    unless f do
      throw "MALFORMED"
    end

    # todo composite p_args
    p_args = p_args
             |> Macro.escape()
    guards = guards
                 |> Macro.escape()


    quote do
      a = Module.get_attribute(__MODULE__, :__sm_withargs, [])
      g = Module.get_attribute(__MODULE__, :__sm_withguards, [])
      @__sm_withargs [unquote(p_args)  | a]
      @__sm_withguards [unquote(guards) | g]


      unquote(body)
      @__sm_withguards Enum.slice(@__sm_withguards, 1..-1)
      @__sm_withargs Enum.slice(@__sm_withargs, 1..-1)
    end
  end

  defmacro defsm({:when, wm, [{name, meta, args} = signature | guards]}, do: block) do
    # Disallow default args if not header
    # Disallow header if already defined of same length
    IO.puts "PUSH def <- body for #{inspect name}\\#{length args} with guards"
    prefix_arg_old =
      quote do
        Module.get_attribute(__MODULE__, :__sm_withargs, [])
        |> List.first()
      end
    prefix_arg = combine_attributes()
    quote do
      guards = unquote(Macro.escape(guards))
      q = blowitup(
        unquote(name),
        unquote(wm),
        unquote(prefix_arg),
        unquote(args),
        unquote(guards),
        unquote(block)
      )
      |> Macro.expand(__ENV__)
      |> Code.compile_quoted()
    end
  end

  defmacro defsm({name, meta, args} = signature, do: block) do
    # Disallow default args if not header
    # Disallow header if already defined of same length
    IO.puts "PUSH def <- body for #{inspect name}\\#{length args}"
    prefix_arg_old =
      quote do
        Module.get_attribute(__MODULE__, :__sm_withargs, [])
        |> List.first()
      end
    prefix_arg = combine_attributes()
    guards = []
    quote do
      guards = unquote(Macro.escape(guards))
      q = blowitup(
            unquote(name),
            unquote(meta),
            unquote(prefix_arg),
            unquote(args),
            unquote(guards),
            unquote(block)
          )
          |> Macro.expand(__ENV__)
          |> Code.compile_quoted()
    end
  end
  defmacro defsm({name, meta, args} = signature) do
    # Disallow default args if not header
    # Disallow header if already defined of same length
    with :ok <- check_header(name, args) do
      IO.puts "PUSH def head for #{inspect name}\\#{length args}"
    end
  end


  defmacro scenario_initial_state(scenario, do: body) do
    quote do
      is = @__nsm_module_queue || []
      d = Module.get_attribute(__MODULE__, :scenariodoc, false)
      Module.delete_attribute(__MODULE__, :scenariodoc)
      @__nsm__initial_state {is, unquote(scenario), d, unquote(Macro.escape(body))}
    end
  end

  defmacro for_state({:when, m, [{:~>, meta, [name, signature]} | guards]}, do: body) do
    guards = [{:and, m, [{:==, [], [name, name]} | guards]}]
    q = quote do
      defsm state_behaviour(unquote(signature)) when unquote(guards) do
        unquote(body)
      end
    end
  end

  defmacro for_state({:when, m, [{state, meta, args} = signature | guards]}, do: body) do
    guards = [{:and, m, [{:==, [], [:unamed_state, :unamed_state]} | guards]}]
    q = quote do
      defsm state_behaviour(unquote(signature)) when unquote(guards) do
        unquote(body)
      end
    end
  end


  defmacro for_state({:when, m, [name | guards]}, do: body) when is_bitstring(name) do
    guards = [{:and, m, [{:==, [], [name, name]} | guards]}]
    q = quote do
      defsm state_behaviour() when unquote(guards) do
        unquote(body)
      end
    end
  end


  defmacro for_state({state, meta, args} = signature, do: body) do
    quote do
      defsm state_behaviour(unquote(state)) when :unnamed_state == :unnamed_state do
        unquote(body)
      end
    end
  end

  defmacro for_state(name, {:when, m, [arg_guard|guards]}, do: body) do
    guards = [{:and, m, [{:==, [], [name, name]} | guards]}]
    quote do
      defsm state_behaviour(unquote(arg_guard)) when unquote(guards) do
        unquote(body)
      end
    end
  end
  defmacro for_state(name, state, do: body) do
    quote do
      defsm state_behaviour(unquote(state)) when (unquote(name) == unquote(name)) do
        unquote(body)
      end
    end
  end

  defmacro lhs ~> rhs do
    {:~>, [], [lhs, rhs]}
  end


end

defmodule Noizu.StateMachine do

  defmacro __using__(options \\ nil) do
    quote do
      require Noizu.StateMachine.Module
      import Noizu.StateMachine.Module
      require Noizu.StateMachine.Records
      import Noizu.StateMachine.Records
      Module.register_attribute(__MODULE__, :__nsm_module_queue, [accumulate: false])
      Module.register_attribute(__MODULE__, :__nsm__initial_state, accumulate: true)
      Module.register_attribute(__MODULE__, :__nsm__states, accumulate: true)
      Module.register_attribute(__MODULE__, :__nsm__modules, accumulate: true)

      @before_compile Noizu.StateMachine.Module

      def initialize(scenario) do
        global = scenario(scenario)
        modules = Enum.map(__nsm_info__(:modules), &({&1, apply(&1, :scenario, [scenario])}))
                  |> Map.new()
        handle = {:global, {__MODULE__, scenario, :os.system_time(:millisecond)}}
        initial_state = nsm(handle: handle, global: global, scenario: scenario, modules: modules, state: :loaded)
        Agent.start_link(fn() -> initial_state  end, name: handle)
        Process.put({:__nsm__, __MODULE__, scenario}, {:ok, initial_state})
        Process.put({:__nsm__, __MODULE__, {:active, :scenario}}, {:ok, scenario})
        handle
      end

      def reset(scenario) do
        global = scenario(scenario)
        modules = Enum.map(__nsm_info__(:modules), &({&1, apply(&1, :scenario, [scenario])}))
                  |> Map.new()
        {:ok, scenario} = Process.get({:__nsm__, __MODULE__, {:active, :scenario}}, {:error, :not_initialized})
        {:ok, current} = Process.get({:__nsm__, __MODULE__, scenario}, {:error, :not_initialized})
        handle = nsm(current, :handle)
        update = nsm(current, handle: handle, global: global, scenario: scenario, modules: modules, state: :loaded)
        Agent.update(handle, fn(_) -> update end)
      end

      def reset(scenario) do
        global = scenario(scenario)
        modules = Enum.map(__nsm_info__(:modules), &({&1, apply(&1, :scenario, [scenario])}))
                  |> Map.new()
        {:ok, current} = Process.get({:__nsm__, __MODULE__, scenario}, {:error, :not_initialized})
        handle = nsm(current, :handle)
        update = nsm(current, handle: handle, global: global, scenario: scenario, modules: modules, state: :loaded)
        Agent.update(handle, fn(_) -> update end)
      end



    end
  end


end
