import { describe, test, expect } from "vitest";
import { render, screen } from "@testing-library/react";
import { MemoryRouter } from "react-router-dom";
import { Layout } from "../../components/Layout.tsx";

describe("Layout", () => {
  test("renders navbar with agent-watch-dog branding", () => {
    render(
      <MemoryRouter>
        <Layout />
      </MemoryRouter>,
    );
    expect(screen.getByText("agent-watch-dog")).toBeInTheDocument();
  });

  test("renders sidebar navigation items", () => {
    render(
      <MemoryRouter>
        <Layout />
      </MemoryRouter>,
    );
    expect(screen.getByText("Explore")).toBeInTheDocument();
    expect(screen.getByText("Datasets")).toBeInTheDocument();
    expect(screen.getByText("Prompts")).toBeInTheDocument();
    expect(screen.getByText("Projects")).toBeInTheDocument();
  });

  test("renders Settings link separated from main nav", () => {
    render(
      <MemoryRouter>
        <Layout />
      </MemoryRouter>,
    );
    expect(screen.getByText("Settings")).toBeInTheDocument();
  });

  test("shows 'Indexed' status indicator", () => {
    render(
      <MemoryRouter>
        <Layout />
      </MemoryRouter>,
    );
    expect(screen.getByText("Indexed")).toBeInTheDocument();
  });

  test("hides web chrome when hosted by the Mac app", () => {
    (window as Window & { __LLM_TOOLKIT_NATIVE_CHROME__?: boolean }).__LLM_TOOLKIT_NATIVE_CHROME__ = true;
    render(
      <MemoryRouter>
        <Layout />
      </MemoryRouter>,
    );
    expect(screen.queryByText("agent-watch-dog")).not.toBeInTheDocument();
    expect(screen.queryByText("Explore")).not.toBeInTheDocument();
    delete (window as Window & { __LLM_TOOLKIT_NATIVE_CHROME__?: boolean }).__LLM_TOOLKIT_NATIVE_CHROME__;
  });
});
