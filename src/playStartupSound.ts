import { spawn, spawnSync } from "node:child_process";
import { existsSync } from "node:fs";
import { join } from "node:path";
import { platform } from "node:os";
import { PACKAGE_ROOT } from "./paths.js";

function which(cmd: string): boolean {
  const result = spawnSync("which", [cmd], { stdio: "ignore" });
  return result.status === 0;
}

export function playStartupSound(): void {
  const sounds = ["ready-to-work.mp3", "work-work.mp3", "it-just-works.mp3", "we-cant-expect-god-to-do-all-the-work.mp3", "lets-go.mp3"];
  const pick = sounds[Math.floor(Math.random() * sounds.length)]!;
  const audioPath = join(PACKAGE_ROOT, "assets", pick);
  if (!existsSync(audioPath)) return;

  const player = platform() === "darwin" ? "afplay" : platform() === "linux" ? "mpg123" : null;
  if (!player || !which(player)) return;

  spawn(player, [audioPath], { stdio: "ignore", detached: true }).unref();
}
