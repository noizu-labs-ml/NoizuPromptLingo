import React from "react";
import { RouterProvider, useRouter } from "./context/RouterContext.js";
import { Layout } from "./components/Layout.js";
import { ExplorePage } from "./pages/ExplorePage.js";
import { ThreadPage } from "./pages/ThreadPage.js";
import { EditPage } from "./pages/EditPage.js";
import { ConvertPage } from "./pages/ConvertPage.js";
import { DatasetsPage } from "./pages/DatasetsPage.js";
import { DatasetDetailPage } from "./pages/DatasetDetailPage.js";
import { PromptsPage } from "./pages/PromptsPage.js";
import { TagsPage } from "./pages/TagsPage.js";
import { ProjectsPage } from "./pages/ProjectsPage.js";
import { ProjectDetailPage } from "./pages/ProjectDetailPage.js";
import { SettingsPage } from "./pages/SettingsPage.js";

function PageRouter() {
  const { current } = useRouter();

  switch (current.page) {
    case "explore":
      return <ExplorePage />;
    case "thread":
      return <ThreadPage />;
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
    default:
      return <ExplorePage />;
  }
}

export function InteractiveApp() {
  return (
    <RouterProvider>
      <Layout>
        <PageRouter />
      </Layout>
    </RouterProvider>
  );
}
