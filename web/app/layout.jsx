import { SessionProvider } from "next-auth/react";
import { auth } from "../auth";

export const metadata = {
  title: "Hello World MCP",
  description: "A hello-world MCP server with a Next.js frontend",
};

export default async function RootLayout({ children }) {
  const session = await auth();
  return (
    <html lang="en">
      <body>
        <SessionProvider session={session}>{children}</SessionProvider>
      </body>
    </html>
  );
}
