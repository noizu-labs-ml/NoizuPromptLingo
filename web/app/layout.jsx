import { SessionProvider } from "next-auth/react";
import { auth } from "../auth";
import Sidebar from "../components/sidebar";
import Topbar from "../components/topbar";
import { ProjectProvider } from "../components/project-context";
import "./globals.css";

export const metadata = {
  title: "Tobor Locker",
  description: "MCP collaboration portal",
};

export default async function RootLayout({ children }) {
  const session = await auth();
  return (
    <html lang="en">
      <body>
        <SessionProvider session={session}>
          {session ? (
            <ProjectProvider>
              <div style={{ display: "flex", minHeight: "100vh" }}>
                <Sidebar />
                <div style={{ marginLeft: "var(--sidebar-w)", flex: 1, display: "flex", flexDirection: "column" }}>
                  <Topbar />
                  <main style={{ flex: 1, padding: 24, overflow: "auto" }}>
                    {children}
                  </main>
                </div>
              </div>
            </ProjectProvider>
          ) : (
            <main>{children}</main>
          )}
        </SessionProvider>
      </body>
    </html>
  );
}
