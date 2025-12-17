export default function Home() {
  return (
    <div className="min-h-screen flex items-center justify-center">
      <div className="text-center">
        <h1 className="text-4xl font-bold text-gray-900 mb-4">
          NPL MCP Server
        </h1>
        <p className="text-xl text-gray-600 mb-8">
          Task queue management, artifacts, and collaborative chat
        </p>
        <div className="flex gap-4 justify-center">
          <a
            href="/sse"
            className="px-6 py-3 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition-colors"
          >
            SSE Endpoint
          </a>
        </div>
      </div>
    </div>
  );
}
