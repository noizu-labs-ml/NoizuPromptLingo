# CI/CD Patterns for MCP Servers

Pipeline patterns for building, testing, and deploying MCP servers via GitHub Actions.

## Standard Pipeline: Lint --> Test --> Build --> Docker --> Publish

### GitHub Actions Workflow (TypeScript)

```yaml
# .github/workflows/ci.yml
name: CI/CD

on:
  push:
    branches: [main]
    tags: ["v*"]
  pull_request:
    branches: [main]

permissions:
  contents: read
  packages: write

jobs:
  lint:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: 22
          cache: npm
      - run: npm ci
      - run: npm run typecheck
      - run: npm run lint

  test:
    runs-on: ubuntu-latest
    needs: lint
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: 22
          cache: npm
      - run: npm ci
      - run: npm run test:coverage
      - uses: actions/upload-artifact@v4
        with:
          name: coverage
          path: coverage/

  build:
    runs-on: ubuntu-latest
    needs: test
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: 22
          cache: npm
      - run: npm ci
      - run: npm run build
      - uses: actions/upload-artifact@v4
        with:
          name: dist
          path: dist/

  docker:
    runs-on: ubuntu-latest
    needs: build
    if: github.ref == 'refs/heads/main' || startsWith(github.ref, 'refs/tags/v')
    steps:
      - uses: actions/checkout@v4
      - uses: docker/setup-buildx-action@v3
      - uses: docker/login-action@v3
        with:
          registry: ghcr.io
          username: ${{ github.actor }}
          password: ${{ secrets.GITHUB_TOKEN }}
      - uses: docker/metadata-action@v5
        id: meta
        with:
          images: ghcr.io/${{ github.repository }}
          tags: |
            type=sha,prefix=
            type=semver,pattern={{version}}
            type=semver,pattern={{major}}.{{minor}}
            type=raw,value=latest,enable={{is_default_branch}}
      - uses: docker/build-push-action@v6
        with:
          context: .
          push: true
          tags: ${{ steps.meta.outputs.tags }}
          labels: ${{ steps.meta.outputs.labels }}
          cache-from: type=gha
          cache-to: type=gha,mode=max

  publish-npm:
    runs-on: ubuntu-latest
    needs: [build, docker]
    if: startsWith(github.ref, 'refs/tags/v')
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: 22
          registry-url: "https://npm.pkg.github.com"
      - run: npm ci
      - run: npm run build
      - run: npm publish
        env:
          NODE_AUTH_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

### GitHub Actions Workflow (Python)

```yaml
# .github/workflows/ci.yml
name: CI/CD

on:
  push:
    branches: [main]
    tags: ["v*"]
  pull_request:
    branches: [main]

permissions:
  contents: read
  packages: write

