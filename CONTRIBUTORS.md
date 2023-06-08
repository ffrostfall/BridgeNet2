# Setup

---

- Run `aftman install`
- Run `wally install`
- Start syncing `testing.project.json` for feature-related things, `stresstest.project.json` for performance-related things.

# Contributing

---

- **Do not publicly export functions directly.** There should always be something in the middle- preferably a file that returns a function.
- Make sure you format all edited files before finalizing a PR. I'll set up actions for this eventually.
- All new files must end in .luau if they are in the Luau lang. That being said- avoid creating new files. It clutters the source directory.

# What to look out for

---

- When fixing a bug, make sure to comment the bugfix if necessary- if it's an edge case for example, that requires a few extra lines, make comment that explains why that bug fix is there.
- Avoid placing anything remotely performance-intensive inside of things like callback runners, middleware, outbound bridges, etc.
- Never intrude on user code, never iterate over it, never touch it. This is one main selling point of BridgeNet2.
