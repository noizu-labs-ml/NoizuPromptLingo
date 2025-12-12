"""HTML report generation for checkpoint comparisons.

Generates human-readable comparison reports with side-by-side views,
status badges, and click-to-zoom functionality.
"""

from datetime import datetime, timezone
from pathlib import Path
from typing import Optional, Dict, List, Any

from .checkpoint import (
    ComparisonResult,
    PageComparisonDetail,
    CheckpointManifest,
    get_checkpoint,
    get_screenshots_dir,
)


# HTML template with dark theme, responsive grid, and modal zoom
REPORT_TEMPLATE = '''<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Visual Comparison: {baseline_name} vs {comparison_name}</title>
    <style>
        :root {{
            --bg-primary: #0d1117;
            --bg-secondary: #161b22;
            --bg-tertiary: #21262d;
            --text-primary: #c9d1d9;
            --text-secondary: #8b949e;
            --border-color: #30363d;
            --badge-identical: #238636;
            --badge-minor: #9e6a03;
            --badge-moderate: #bd561d;
            --badge-major: #da3633;
            --badge-new: #1f6feb;
            --badge-missing: #6e7681;
        }}

        * {{
            box-sizing: border-box;
            margin: 0;
            padding: 0;
        }}

        body {{
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Helvetica, Arial, sans-serif;
            background: var(--bg-primary);
            color: var(--text-primary);
            line-height: 1.5;
            padding: 2rem;
        }}

        header {{
            margin-bottom: 2rem;
            padding-bottom: 1rem;
            border-bottom: 1px solid var(--border-color);
        }}

        h1 {{
            font-size: 1.5rem;
            font-weight: 600;
            margin-bottom: 1rem;
        }}

        .meta {{
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 1rem;
            font-size: 0.875rem;
            color: var(--text-secondary);
        }}

        .meta-item {{
            display: flex;
            flex-direction: column;
        }}

        .meta-label {{
            font-weight: 600;
            color: var(--text-primary);
            margin-bottom: 0.25rem;
        }}

        .meta-value {{
            font-family: ui-monospace, SFMono-Regular, 'SF Mono', monospace;
        }}

        .summary {{
            display: flex;
            flex-wrap: wrap;
            gap: 0.75rem;
            margin: 1.5rem 0;
            padding: 1rem;
            background: var(--bg-secondary);
            border-radius: 6px;
        }}

        .badge {{
            display: inline-flex;
            align-items: center;
            gap: 0.375rem;
            padding: 0.25rem 0.75rem;
            border-radius: 9999px;
            font-size: 0.875rem;
            font-weight: 500;
        }}

        .badge-identical {{ background: var(--badge-identical); color: white; }}
        .badge-minor {{ background: var(--badge-minor); color: white; }}
        .badge-moderate {{ background: var(--badge-moderate); color: white; }}
        .badge-major {{ background: var(--badge-major); color: white; }}
        .badge-new {{ background: var(--badge-new); color: white; }}
        .badge-missing {{ background: var(--badge-missing); color: white; }}

        .badge-count {{
            background: rgba(255,255,255,0.2);
            padding: 0.125rem 0.5rem;
            border-radius: 9999px;
            font-size: 0.75rem;
        }}

        .filters {{
            margin: 1rem 0;
            display: flex;
            gap: 0.5rem;
            flex-wrap: wrap;
        }}

        .filter-btn {{
            padding: 0.375rem 0.75rem;
            border: 1px solid var(--border-color);
            border-radius: 6px;
            background: var(--bg-secondary);
            color: var(--text-primary);
            cursor: pointer;
            font-size: 0.875rem;
            transition: all 0.15s ease;
        }}

        .filter-btn:hover {{
            background: var(--bg-tertiary);
        }}

        .filter-btn.active {{
            background: var(--badge-identical);
            border-color: var(--badge-identical);
        }}

        .page-section {{
            margin: 2rem 0;
            padding: 1.5rem;
            background: var(--bg-secondary);
            border-radius: 8px;
            border: 1px solid var(--border-color);
        }}

        .page-header {{
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 1rem;
            padding-bottom: 0.75rem;
            border-bottom: 1px solid var(--border-color);
        }}

        .page-title {{
            font-size: 1.125rem;
            font-weight: 600;
        }}

        .comparison-row {{
            display: grid;
            grid-template-columns: repeat(3, 1fr);
            gap: 1rem;
            margin: 1rem 0;
            padding: 1rem;
            background: var(--bg-tertiary);
            border-radius: 6px;
        }}

        .comparison-row.hidden {{
            display: none;
        }}

        .variant-info {{
            grid-column: 1 / -1;
            display: flex;
            align-items: center;
            gap: 0.75rem;
            margin-bottom: 0.5rem;
            font-size: 0.875rem;
        }}

        .variant-badge {{
            padding: 0.125rem 0.5rem;
            background: var(--bg-secondary);
            border: 1px solid var(--border-color);
            border-radius: 4px;
            font-size: 0.75rem;
            font-weight: 500;
        }}

        .screenshot-col {{
            display: flex;
            flex-direction: column;
        }}

        .screenshot-label {{
            font-size: 0.75rem;
            font-weight: 600;
            color: var(--text-secondary);
            margin-bottom: 0.5rem;
            text-transform: uppercase;
            letter-spacing: 0.05em;
        }}

        .screenshot-container {{
            position: relative;
            background: var(--bg-primary);
            border: 1px solid var(--border-color);
            border-radius: 4px;
            overflow: hidden;
            aspect-ratio: 16/10;
        }}

        .screenshot-container img {{
            width: 100%;
            height: 100%;
            object-fit: contain;
            cursor: pointer;
            transition: transform 0.15s ease;
        }}

        .screenshot-container img:hover {{
            transform: scale(1.02);
        }}

        .screenshot-placeholder {{
            display: flex;
            align-items: center;
            justify-content: center;
            width: 100%;
            height: 100%;
            color: var(--text-secondary);
            font-size: 0.875rem;
        }}

        .diff-percentage {{
            position: absolute;
            bottom: 0.5rem;
            right: 0.5rem;
            padding: 0.25rem 0.5rem;
            border-radius: 4px;
            font-size: 0.75rem;
            font-weight: 600;
        }}

        /* Modal */
        .modal {{
            display: none;
            position: fixed;
            inset: 0;
            background: rgba(0,0,0,0.95);
            z-index: 1000;
            justify-content: center;
            align-items: center;
            padding: 2rem;
        }}

        .modal.active {{
            display: flex;
        }}

        .modal img {{
            max-width: 95vw;
            max-height: 95vh;
            object-fit: contain;
            border-radius: 4px;
        }}

        .modal-close {{
            position: absolute;
            top: 1rem;
            right: 1rem;
            width: 2.5rem;
            height: 2.5rem;
            border: none;
            border-radius: 50%;
            background: var(--bg-tertiary);
            color: var(--text-primary);
            font-size: 1.25rem;
            cursor: pointer;
            display: flex;
            align-items: center;
            justify-content: center;
        }}

        .modal-close:hover {{
            background: var(--bg-secondary);
        }}

        @media (max-width: 768px) {{
            .comparison-row {{
                grid-template-columns: 1fr;
            }}
        }}
    </style>
</head>
<body>
    <header>
        <h1>Visual Comparison Report</h1>
        <div class="meta">
            <div class="meta-item">
                <span class="meta-label">Baseline</span>
                <span class="meta-value">{baseline_name}</span>
                <span class="meta-value" style="font-size: 0.75rem;">{baseline_commit}</span>
            </div>
            <div class="meta-item">
                <span class="meta-label">Comparison</span>
                <span class="meta-value">{comparison_name}</span>
                <span class="meta-value" style="font-size: 0.75rem;">{comparison_commit}</span>
            </div>
            <div class="meta-item">
                <span class="meta-label">Generated</span>
                <span class="meta-value">{timestamp}</span>
            </div>
        </div>
    </header>

    <section class="summary">
        <span class="badge badge-identical">Identical <span class="badge-count">{identical}</span></span>
        <span class="badge badge-minor">Minor <span class="badge-count">{minor}</span></span>
        <span class="badge badge-moderate">Moderate <span class="badge-count">{moderate}</span></span>
        <span class="badge badge-major">Major <span class="badge-count">{major}</span></span>
        <span class="badge badge-new">New <span class="badge-count">{new}</span></span>
        <span class="badge badge-missing">Missing <span class="badge-count">{missing}</span></span>
    </section>

    <div class="filters">
        <button class="filter-btn active" data-filter="all">All</button>
        <button class="filter-btn" data-filter="changes">Changes Only</button>
        <button class="filter-btn" data-filter="identical">Identical</button>
        <button class="filter-btn" data-filter="minor">Minor</button>
        <button class="filter-btn" data-filter="moderate">Moderate</button>
        <button class="filter-btn" data-filter="major">Major</button>
    </div>

    {page_sections}

    <div class="modal" id="modal" onclick="closeModal(event)">
        <button class="modal-close" onclick="closeModal(event)">&times;</button>
        <img id="modal-img" src="" alt="Full size screenshot">
    </div>

    <script>
        function openModal(img) {{
            document.getElementById('modal-img').src = img.src;
            document.getElementById('modal').classList.add('active');
            document.body.style.overflow = 'hidden';
        }}

        function closeModal(event) {{
            if (event.target.id === 'modal' || event.target.classList.contains('modal-close')) {{
                document.getElementById('modal').classList.remove('active');
                document.body.style.overflow = '';
            }}
        }}

        document.addEventListener('keydown', function(e) {{
            if (e.key === 'Escape') {{
                document.getElementById('modal').classList.remove('active');
                document.body.style.overflow = '';
            }}
        }});

        // Filter functionality
        document.querySelectorAll('.filter-btn').forEach(btn => {{
            btn.addEventListener('click', function() {{
                document.querySelectorAll('.filter-btn').forEach(b => b.classList.remove('active'));
                this.classList.add('active');

                const filter = this.dataset.filter;
                document.querySelectorAll('.comparison-row').forEach(row => {{
                    const status = row.dataset.status;
                    if (filter === 'all') {{
                        row.classList.remove('hidden');
                    }} else if (filter === 'changes') {{
                        row.classList.toggle('hidden', status === 'identical');
                    }} else {{
                        row.classList.toggle('hidden', status !== filter);
                    }}
                }});
            }});
        }});
    </script>
</body>
</html>'''