jobs:
  lint:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-python@v5
        with:
          python-version: "3.12"
      - run: pip install ruff
      - run: ruff check src/ tests/
      - run: ruff format --check src/ tests/

  test:
    runs-on: ubuntu-latest
    needs: lint
    strategy:
      matrix:
        python-version: ["3.11", "3.12", "3.13"]
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-python@v5
        with:
          python-version: ${{ matrix.python-version }}
      - run: pip install -e ".[dev]"
      - run: pytest --cov --cov-report=xml
      - uses: actions/upload-artifact@v4
        if: matrix.python-version == '3.12'
        with:
          name: coverage
          path: coverage.xml

  docker:
    runs-on: ubuntu-latest
    needs: test
    if: github.ref == 'refs/heads/main' || startsWith(github.ref, 'refs/tags/v')
    steps:
      - uses: actions/checkout@v4
      - uses: docker/setup-buildx-action@v3
      - uses: docker/login-action@v3
        with:
          registry: ghcr.io
          username: ${{ github.actor }}
          password: ${{ secrets.GITHUB_TOKEN }}
      - uses: docker/metadata-action@v5
        id: meta
        with:
          images: ghcr.io/${{ github.repository }}
          tags: |
            type=sha,prefix=
            type=semver,pattern={{version}}
            type=raw,value=latest,enable={{is_default_branch}}
      - uses: docker/build-push-action@v6
        with:
          context: .
          push: true
          tags: ${{ steps.meta.outputs.tags }}
          labels: ${{ steps.meta.outputs.labels }}
          cache-from: type=gha
          cache-to: type=gha,mode=max

  publish-pypi:
    runs-on: ubuntu-latest
    needs: [test, docker]
    if: startsWith(github.ref, 'refs/tags/v')
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-python@v5
        with:
          python-version: "3.12"
      - run: pip install build twine
      - run: python -m build
      - run: twine upload dist/*
        env:
          TWINE_USERNAME: __token__
          TWINE_PASSWORD: ${{ secrets.PYPI_TOKEN }}
```

## Version Tagging Strategy

### Git Tag to Package Version

```bash
# Tag a release
git tag v1.2.3
git push origin v1.2.3
```

The CI pipeline extracts the version from the git tag:
- `v1.2.3` --> npm/PyPI version `1.2.3`
- `v1.2.3` --> Docker tags: `1.2.3`, `1.2`, `latest`

### Semantic Release (Automated)

For automated versioning based on commit messages:

```yaml
# .github/workflows/release.yml
name: Release

on:
  push:
    branches: [main]

permissions:
  contents: write
  packages: write

jobs:
  release:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0
      - uses: actions/setup-node@v4
        with:
          node-version: 22
      - run: npx semantic-release
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
          NPM_TOKEN: ${{ secrets.NPM_TOKEN }}
```

Commit convention:
- `feat:` --> minor version bump
- `fix:` --> patch version bump
- `feat!:` or `BREAKING CHANGE:` --> major version bump

## Docker Image Tagging

| Trigger | Tags Generated |
|---|---|
| Push to main | `latest`, `sha-abc1234` |
| Tag v1.2.3 | `1.2.3`, `1.2`, `latest`, `sha-abc1234` |
| PR | None (build only, no push) |

## Environment-Specific Deployments

```yaml
# .github/workflows/deploy.yml
name: Deploy

on:
  workflow_dispatch:
    inputs:
      environment:
        description: "Target environment"
        required: true
        type: choice
        options: [dev, staging, prod]
      image_tag:
        description: "Docker image tag to deploy"
        required: true

jobs:
  deploy:
    runs-on: ubuntu-latest
    environment: ${{ inputs.environment }}
    steps:
      - uses: actions/checkout@v4
      - name: Deploy to ${{ inputs.environment }}
        run: |
          echo "Deploying ghcr.io/${{ github.repository }}:${{ inputs.image_tag }}"
          echo "Target: ${{ inputs.environment }}"
          # Replace with your deployment mechanism:
          # kubectl, helm, docker compose, etc.
```

## MCP-Specific CI: Protocol Conformance Tests

Add a dedicated job that validates the server speaks valid MCP protocol:

```yaml
  protocol-conformance:
    runs-on: ubuntu-latest
    needs: build
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: 22
          cache: npm
      - run: npm ci
      - run: npm run build
      - name: Protocol conformance test
        run: |
          # Start server in background
          node dist/server.js &
          SERVER_PID=$!
          sleep 2

          # Send initialize request via stdio
          echo '{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2025-03-26","capabilities":{},"clientInfo":{"name":"ci-test","version":"1.0.0"}}}' | timeout 5 node dist/server.js | head -1 > response.json

          # Validate response has required fields
          node -e "
            const r = JSON.parse(require('fs').readFileSync('response.json','utf8'));
            if (!r.result?.protocolVersion) throw new Error('Missing protocolVersion');
            if (!r.result?.capabilities) throw new Error('Missing capabilities');
            if (!r.result?.serverInfo) throw new Error('Missing serverInfo');
            console.log('Protocol conformance: PASS');
          "

          kill $SERVER_PID 2>/dev/null || true
```

## Release Automation with Changesets

For monorepo or multi-package setups:

```json
// .changeset/config.json
{
  "$schema": "https://unpkg.com/@changesets/config/schema.json",
  "changelog": "@changesets/cli/changelog",
  "commit": false,
  "access": "restricted",
  "baseBranch": "main"
}
```

```yaml
# .github/workflows/changeset-release.yml
name: Release

on:
  push:
    branches: [main]

jobs:
  release:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: 22
      - run: npm ci
      - uses: changesets/action@v1
        with:
          publish: npm run publish
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
          NPM_TOKEN: ${{ secrets.NPM_TOKEN }}
```

## Best Practices

1. **Cache aggressively.** Use `actions/cache` or built-in `cache` options for npm/pip, Docker layers, and build artifacts.
2. **Fail fast.** Lint before test. Test before build. Build before Docker. Each step gates the next.
3. **Test on multiple runtimes.** Use a matrix strategy for Python (3.11, 3.12, 3.13) or Node.js (20, 22) to catch compatibility issues.
4. **Never push Docker images from PRs.** Build-only on PRs. Push on main and tags.
5. **Pin action versions.** Use `@v4` not `@main` for third-party actions.
6. **Use OIDC for deployments.** Avoid long-lived credentials where possible. Use GitHub's OIDC provider for cloud deployments.
