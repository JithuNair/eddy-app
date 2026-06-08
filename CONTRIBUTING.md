# Contributing to Eddy

Thank you for being here. Eddy is built by and for people with ADHD — and that includes how we work together.

There is no velocity pressure here. No sprint deadlines. No contribution streaks. Show up when you can, contribute what makes sense for your energy and capacity right now. Small things count. Everything lands in its own time.

---

## What you can contribute

Contributions don't have to be code. Eddy benefits from:

- **Code** — bug fixes, feature work, performance improvements, refactors
- **Regulation techniques** — research-backed breathing, grounding, or nervous system tools
- **Accessibility improvements** — screen reader support, contrast, motor accessibility, cognitive load reduction
- **Localization** — translation into other languages (Hindi and Malayalam are planned first)
- **Ambient sounds** — suggestions or sourcing for brown noise, rain, café hum, etc.
- **Documentation** — clearer setup instructions, better inline comments, guides
- **Design feedback** — visual review, UX observations, anything that feels off
- **Testing** — manual testing on different devices, writing widget tests, edge case coverage
- **Ideas and discussion** — opening issues to share observations, ask questions, or propose features

If you're not sure whether something is worth raising — raise it anyway. There are no bad questions here.

---

## Setting up the project

**Requirements:**

- Flutter 3.x or later — [install Flutter](https://docs.flutter.dev/get-started/install)
- Chrome (for web development)
- A code editor — VS Code with the Flutter extension works well

**Steps:**

```bash
git clone https://github.com/jithunair/eddy-app.git
cd eddy-app
flutter pub get
flutter run -d chrome
```

Hot reload is enabled — save a file and the app updates in place. Hot restart (`R` in the terminal) resets state.

---

## Running the checks

Before opening a pull request, please run:

```bash
# Static analysis — should report "No issues found"
flutter analyze

# Widget tests
flutter test
```

If either fails, include the output in your PR and note what you tried. Sometimes environment issues happen — that's fine to mention.

---

## Branch and PR guidance

- Work on a branch named after what you're doing: `feat/ambient-sounds`, `fix/breathing-timer`, `docs/contributing-guide`
- Keep PRs focused. One thing per PR is easier to review and easier to merge
- Write a short description in the PR body — what changed, why, and anything the reviewer should know
- If you're working on something larger, open a GitHub Discussion or draft PR first. Not for gatekeeping — just to avoid duplicated effort and to make sure the direction fits

You don't need to wait for permission to start. Fork, branch, and build. The worst outcome is a conversation about fit.

---

## Design principles

Eddy's design is grounded in a few things that should stay consistent:

- **Regulation first.** The app opens on a tool you can use immediately. Never hide calm behind navigation.
- **Dark mode first.** ADHD brains are often light-sensitive. Light mode may come later, but it is not the default.
- **No shame mechanics.** No broken chains, no "you missed X days", no guilt-flavoured nudges.
- **Minimal friction.** Dysregulated people won't navigate three screens. Features should be reachable fast.
- **Calm motion.** Animations should feel deliberate and gentle, not flashy.
- **Clarity over cleverness.** Code and UI should both be easy to follow.

If a contribution introduces streak mechanics, gamification pressure, or anything that punishes inconsistency — it won't land. That's not a judgment on the idea, just a product boundary.

---

## Contributor expectations

- Be kind. Assume good intent. Ask before concluding.
- Async is the default. No one owes a same-day reply.
- You don't have to justify your capacity or explain gaps. Life happens.
- Attribution matters. If your contribution builds on someone else's work, note it.
- Code of conduct applies — see [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md).

---

## A note on neurodivergence

Many contributors to Eddy may themselves be neurodivergent. That shapes how we communicate:

- Clear, direct feedback is preferred over hinted criticism
- Long review threads are fine to take slowly
- It's okay to step back from a PR and return to it later
- "I don't have the bandwidth for this right now" is a complete and valid response

If the process ever feels like too much — say so. We can figure it out.

---

*Thank you for helping make Eddy better.*
