import React from "react";
import { Routes, Route } from "react-router-dom";
import { Layout } from "./components/Layout.js";
import { Explore } from "./pages/Explore.js";
import { Thread } from "./pages/Thread.js";
import { ContinueSession } from "./pages/ContinueSession.js";
import { Edit } from "./pages/Edit.js";
import { Convert } from "./pages/Convert.js";
import { Datasets } from "./pages/Datasets.js";
import { DatasetDetail } from "./pages/DatasetDetail.js";
import { Prompts } from "./pages/Prompts.js";
import { Tags } from "./pages/Tags.js";
import { Projects } from "./pages/Projects.js";
import { ProjectDetail } from "./pages/ProjectDetail.js";
import { Settings } from "./pages/Settings.js";
import { StyleGuide } from "./pages/StyleGuide.js";
import { SafetyWatch } from "./pages/SafetyWatch.js";

// ⟦𓃺𓆬𓂜𓄑⟧ App :: auto-generated pointer for public function App
export function App() {
  return (
    <Routes>
      <Route element={<Layout />}>
        <Route index element={<Explore />} />
        <Route path="search" element={<Explore />} />
        <Route path="browse" element={<Explore />} />
        <Route path="safety-watch" element={<SafetyWatch />} />
        <Route path="thread/:id" element={<Thread />} />
        <Route path="thread/:id/continue" element={<ContinueSession />} />
        <Route path="thread/:id/edit" element={<Edit />} />
        <Route path="thread/:id/convert" element={<Convert />} />
        <Route path="datasets" element={<Datasets />} />
        <Route path="datasets/:name" element={<DatasetDetail />} />
        <Route path="prompts" element={<Prompts />} />
        <Route path="tags" element={<Tags />} />
        <Route path="projects" element={<Projects />} />
        <Route path="projects/:slug" element={<ProjectDetail />} />
        <Route path="settings" element={<Settings />} />
        <Route path="style-guides" element={<StyleGuide />} />
        <Route path="style-guides/:slug" element={<StyleGuide />} />
      </Route>
    </Routes>
  );
}
