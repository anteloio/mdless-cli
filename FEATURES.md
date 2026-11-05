# Features

This file lists what mdless does today in plain English. It covers what you can do and see, not how the code works.

## Setup

- `mdless init` copies the default `orchestrator` agent into `.mdless/agents/`.
- The `orchestrator` agent works through your GitHub issues and pull requests: it implements, reviews and fixes the work, and it leaves the merge to you.
- `mdless init` does not replace a file that already exists, so your edits stay.
- `mdless init` tells git to ignore the logs and worktrees.

## Agents

- An agent is a markdown file in `.mdless/agents/`, and its file name is the agent name.
- `mdless agent <name>` runs the agent once.
- `mdless agent <name> --loop` runs the agent forever, with a 60-second wait between runs.
- `mdless agent <name> --loop <n>` runs the agent `<n>` times, with the same wait.
- If a run fails, the loop continues with the next run.
- `mdless agent` with no name shows a list of your agents, and you pick one.
- If the agent name does not exist, mdless shows the agents that you have.
- mdless runs Claude Code with permission prompts turned off, so an agent can run commands and change files without asking you.

## Learnings

- When an agent starts, mdless tells it to read the notes in `.mdless/learnings/`.
- mdless tells every agent to save useful findings in that folder before it finishes.
- You can also write notes in that folder yourself.

## Terminal output

- You see the work of the agent live: its messages, its tool calls, short tool results, and its thinking.
- Each type of tool has its own color.
- Each line starts with the time.
- Each run ends with a summary of the turns, the duration, and the cost.

## Logs

- Each agent writes to its own log file, `.mdless/logs/<name>.log`.
- New runs add to the end of the log file.
- Logs are plain text, and colors stay in the terminal.

## Other

- `mdless` with no command shows a menu with `init` and `exit`.
- `mdless --version` shows the version, and `mdless --help` shows the commands.
- When an agent starts, mdless plays a short sound.
