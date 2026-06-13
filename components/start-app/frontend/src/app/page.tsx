import { StyleGuideBtn, StyleGuideCard, StyleGuideCardGrid } from "@noizu/styleguide/components";
import Link from "next/link";

export default function Home() {
  return (
    <div className="content">
      <main>
        <h1 className="sg-page-title">Project Name</h1>
        <p className="sg-page-intro">
          Edit this page to build your project. Auth is ready — sign up and log in.
        </p>
        <div className="button-row sg-page-cta">
          <Link href="/styleguide"><StyleGuideBtn variant="black" label="Style Guide" /></Link>
          <Link href="/sitemap"><StyleGuideBtn variant="outline" label="Site Map" /></Link>
          <Link href="/signup"><StyleGuideBtn variant="outline" label="Get Started" /></Link>
        </div>
        <StyleGuideCardGrid>
          <StyleGuideCard title="Accounts" body="Registration, login, and JWT auth are wired up and ready." />
          <StyleGuideCard title="Design System" body="YAML-driven CSS generation with the styleguide engine." />
          <StyleGuideCard title="Containerized" body="Dockerfiles for both frontend and backend, ready for K8s." />
        </StyleGuideCardGrid>
      </main>
    </div>
  );
}
