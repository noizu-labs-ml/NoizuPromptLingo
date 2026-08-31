defmodule DocPointers.Application do
  use Application

  @impl true
  def start(_type, _args) do
    root =
      System.get_env("DOC_POINTERS_ROOT") ||
        Application.get_env(:doc_pointers, :root) ||
        File.cwd!()

    children = [
      {DocPointers.Store, root: root}
    ]

    Supervisor.start_link(children, strategy: :one_for_one, name: DocPointers.Supervisor)
  end
end
