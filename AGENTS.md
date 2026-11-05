# mdless-cli

CLI tools for Claude Code developers.

## Development

This project uses Bun and runs TypeScript directly without a build step.

### Setup

Symlink the CLI into a directory on your `PATH` that is **not** tied to a Node
version. `npm link` installs into the *current* Node version's global bin, so
with `nvm`/`.nvmrc` the `mdless` command vanishes the moment you `cd` into a
project pinned to a different Node version. A plain symlink avoids that:

```bash
mkdir -p ~/.local/bin              # ensure the dir exists and is on your PATH
ln -sf "$(pwd)/bin.mjs" ~/.local/bin/mdless
```

`bin.mjs` runs under whatever Node is active and resolves `tsx` + `src/` by its
own path, so `mdless` works from any folder under any Node version.

### Testing

After making changes, test by running `mdless` in any terminal - changes are reflected immediately.

### Documentation

Always update `README.md` after changing the code, so the docs and behavior stay in sync.

Always update `FEATURES.md` when you add, change, or remove a feature. It lists all features in plain English.

### Releasing

```bash
npm version patch  # bumps version and creates git tag
git push && git push --tags
npm publish
```

## Commands

- `mdless` - Interactive mode with command menu
- `mdless init` - Copy default agent prompts into `.mdless/agents/`
- `mdless agent <name>` - Run the agent in `.mdless/agents/<name>.md` once
- `mdless agent <name> --loop` - Run the agent on repeat forever (`--loop <n>` runs it `<n>` times)
