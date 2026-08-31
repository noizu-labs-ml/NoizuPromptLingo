import React from "react";
import { RouterProvider, useRouter } from "./context/RouterContext.js";
import { HarnessProvider } from "./context/HarnessContext.js";
import { Layout } from "./components/Layout.js";
import { ExplorePage } from "./pages/ExplorePage.js";
import { SafetyWatchPage } from "./pages/SafetyWatchPage.js";
import { ThreadPage } from "./pages/ThreadPage.js";
import { ContinueSessionPage } from "./pages/ContinueSessionPage.js";
import { EditPage } from "./pages/EditPage.js";
import { ConvertPage } from "./pages/ConvertPage.js";
import { DatasetsPage } from "./pages/DatasetsPage.js";
import { DatasetDetailPage } from "./pages/DatasetDetailPage.js";
import { PromptsPage } from "./pages/PromptsPage.js";
import { TagsPage } from "./pages/TagsPage.js";
import { ProjectsPage } from "./pages/ProjectsPage.js";
import { ProjectDetailPage } from "./pages/ProjectDetailPage.js";
import { SettingsPage } from "./pages/SettingsPage.js";
import { StyleGuidePage } from "./pages/StyleGuidePage.js";

function PageRouter() {
  const { current } = useRouter();

  switch (current.page) {
    case "explore":
      return <ExplorePage />;
    case "safety-watch":
      return <SafetyWatchPage />;
    case "thread":
      return <ThreadPage />;
    case "continue":
      return <ContinueSessionPage />;
    case "edit":
      return <EditPage />;
    case "convert":
      return <ConvertPage />;
    case "datasets":
      return <DatasetsPage />;
    case "dataset-detail":
      return <DatasetDetailPage />;
    case "prompts":
      return <PromptsPage />;
    case "tags":
      return <TagsPage />;
    case "projects":
      return <ProjectsPage />;
    case "project-detail":
      return <ProjectDetailPage />;
    case "settings":
      return <SettingsPage />;
    case "style-guide":
      return <StyleGuidePage />;
    default:
      return <ExplorePage />;
  }
}

// ⟦𓋎𓂊𓃵𓎼⟧ InteractiveApp :: auto-generated pointer for public function InteractiveApp
export function InteractiveApp() {
  return (
    <HarnessProvider>
      <RouterProvider>
        <Layout>
          <PageRouter />
        </Layout>
      </RouterProvider>
    </HarnessProvider>
  );
}
