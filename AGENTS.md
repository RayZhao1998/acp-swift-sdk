# Repository Guidelines

## Project Structure & Module Organization
- Swift package (`Package.swift`) with library target `ACP` under `Sources/ACP` and CLI example target `Example` under `Sources/Example`.
- Core modules: protocol definitions and helpers in `Sources/ACP/Base`, agent-side interfaces in `Sources/ACP/Agent`, and client-side plumbing in `Sources/ACP/Client`.
- Tests live in `Tests/ACPTests`, using async integration checks against a running ACP agent.
- Protocol JSON schemas are stored in `schema/` for reference and regeneration.

## Build, Test, and Development Commands
- `swift build` — compile all targets.
- `swift test` — run the test suite; requires a runnable ACP agent (`kimi --acp` or `ACP_AGENT_BIN`) to avoid skipped assertions.
- `swift run Example` — launch the sample client and connect to the configured agent.
- When formatting is available, run `swift format --in-place --recursive Sources Tests` to apply `.swift-format` rules.

## Coding Style & Naming Conventions
- Follow `.swift-format`: 2-space indentation, 100-character max line length, ordered imports, one declaration per line, trailing commas for multi-line collections.
- Swift API naming: `UpperCamelCase` for types, `lowerCamelCase` for functions/properties, no semicolons, prefer early exits, and avoid force unwrap/try unless justified.
- Keep public-facing types documented; internal helpers can be light on comments but maintain clarity through naming.

## Testing Guidelines
- Frameworks: `Testing` with async tests.
- Integration tests expect an ACP-compatible agent on the host. Provide `ACP_AGENT_BIN=/path/to/agent --acp` if `kimi` is not on PATH; otherwise tests record an `Issue` and skip work.
- Name tests after behaviors (`connectsToKimiAgent`) and group with `@Suite` annotations. Add fixtures under `Tests/ACPTests` alongside the test file.

## Commit & Pull Request Guidelines
- Commit history uses Conventional Commit prefixes (`feat:`, `refactor:`, `feat(schema):`). Match this style and keep messages concise.
- Pull requests: include a clear summary, mention protocol or schema updates, link related issues, and add screenshots or logs only when UI/CLI output is relevant.
- Ensure new code is formatted, tests pass, and any agent/test environment requirements are documented in the PR description.

## Security & Configuration Tips
- Do not hardcode secrets or API tokens. Prefer environment variables and document any required values (e.g., `ACP_AGENT_BIN`, working directories).
- When invoking external CLIs (e.g., `kimi`), validate availability before running and fail with actionable messages.
