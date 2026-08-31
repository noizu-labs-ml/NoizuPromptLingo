import { describe, test, expect, vi, beforeEach } from "vitest";
import { render, screen } from "@testing-library/react";
import { MemoryRouter } from "react-router-dom";
import { Explore } from "../../pages/Explore.tsx";

beforeEach(() => {
  vi.stubGlobal("fetch", vi.fn(() =>
    Promise.resolve({
      ok: true,
      json: () => Promise.resolve({ data: [], meta: { total: 0, limit: 20 } }),
    }),
  ));
});

function renderWithRouter(ui: React.ReactElement) {
  return render(<MemoryRouter>{ui}</MemoryRouter>);
}

describe("Explore", () => {
  test("renders search input", () => {
    renderWithRouter(<Explore />);
    expect(screen.getByPlaceholderText("Search conversations...")).toBeInTheDocument();
  });

  test("renders stat cards", () => {
    renderWithRouter(<Explore />);
    expect(screen.getByText("Conversations")).toBeInTheDocument();
    expect(screen.getByText("Indexed")).toBeInTheDocument();
    expect(screen.getByText("Last Indexed")).toBeInTheDocument();
  });

  test("renders text/semantic mode toggle", () => {
    renderWithRouter(<Explore />);
    expect(screen.getByText("Text")).toBeInTheDocument();
    expect(screen.getByText("Semantic")).toBeInTheDocument();
  });
});
