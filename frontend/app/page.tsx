export default function Home() {
  return (
    <main className="min-h-screen bg-gradient-to-br from-gray-900 via-blue-950 to-gray-900 text-white">
      <div className="container mx-auto flex min-h-screen flex-col items-center justify-center px-4">
        <div className="z-10 max-w-5xl w-full items-center justify-center font-mono text-sm lg:flex">
          <div className="fixed bottom-0 left-0 flex h-48 w-full justify-center border-t border-white/10 bg-gradient-to-b from-transparent via-transparent via-blue-950 to-transparent lg:static lg:h-auto lg:w-auto lg:bg-none lg:border-none">
          </div>

          <div className="relative flex place-items-center before:absolute before:h-[300px] before:w-[480px] before:-translate-x-1/2 before:translate-y-1/3 before:rounded-full before:bg-blue-500/20 before:blur-3xl before:content-[''] lg:block">
          </div>

          <div className="relative flex flex-col items-center justify-center w-full">
            <h1 className="text-6xl font-bold mb-4 text-transparent bg-clip-text bg-gradient-to-r from-blue-400 to-purple-400">
              NPL MCP Server
            </h1>
            <p className="text-xl text-gray-300 mb-8 text-center">
              NoizuPromptLingo Model Context Protocol Server
            </p>
            <div className="grid grid-cols-1 md:grid-cols-3 gap-4 w-full max-w-3xl mb-8">
              <div className="bg-white/5 border border-white/10 rounded-lg p-6 hover:bg-white/10 transition-all">
                <h3 className="font-semibold mb-2 text-blue-400">MCP Tools</h3>
                <p className="text-sm text-gray-400">Access 96+ integrated tools for Markdown conversion, project management, and more.</p>
              </div>
              <div className="bg-white/5 border border-white/10 rounded-lg p-6 hover:bg-white/10 transition-all">
                <h3 className="font-semibold mb-2 text-purple-400">Chat Rooms</h3>
                <p className="text-sm text-gray-400">Event-sourced collaborative chat rooms with persona-based interactions.</p>
              </div>
              <div className="bg-white/5 border border-white/10 rounded-lg p-6 hover:bg-white/10 transition-all">
                <h3 className="font-semibold mb-2 text-pink-400">Artifacts</h3>
                <p className="text-sm text-gray-400">Versioned artifacts with review workflows and markdown support.</p>
              </div>
            </div>

            <div className="code-window bg-black/50 rounded-lg border border-white/10 p-4 w-full max-w-2xl">
              <div className="flex gap-2 mb-3">
                <div className="w-3 h-3 rounded-full bg-red-500"></div>
                <div className="w-3 h-3 rounded-full bg-yellow-500"></div>
                <div className="w-3 h-3 rounded-full bg-green-500"></div>
              </div>
              <pre className="text-sm text-green-400 overflow-x-auto">
                <code>
                  <span className="text-gray-500">$</span> npl-mcp --status <br/>
                  Server running at http://127.0.0.1:8765<br/>
                  <br/>
                  <span className="text-gray-500">$</span> npl-mcp<br/>
                  Starting NPL MCP server at http://127.0.0.1:8765/sse
                </code>
              </pre>
            </div>
          </div>
        </div>
      </div>
    </main>
  );
}