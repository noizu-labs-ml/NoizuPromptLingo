defmodule NoizuPromptLingua.Domains.MarkdownTest do
  use ExUnit.Case, async: true

  alias NoizuPromptLingua.Domains.Markdown

  @doc """
  Loopback stub server used to exercise `convert/2` URL fetching without any
  external network. Req 0.5 has no injectable adapter in `Req.get/2` (the
  module calls it directly), so the honest seam is a real HTTP server on
  127.0.0.1 with deterministic per-path responses.
  """
  defmodule StubServer do
    @behaviour Plug

    @html """
    <html>
      <head><title>Ignored Title</title><style>.x{color:red}</style></head>
      <body>
        <h1>Stub Heading</h1>
        <p>Hello <strong>brave</strong> <em>world</em>.</p>
        <a href="/next">Next</a>
        <script>alert('pwn')</script>
      </body>
    </html>
    """

    @impl true
    def init(opts), do: opts

    @impl true
    def call(%Plug.Conn{path_info: ["html"]} = conn, _opts) do
      conn
      |> Plug.Conn.put_resp_content_type("text/html")
      |> Plug.Conn.send_resp(200, @html)
    end

    # A 2xx with a JSON body: Req auto-decodes it to a map, exercising the
    # `html = if is_binary(body), do: body, else: inspect(body)` fallback.
    def call(%Plug.Conn{path_info: ["json"]} = conn, _opts) do
      conn
      |> Plug.Conn.put_resp_content_type("application/json")
      |> Plug.Conn.send_resp(200, ~s({"ok": true, "note": "not html"}))
    end

    def call(%Plug.Conn{path_info: ["boom"]} = conn, _opts),
      do: Plug.Conn.send_resp(conn, 503, "service unavailable")

    def call(conn, _opts), do: Plug.Conn.send_resp(conn, 404, "not found")
  end

  setup_all do
    {:ok, listener} = :gen_tcp.listen(0, [:binary, active: false, ip: {127, 0, 0, 1}])
    {:ok, port} = :inet.port(listener)
    :gen_tcp.close(listener)

    {:ok, pid} = Bandit.start_link(plug: StubServer, port: port, ip: {127, 0, 0, 1})
    on_exit(fn -> Process.exit(pid, :kill) end)

    %{base: "http://127.0.0.1:#{port}"}
  end

  # ── convert/2 — type inference & dispatch ────────────────────────────────

  describe "convert/2 — type inference & dispatch" do
    test "passthrough for plain markdown (explicit type)" do
      assert {:ok, %{markdown: "# Hi", source_type: :markdown, via: :passthrough}} =
               Markdown.convert("# Hi", type: :markdown)
    end

    test "passthrough inferred for plain text" do
      assert {:ok, %{markdown: "just some words", source_type: :markdown, via: :passthrough}} =
               Markdown.convert("just some words")
    end

    test "html detected and converted when inferred" do
      assert {:ok, %{markdown: md, source_type: :html, via: :floki}} =
               Markdown.convert("<p>auto html</p>")

      assert md == "auto html"
    end

    test "html honored when forced" do
      assert {:ok, %{source_type: :html, via: :floki}} =
               Markdown.convert("<p>forced</p>", type: :html)
    end

    test "url inferred for http(s) strings (including surrounding whitespace)", %{base: base} do
      assert {:ok, %{source_type: :url, via: :floki, markdown: md}} =
               Markdown.convert("  #{base}/html  ")

      assert md =~ "# Stub Heading"
    end

    test "url fetch error surfaces as {:error, reason}", %{base: base} do
      assert {:error, "Fetch failed: HTTP 503"} = Markdown.convert("#{base}/boom", type: :url)
    end

    test "url fetch transport failure surfaces as {:error, reason}" do
      # Port 1 on loopback: connection refused, deterministic, no network.
      assert {:error, "Fetch failed: " <> _detail} =
               Markdown.convert("http://127.0.0.1:1/", type: :url)
    end

    test "url with non-binary (decoded JSON) body falls back to inspect", %{base: base} do
      assert {:ok, %{source_type: :url, via: :floki, markdown: md}} =
               Markdown.convert("#{base}/json", type: :url)

      assert md =~ "not html"
    end

    test "unknown type raises (no silent fallback)" do
      assert_raise FunctionClauseError, fn -> Markdown.convert("x", type: :bogus) end
    end

    test "non-binary source is rejected by guard" do
      assert_raise FunctionClauseError, fn -> Markdown.convert(nil) end
    end

    test "empty string passes through as empty markdown" do
      assert {:ok, %{markdown: "", source_type: :markdown, via: :passthrough}} =
               Markdown.convert("")
    end

    test "unicode markdown passes through untouched" do
      assert {:ok, %{markdown: "café — ⌜NPL@1.0⌝ ✓", source_type: :markdown}} =
               Markdown.convert("café — ⌜NPL@1.0⌝ ✓")
    end

    test "huge passthrough input does not crash" do
      big = String.duplicate("word ", 200_000)
      assert {:ok, %{markdown: ^big}} = Markdown.convert(big)
    end
  end

  # ── html_to_markdown/1 ───────────────────────────────────────────────────

  describe "html_to_markdown/1 — headings & blocks" do
    test "h1 through h6 map to ATX headings" do
      html = "<h1>one</h1><h2>two</h2><h3>three</h3><h4>four</h4><h5>five</h5><h6>six</h6>"
      md = Markdown.html_to_markdown(html)

      assert md =~ "# one"
      assert md =~ "## two"
      assert md =~ "### three"
      assert md =~ "#### four"
      assert md =~ "##### five"
      assert md =~ "###### six"
    end

    test "adjacent paragraphs collapse to double newlines" do
      assert Markdown.html_to_markdown("<p>a</p><p>b</p>") == "a\n\nb"
    end

    test "hr renders a horizontal rule" do
      assert Markdown.html_to_markdown("<hr>") == "---"
    end

    test "br collapses inside inline context" do
      assert Markdown.html_to_markdown("<p>a<br>b</p>") == "a b"
    end

    test "blockquote quotes every line" do
      md = Markdown.html_to_markdown("<blockquote><p>line1</p><p>line2</p></blockquote>")

      # Blank lines between paragraphs are quoted as-is (no blank-collapse
      # inside the blockquote walk).
      assert md == "> line1\n> \n> \n> \n> line2"
    end
  end

  describe "html_to_markdown/1 — inline elements" do
    test "strong and b render bold" do
      assert Markdown.html_to_markdown("<p><strong>a</strong></p>") == "**a**"
      assert Markdown.html_to_markdown("<p><b>b</b></p>") == "**b**"
    end

    test "em and i render italic" do
      assert Markdown.html_to_markdown("<p><em>a</em></p>") == "_a_"
      assert Markdown.html_to_markdown("<p><i>b</i></p>") == "_b_"
    end

    test "inline code stays inline; multiline code becomes a fenced block" do
      assert Markdown.html_to_markdown("<code>foo()</code>") == "`foo()`"
      assert Markdown.html_to_markdown("<code>a\nb</code>") == "```\na\nb\n```"
    end

    test "pre renders a fenced block" do
      assert Markdown.html_to_markdown("<pre>x = 1</pre>") == "```\nx = 1\n```"
    end

    test "runs of whitespace collapse inside inline text" do
      assert Markdown.html_to_markdown("<p>  a \t b  </p>") == "a b"
    end
  end

  describe "html_to_markdown/1 — links & images" do
    test "link with href renders markdown link" do
      assert Markdown.html_to_markdown("<a href=\"https://x.example\">link</a>") ==
               "[link](https://x.example)"
    end

    test "link without href renders bare label" do
      assert Markdown.html_to_markdown("<a>label</a>") == "label"
    end

    test "empty link renders nothing" do
      assert Markdown.html_to_markdown("<a href=\"https://x.example\"></a>") == ""
    end

    test "image with src renders markdown image" do
      assert Markdown.html_to_markdown("<img src=\"a.png\" alt=\"Alt\">") == "![Alt](a.png)"
    end

    test "image without src renders nothing" do
      assert Markdown.html_to_markdown("<img alt=\"orphan\">") == ""
    end

    test "hrefs are passed through verbatim (converter, not sanitizer)" do
      # By design this is a converter, not a URL sanitizer — callers must treat
      # output as untrusted. Pin the current contract.
      assert Markdown.html_to_markdown("<a href=\"javascript:alert(1)\">x</a>") ==
               "[x](javascript:alert(1))"
    end
  end

  describe "html_to_markdown/1 — lists" do
    test "unordered list" do
      assert Markdown.html_to_markdown("<ul><li>one</li><li>two</li></ul>") == "- one\n- two"
    end

    test "ordered list numbers items" do
      assert Markdown.html_to_markdown("<ol><li>a</li><li>b</li></ol>") == "1. a\n2. b"
    end

    test "non-li children of lists are ignored" do
      assert Markdown.html_to_markdown("<ul>stray<li>kept</li></ul>") == "- kept"
    end
  end

  describe "html_to_markdown/1 — structure & noise" do
    test "unknown/structural tags render their children transparently" do
      assert Markdown.html_to_markdown("<div><span>nested</span></div>") == "nested"
    end

    test "table renders a GFM table" do
      html = "<table><tr><th>A</th><th>B</th></tr><tr><td>1</td><td>2</td></tr></table>"

      assert Markdown.html_to_markdown(html) == """
             | A | B |
             | --- | --- |
             | 1 | 2 |\
             """
    end

    test "table with no cell rows renders empty" do
      assert Markdown.html_to_markdown("<table></table>") == ""
    end

    test "script/style/noscript/template/svg/iframe/head are dropped" do
      html = """
      <html>
        <head><title>gone</title></head>
        <body>
          <script>evil()</script><style>.x{}</style>
          <noscript>gone</noscript><template>gone</template>
          <svg><circle/></svg><iframe src="https://evil.example"></iframe>
          <p>kept</p>
        </body>
      </html>
      """

      md = Markdown.html_to_markdown(html)
      assert md == "kept"
      refute md =~ "evil"
      refute md =~ "gone"
    end

    test "HTML comments are stripped" do
      assert Markdown.html_to_markdown("<!-- secret --><p>visible</p>") == "visible"
    end

    test "content outside body is dropped via body extraction" do
      md = Markdown.html_to_markdown("<body><p>inside</p></body>")
      assert md == "inside"
    end

    test "empty and unicode input are handled" do
      assert Markdown.html_to_markdown("") == ""
      assert Markdown.html_to_markdown("<p>café ✓</p>") == "café ✓"
    end
  end

  # ── view/2 ────────────────────────────────────────────────────────────────

  @sample_doc """
  Preamble line.

  # Intro
  intro body

  ## Alpha
  alpha body
  ### Alpha Deep
  deep body

  ## Beta
  beta body
  """

  describe "view/2 — filtering" do
    test "no filter returns full document and counts headings" do
      assert {:ok, %{markdown: md, matched: 4}} = Markdown.view(@sample_doc)
      assert md =~ "# Intro"
      assert md =~ "deep body"
      assert md =~ "Preamble line."
    end

    test "bare name filter extracts the matched section only" do
      assert {:ok, %{markdown: md, matched: 1}} =
               Markdown.view(@sample_doc, filter: "Alpha", bare: true)

      assert md == "## Alpha\nalpha body"
    end

    test "bare: \"true\" (string) behaves like true" do
      assert {:ok, %{markdown: md}} =
               Markdown.view(@sample_doc, filter: "Alpha", bare: "true")

      assert md == "## Alpha\nalpha body"
    end

    test "non-bare filter keeps preamble and collapses unmatched sections" do
      assert {:ok, %{markdown: md, matched: 1}} = Markdown.view(@sample_doc, filter: "Alpha")

      # The preamble holds the blank line before "# Intro", hence the triple
      # newline before the first heading.
      assert md == """
             Preamble line.


             # Intro 📦

             ## Alpha
             alpha body

             ### Alpha Deep 📦

             ## Beta 📦\
             """
    end

    test "path selector matches on the last segment only" do
      # NOTE: the implementation matches only the final path segment ("tail"
      # matching); the ancestor segments are cosmetic. Pin that contract.
      assert {:ok, %{matched: 1, markdown: md}} =
               Markdown.view(@sample_doc, filter: "Irrelevant > Alpha Deep", bare: true)

      assert md == "### Alpha Deep\ndeep body"
    end

    test "star path selector matches every heading (documented quirk)" do
      assert {:ok, %{matched: 4}} = Markdown.view(@sample_doc, filter: "Alpha > *", bare: true)
    end

    test "level selector h2 matches all level-2 headings, case-insensitively" do
      assert {:ok, %{matched: 2}} = Markdown.view(@sample_doc, filter: "h2", bare: true)
      assert {:ok, %{matched: 2}} = Markdown.view(@sample_doc, filter: "H2", bare: true)
    end

    test "filter with no matches returns matched: 0" do
      assert {:ok, %{markdown: "", matched: 0}} =
               Markdown.view(@sample_doc, filter: "Nope", bare: true)
    end

    test "unicode headings slug-match their filters" do
      doc = "# Café Notes\nbody here"

      assert {:ok, %{markdown: md, matched: 1}} =
               Markdown.view(doc, filter: "café notes", bare: true)

      assert md == "# Café Notes\nbody here"
    end

    test "seven hashes is not a heading" do
      assert {:ok, %{matched: 0}} = Markdown.view("####### seven", bare: true)
    end

    test "empty markdown yields an empty view" do
      assert {:ok, %{markdown: "", matched: 0}} = Markdown.view("")
    end
  end

  describe "view/2 — depth collapsing" do
    test "depth collapses headings deeper than the limit" do
      assert {:ok, %{markdown: md}} = Markdown.view(@sample_doc, depth: 1)

      assert md == """
             Preamble line.


             # Intro
             intro body

             ## Alpha 📦

             ### Alpha Deep 📦

             ## Beta 📦\
             """
    end

    test "depth accepts a string level" do
      assert {:ok, %{markdown: md}} = Markdown.view(@sample_doc, depth: "2")
      refute md =~ "deep body"
      assert md =~ "alpha body"
    end

    test "filter_inner_depth collapses matched sections deeper than the inner limit" do
      assert {:ok, %{markdown: md, matched: 1}} =
               Markdown.view(@sample_doc, filter: "Alpha Deep", bare: true, filter_inner_depth: 2)

      # Matched but deeper than the inner limit → collapsed anyway.
      assert md == "### Alpha Deep 📦"
    end

    test "filter_inner_depth leaves matched sections within the limit intact" do
      assert {:ok, %{markdown: md}} =
               Markdown.view(@sample_doc, filter: "Alpha Deep", bare: true, filter_inner_depth: 3)

      assert md == "### Alpha Deep\ndeep body"
    end

    test "depth beyond 6 collapses nothing" do
      assert {:ok, %{markdown: md}} = Markdown.view(@sample_doc, depth: 6)
      assert md =~ "deep body"
    end
  end

  describe "view/2 — edge cases" do
    test "document with only a preamble has no heading matches" do
      assert {:ok, %{markdown: "just prose", matched: 0}} = Markdown.view("just prose")
    end

    test "empty heading bodies render as bare headings" do
      assert {:ok, %{markdown: "# Solo", matched: 1}} = Markdown.view("# Solo", bare: true)
    end
  end
end
