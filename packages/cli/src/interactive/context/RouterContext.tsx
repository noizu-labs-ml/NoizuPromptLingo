import React, { createContext, useContext, useReducer, useCallback, useMemo } from "react";

export type PageName =
  | "explore"
  | "thread"
  | "edit"
  | "convert"
  | "datasets"
  | "dataset-detail"
  | "prompts"
  | "tags"
  | "projects"
  | "project-detail"
  | "settings";

export interface Route {
  page: PageName;
  params: Record<string, string>;
}

interface RouterState {
  stack: Route[];
}

type RouterAction =
  | { type: "push"; route: Route }
  | { type: "pop" }
  | { type: "replace"; route: Route }
  | { type: "reset"; route: Route };

function routerReducer(state: RouterState, action: RouterAction): RouterState {
  switch (action.type) {
    case "push":
      return { stack: [...state.stack, action.route] };
    case "pop":
      if (state.stack.length <= 1) return state;
      return { stack: state.stack.slice(0, -1) };
    case "replace":
      return { stack: [...state.stack.slice(0, -1), action.route] };
    case "reset":
      return { stack: [action.route] };
  }
}

export interface RouterContextValue {
  current: Route;
  navigate: (page: PageName, params?: Record<string, string>) => void;
  goBack: () => void;
  replace: (page: PageName, params?: Record<string, string>) => void;
  canGoBack: boolean;
}

const Context = createContext<RouterContextValue | null>(null);

export function RouterProvider({ children }: { children: React.ReactNode }) {
  const [state, dispatch] = useReducer(routerReducer, {
    stack: [{ page: "explore", params: {} }],
  });

  const current = state.stack[state.stack.length - 1]!;
  const canGoBack = state.stack.length > 1;

  const navigate = useCallback((page: PageName, params: Record<string, string> = {}) => {
    dispatch({ type: "push", route: { page, params } });
  }, []);

  const goBack = useCallback(() => {
    dispatch({ type: "pop" });
  }, []);

  const replace = useCallback((page: PageName, params: Record<string, string> = {}) => {
    dispatch({ type: "replace", route: { page, params } });
  }, []);

  const value = useMemo(() => ({
    current, navigate, goBack, replace, canGoBack,
  }), [current, canGoBack]);

  return <Context.Provider value={value}>{children}</Context.Provider>;
}

export function useRouter(): RouterContextValue {
  const ctx = useContext(Context);
  if (!ctx) throw new Error("useRouter must be used within RouterProvider");
  return ctx;
}
