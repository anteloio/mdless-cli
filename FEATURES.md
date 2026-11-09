# Features

This file lists what mdless does today in plain English. It covers what you can do and see, not how the code works.

## Installation

- `npx @mdless/cli@latest` runs mdless without installing anything, and it always runs the latest version.
- You can also install it with `npm install -g @mdless/cli`.
- mdless needs Node.js 20.17 or newer.
- When a fix or a new feature is merged, a new version goes to npm right away.

## Setup

- `mdless init` copies the default `orchestrator` agent into `.mdless/agents/`.
- The `orchestrator` agent works through your GitHub issues and pull requests: it implements, reviews and fixes the work, and it leaves the merge to you.
- `mdless init` does not replace a file that already exists, so your edits stay.
- `mdless init` tells git to ignore the worktrees.

## Agents

- An agent is a markdown file in `.mdless/agents/`, and its file name is the agent name.
- `mdless agent <name>` runs the agent once.
- `mdless agent <name> --loop` runs the agent forever, with a 60-second wait between runs.
- `mdless agent <name> --loop <n>` runs the agent `<n>` times, with the same wait.
- If a run fails, the loop continues with the next run.
- `mdless agent` with no name shows a list of your agents, and you pick one.
- If the agent name does not exist, mdless shows the agents that you have.
- mdless runs Claude Code with permission prompts turned off, so an agent can run commands and change files without asking you.
- mdless tells every agent that no human is watching. The agent does not stop to ask questions, and it picks a reasonable default.
- If an agent is blocked, it writes what it needs in `.mdless/learnings/` and exits.

## Learnings

- When an agent starts, mdless tells it to read the notes in `.mdless/learnings/`.
- mdless tells every agent to save useful findings in that folder before it finishes.
- mdless also tells every agent to update or delete notes that are old or wrong.
- You can also write notes in that folder yourself.

## Terminal output

- You see the work of the agent live: its messages, its tool calls, short tool results, and its thinking.
- Each type of tool has its own color.
- Each line starts with the time.
- Each run ends with a summary of the turns, the duration, and the cost.
- mdless does not save this output to a file. When you close the terminal, it is gone.

## Other

- `mdless` with no command shows a menu with `init` and `exit`.
- `mdless --version` shows the version, and `mdless --help` shows the commands.
- When an agent starts, mdless plays a short random sound.
