import TrpItemTimelineEmbed from "@/components/pm/trp-item-timeline-embed";
import { trpEmbedConfig } from "@/lib/pm/trp-board-embed";

/**
 * TRP item-timeline embed (W7 component exchange v2 — reverse direction).
 *
 * Renders the <trp-item-timeline> Lit component authored by TRP; bundle and
 * item/activity data flow through the same-origin key proxy (/api/trp-board/*)
 * with the shared key attached server-side. When the embed is not provisioned
 * yet (no TRP_EMBED_API_KEY / TRP_COMPONENT_BASE_URL — W10 wires Infisical)
 * the page degrades to a quiet empty state.
 *
 * The item id is a TRP item UUID or human key (PREFIX-NNN) passed as
 * ?item=<key> — NPL ticket keys map to TRP items with W8's cutover, until
 * then the key is pasted/linked directly.
 */
export default async function TrpItemPage({
  params,
  searchParams,
}: {
  params: Promise<{ orgId: string }>;
  searchParams: Promise<{ item?: string | string[] }>;
}) {
  const { orgId } = await params;
  const { item: rawItem } = await searchParams;
  const itemId = (Array.isArray(rawItem) ? rawItem[0] : rawItem)?.trim() ?? "";
  const config = trpEmbedConfig();
  const effectiveOrgId = config?.orgIdOverride || orgId;

  return (
    <div className="content">
      <main>
        <div className="projects-header">
          <h1 className="sg-page-title">trp item timeline</h1>
        </div>
        <p className="sg-page-intro">
          TRP-authored component embedded via shared key
          <span className="text-[12px] opacity-60"> · bundle + data via same-origin proxy</span>
        </p>

        {!config ? (
          <p className="sg-page-intro">
            embed not configured — the TRP component embed needs TRP_COMPONENT_BASE_URL and
            TRP_EMBED_API_KEY (provisioned via Infisical). until then this page stays
            intentionally empty.
          </p>
        ) : !itemId ? (
          <p className="sg-page-intro">
            no item selected — append <code>?item=&lt;TRP-item-key-or-uuid&gt;</code> to this
            page&apos;s URL (e.g. <code>?item=TRP-0142</code>) to render an item&apos;s timeline.
          </p>
        ) : (
          <div className="mt-6">
            <TrpItemTimelineEmbed orgId={effectiveOrgId} itemId={itemId} heading={undefined} />
          </div>
        )}
      </main>
    </div>
  );
}
