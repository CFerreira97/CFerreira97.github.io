# vscode/

VS Code project config for Python projects, migrated from `default` (the user's now-retired
personal template repo)'s `.vscode/`. Already generic as written (uses `${workspaceFolder}`
throughout, no hardcoded package name) — pull byte-for-byte, no `<pkg>` find/replace needed.

```
xorgentic pull tools/vscode/ --to .vscode/
```

- `extensions.json` — recommended-extensions list (VS Code's "Recommended" tab in the
  Extensions view). **Note:** `default`'s copy was named `extension.json` (no `s`), which VS
  Code does not recognize — recommendations silently never showed up there. Named correctly
  here.
- `settings.json` — Python interpreter path, `.env` loading, `src` on the analysis path,
  pytest as the test runner.
