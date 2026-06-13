# requires: base
# apt: elixir, erlang-dev, erlang-xmerl
RUN mix local.hex --force && mix local.rebar --force