PAGE_SECTION_TEMPLATE = '''
    <section class="page-section">
        <div class="page-header">
            <h2 class="page-title">{page_name}</h2>
        </div>
        {comparison_rows}
    </section>
'''


COMPARISON_ROW_TEMPLATE = '''
        <div class="comparison-row" data-status="{status}">
            <div class="variant-info">
                <span class="variant-badge">{viewport}</span>
                <span class="variant-badge">{theme}</span>
                <span class="badge badge-{status}">{status_label} <span class="badge-count">{diff_pct}%</span></span>
            </div>
            <div class="screenshot-col">
                <span class="screenshot-label">Baseline</span>
                <div class="screenshot-container">
                    {baseline_img}
                </div>
            </div>
            <div class="screenshot-col">
                <span class="screenshot-label">Comparison</span>
                <div class="screenshot-container">
                    {comparison_img}
                </div>
            </div>
            <div class="screenshot-col">
                <span class="screenshot-label">Diff</span>
                <div class="screenshot-container">
                    {diff_img}
                </div>
            </div>
        </div>
'''


def _format_commit(commit: Optional[str]) -> str:
    """Format git commit for display."""
    if not commit:
        return "N/A"
    return commit[:8]


def _format_timestamp(timestamp: str) -> str:
    """Format ISO timestamp for display."""
    try:
        dt = datetime.fromisoformat(timestamp.replace('Z', '+00:00'))
        return dt.strftime("%Y-%m-%d %H:%M UTC")
    except Exception:
        return timestamp


