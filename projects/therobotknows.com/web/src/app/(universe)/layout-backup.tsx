import { notFound } from "next/navigation";
import { Sidebar } from "@/components/layout/sidebar";
import { TopBar } from "@/components/layout/top-bar";
import { StatusBar } from "@/components/layout/status-bar";
import { universes } from "@/data/universes";

interface UniverseLayoutProps {
  children: React.ReactNode;
  params: Promise<{ universeId: string }>;
}

export default async function UniverseLayout({ children, params }: UniverseLayoutProps) {
  const { universeId } = await params;
  const universe = universes.find((u) => u.id === universeId);

  if (!universe) {
    notFound();
  }

  return (
    <div className="flex h-screen bg-page overflow-hidden">
      {/* Fixed left sidebar */}
      <Sidebar
        universeId={universeId}
        universeName={universe.name}
      />

      {/* Main content column */}
      <div className="flex flex-col flex-1 min-w-0 overflow-hidden">
        <TopBar
          title={universe.name}
          backHref="/"
          backLabel="Universes"
        />

        {/* Scrollable content */}
        <main className="flex-1 overflow-y-auto bg-page">
          {children}
        </main>

        <StatusBar
          entryCount={universe.entryCount}
          connectionCount={universe.connectionCount}
          flagCount={universe.flagCount}
          lastSync="2m ago"
        />
      </div>
    </div>
  );
}
