import { SessionProvider } from "next-auth/react";
import { auth } from "../auth";
import Sidebar from "../components/sidebar";
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
          <div style={{ display: "flex", minHeight: "100vh" }}>
            <Sidebar />
            <main style={{ marginLeft: "var(--sidebar-w)", flex: 1, padding: 24, overflow: "auto" }}>
              {children}
            </main>
          </div>
        </SessionProvider>
      </body>
    </html>
  );
}