def _img_tag(path: Optional[str], alt: str) -> str:
    """Generate img tag or placeholder."""
    if not path:
        return f'<div class="screenshot-placeholder">{alt}</div>'
    # Use relative path from report location
    return f'<img src="{path}" alt="{alt}" onclick="openModal(this)">'


async def generate_comparison_report(
    result: ComparisonResult,
    baseline: CheckpointManifest,
    comparison: CheckpointManifest,
    base_dir: Optional[Path] = None,
) -> str:
    """Generate HTML comparison report.

    Args:
        result: ComparisonResult from compare_checkpoints
        baseline: Baseline checkpoint manifest
        comparison: Comparison checkpoint manifest
        base_dir: Base directory for screenshots

    Returns:
        Path to generated HTML report
    """
    screenshots_dir = get_screenshots_dir(base_dir)

    # Group details by page
    pages: Dict[str, List[PageComparisonDetail]] = {}
    for detail in result.details:
        if detail.page not in pages:
            pages[detail.page] = []
        pages[detail.page].append(detail)

    # Generate page sections
    page_sections = []
    for page_name in sorted(pages.keys()):
        details = pages[page_name]

        # Generate comparison rows
        rows = []
        for detail in sorted(details, key=lambda d: (d.viewport, d.theme)):
            status_label = detail.status.capitalize()
            diff_pct = f"{detail.diff_percentage:.2f}" if detail.diff_percentage < 100 else "100"

            # Build image paths relative to report location
            baseline_img = _img_tag(detail.baseline_path, "Not in baseline")
            comparison_img = _img_tag(detail.comparison_path, "Not in comparison")
            diff_img = _img_tag(detail.diff_path, "No diff available")

            row = COMPARISON_ROW_TEMPLATE.format(
                status=detail.status,
                viewport=detail.viewport,
                theme=detail.theme,
                status_label=status_label,
                diff_pct=diff_pct,
                baseline_img=baseline_img,
                comparison_img=comparison_img,
                diff_img=diff_img,
            )
            rows.append(row)

        section = PAGE_SECTION_TEMPLATE.format(
            page_name=page_name,
            comparison_rows='\n'.join(rows),
        )
        page_sections.append(section)

    # Generate full HTML
    html = REPORT_TEMPLATE.format(
        baseline_name=baseline.name,
        comparison_name=comparison.name,
        baseline_commit=_format_commit(baseline.git_commit),
        comparison_commit=_format_commit(comparison.git_commit),
        timestamp=_format_timestamp(result.timestamp),
        identical=result.summary.get("identical", 0),
        minor=result.summary.get("minor", 0),
        moderate=result.summary.get("moderate", 0),
        major=result.summary.get("major", 0),
        new=result.summary.get("new", 0),
        missing=result.summary.get("missing", 0),
        page_sections='\n'.join(page_sections),
    )

    # Write report
    report_path = screenshots_dir / "comparison.html"
    with open(report_path, 'w') as f:
        f.write(html)

    return str(report_path)
