# mdless-cli

CLI tools for Claude Code developers.

## Development

This project uses Bun. In development, `bin.mjs` runs the TypeScript in `src/` directly with `tsx`, so there is no build step. The published package is different: `bun run build` bundles `src/` and all dependencies into one file, `dist/index.js`, and the package `bin` points to it. The package has no runtime dependencies, so `npx @mdless/cli@latest` starts fast.

Files that the CLI reads at runtime (`assets/*.mp3`, `src/agents/prompts/`) are found from `PACKAGE_ROOT` in `src/paths.ts`. Keep `src/paths.ts` directly in `src/`, and add new runtime files to `files` in `package.json`.

### Setup

Symlink the CLI into a directory on your `PATH` that is **not** tied to a Node version. `npm link` installs into the *current* Node version's global bin, so with `nvm`/`.nvmrc` the `mdless` command vanishes the moment you `cd` into a project pinned to a different Node version. A plain symlink avoids that:

```bash
mkdir -p ~/.local/bin              # ensure the dir exists and is on your PATH
ln -sf "$(pwd)/bin.mjs" ~/.local/bin/mdless
```

`bin.mjs` runs under whatever Node is active and resolves `tsx` + `src/` by its own path, so `mdless` works from any folder under any Node version.

### Testing

After making changes, test by running `mdless` in any terminal - changes are reflected immediately.

Checks (CI runs all of them on every pull request and before every release):

```bash
bun run typecheck   # tsc --noEmit
bun run test        # bun test
bun run build       # bundle src/ into dist/index.js
bun run smoke       # npm pack, install the tarball in a temp folder, run mdless --version, init and agent
```

`bun run smoke` uses a fake `claude` command, so it costs nothing.

Unit tests use `bun test`. Test files sit next to the code they test, as `*.test.ts`.

### Documentation

Always update `README.md` after changing the code, so the docs and behavior stay in sync.

Always update `FEATURES.md` when you add, change, or remove a feature. It lists all features in plain English.

### Releasing

Do not publish by hand. Every push to `main` (eg a merged pull request) runs `.github/workflows/publish.yml`. It runs the checks above. If they pass, semantic-release reads the commit messages since the last release and picks the next version:

| Commit                                            | Release                  |
| ------------------------------------------------- | ------------------------ |
| `fix: ...`, `perf: ...`                           | patch (1.2.3 -> 1.2.4)   |
| `feat: ...`                                       | minor (1.2.3 -> 1.3.0)   |
| `feat!: ...`, or a `BREAKING CHANGE:` footer      | major (1.2.3 -> 2.0.0)   |
| `chore:`, `docs:`, `refactor:`, `test:`, `ci:`    | no release               |

The highest one wins: a merge with one `feat:` and three `fix:` commits gives a minor. The type must be in lowercase: `Feat:` gives no release. The type `revert:` also gives no release.

Merge pull requests with squash merge. The pull-request title then becomes the commit message on `main`, so the title decides the release. `.github/workflows/pr-title.yml` checks the title on every pull request and shows the release it will give. Run the same check locally with `sh scripts/check-pr-title.sh "<title>"`.

After it picks the version, semantic-release publishes to npm (trusted publishing, no token), and creates the git tag `vX.Y.Z` and a GitHub Release with the notes.

The version in `package.json` stays `0.0.0-development` in git. semantic-release writes the real version only into the published package, so it never commits to `main`. The last released version is the latest `v*` git tag.

### Undoing a bad release

npm lets you remove a version only in rare cases, and a version number can never be used again. So publish a new version instead.

- Fix it or revert it in a pull request titled `fix: ...`, eg `fix: revert "feat: add --every"`. Do not keep the default GitHub title `Revert "..."`: it gives no release, and the title check fails. After the merge, CI publishes a new patch in a few minutes.
- If users must stop getting the bad version right now, point `latest` back to the last good version by hand (needs your npm login): `npm dist-tag add @mdless/cli@<good version> latest`. `npx @mdless/cli@latest` then runs that version. The next release moves `latest` forward again.

## Commands

- `mdless` - Interactive mode with command menu
- `mdless init` - Copy default agent prompts into `.mdless/agents/`
- `mdless agent <name>` - Run the agent in `.mdless/agents/<name>.md` once
- `mdless agent <name> --loop` - Run the agent on repeat forever (`--loop <n>` runs it `<n>` times)
- `mdless agent <name> --every <interval>` - Run the agent on repeat, waiting `<interval>` (eg `10m`) between runs
