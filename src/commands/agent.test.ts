import { describe, expect, test } from "bun:test";
import { formatInterval, parseInterval } from "./agent.ts";

describe("parseInterval", () => {
  test.each([
    ["30s", 30],
    ["10m", 600],
    ["2h", 7200],
    ["1d", 86400],
    ["1h30m", 5400],
    ["1.5h", 5400],
    [" 10M ", 600],
  ])("reads %p as %p seconds", (text, seconds) => {
    expect(parseInterval(text)).toBe(seconds);
  });

  test.each(["", "10", "m", "0m", "10x", "-5m", "10 m", "m10"])("rejects %p", (text) => {
    expect(parseInterval(text)).toBeNull();
  });
});

describe("formatInterval", () => {
  test.each([
    [30, "30s"],
    [600, "10m"],
    [5400, "1h30m"],
    [86400, "1d"],
    [90061, "1d1h1m1s"],
  ])("writes %p seconds as %p", (seconds, text) => {
    expect(formatInterval(seconds)).toBe(text);
  });
});
