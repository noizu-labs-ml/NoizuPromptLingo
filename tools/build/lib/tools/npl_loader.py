from pathlib import Path

import yaml


def load_yaml_file(path: Path) -> dict | None:
    """Load a single YAML file"""
    if path.exists():
        with open(path, "r") as f:
            return yaml.safe_load(f)
    return None


def load_yaml_files() -> dict[str, dict]:
    """Load all YAML files from ~/.npl/npl/"""
    npl_home = Path.home() / ".npl" / "npl"

    files = {
        "npl": npl_home / "npl.yaml",
        "syntax": npl_home / "syntax.yaml",
    }

    data = {}
    for name, path in files.items():
        content = load_yaml_file(path)
        if content:
            data[name] = content

    return data


def format_npl_output(data: dict[str, dict]) -> str:
    """Format the YAML data to look similar to npl.md"""
    lines = []

    # Header
    lines.append("\u231cNPL@1.0\u231d")
    lines.append("# Noizu Prompt Lingua (NPL)")

    # Description from npl.yaml
    npl_data = data.get("npl")
    if npl_data and "npl" in npl_data:
        npl = npl_data["npl"]
        if "description" in npl:
            lines.append(npl["description"].strip())
        lines.append("")
        lines.append("**Convention**: Additional details and deep-dive instructions are available under `${NPL_HOME}/npl/` and can be loaded on an as-needed basis.")
        lines.append("")

        # Core Concepts
        if "concepts" in npl:
            lines.append("## Core Concepts")
            lines.append("")
            for concept in npl["concepts"]:
                name = concept.get("name", "")
                desc = concept.get("description", "").strip()
                # First line of description
                first_line = desc.split("\n")[0] if desc else ""
                lines.append(f"**{name}**")
                lines.append(f": {first_line}")
                lines.append("")

    # Essential Syntax from syntax.yaml
    syntax_data = data.get("syntax")
    if syntax_data and "components" in syntax_data:
        lines.append("## Essential Syntax")
        lines.append("")

        for component in syntax_data["components"]:
            name = component.get("name", "")
            brief = component.get("brief", "")
            syntax_list = component.get("syntax", [])

            lines.append(f"### {name}")
            if brief:
                lines.append(brief)
            lines.append("")

            if syntax_list:
                syntax_strs = [s.get("syntax", "") for s in syntax_list if s.get("syntax")]
                if syntax_strs:
                    lines.append("**syntax:** " + ", ".join(f"`{s}`" for s in syntax_strs))
                    lines.append("")

    # Footer
    lines.append("\u231eNPL@1.0\u231f")

    return "\n".join(lines)


def main():
    data = load_yaml_files()

    if not data:
        print("Error: Could not find any YAML files in ~/.npl/npl/")
        return

    output = format_npl_output(data)
    print(output)


if __name__ == "__main__":
    main()
