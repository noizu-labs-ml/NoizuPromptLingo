defmodule NoizuPromptLingua.Domains.Wiki.Tools.Overview do
  use Noizu.MCP.Server.Tool,
    name: "Wiki.Overview",
    description: "List wiki tools and space/page counts for an organization.",
    annotations: [read_only_hint: true],
    category: "Wiki"

  input do
    field :organization, :string, required: true, description: "Organization slug or UUID"
  end

  alias NoizuPromptLingua.Domains.Wiki
  alias NoizuPromptLingua.MCP.{Args, Resolve}

  @impl true
  def call(args, _ctx) do
    org_ref = Args.get(args, :organization)

    case Resolve.organization_id(org_ref) do
      nil ->
        {:error, "Organization '#{org_ref}' not found"}

      org_id ->
        {:ok, %{
          domain: "Wiki",
          subdomain: "wiki.tobor.locker",
          organization_id: org_id,
          spaces: Wiki.count_spaces(org_id),
          pages: Wiki.count_pages(org_id),
          tools: [
            %{name: "Wiki.SpaceList", description: "List wiki spaces in an org"},
            %{name: "Wiki.SpaceGet", description: "Get a space with its pages"},
            %{name: "Wiki.SpaceCreate", description: "Create a wiki space"},
            %{name: "Wiki.SpaceUpdate", description: "Update a wiki space"},
            %{name: "Wiki.SpaceDelete", description: "Delete a wiki space"},
            %{name: "Wiki.PageList", description: "List pages in a space"},
            %{name: "Wiki.PageGet", description: "Get a page with comments/attachments/reactions"},
            %{name: "Wiki.PageCreate", description: "Create a page in a space"},
            %{name: "Wiki.PageUpdate", description: "Update a page"},
            %{name: "Wiki.PageDelete", description: "Delete a page"},
            %{name: "Wiki.CommentList", description: "List comments on a page"},
            %{name: "Wiki.CommentCreate", description: "Add a comment to a page"},
            %{name: "Wiki.CommentDelete", description: "Delete a comment"},
            %{name: "Wiki.AttachmentList", description: "List attachments on a page"},
            %{name: "Wiki.AttachmentCreate", description: "Attach a file reference to a page"},
            %{name: "Wiki.AttachmentDelete", description: "Delete an attachment"},
            %{name: "Wiki.ReactionList", description: "List reactions on a page or comment"},
            %{name: "Wiki.ReactionAdd", description: "Add a reaction to a page or comment"},
            %{name: "Wiki.ReactionRemove", description: "Remove a reaction"}
          ]
        }}
    end
  end
end
