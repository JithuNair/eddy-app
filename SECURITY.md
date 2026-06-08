# Security and Privacy Policy

## Reporting a vulnerability

If you discover a security or privacy issue in Eddy, **please do not open a public GitHub issue**.

Instead, report it privately by emailing:

**jithunair95@gmail.com**

Include as much detail as you can:

- A description of the issue and its potential impact
- Steps to reproduce or a proof of concept if you have one
- The version or commit where you observed it
- Any suggested mitigations, if you have them

You will receive an acknowledgement within a reasonable timeframe. This is a solo-maintained open-source project — response times may vary, but security reports are always treated as a priority.

---

## Why this matters

Eddy is a wellbeing app. Even in its current MVP state — which stores only local habit data — future versions are planned to handle sensitive personal information:

- Emotional state check-ins
- Nervous system regulation history
- Focus session data
- Potentially audio or biometric signals

Privacy and security are not afterthoughts. If something feels wrong — a data exposure risk, an insecure dependency, a privacy-violating default, a vector for misuse — please raise it privately. That kind of report is taken seriously and handled with care.

---

## Scope

Current surface area to be aware of:

- **Local storage** — Hive is used for on-device habit storage. No data leaves the device in the current version.
- **Dependencies** — the project uses standard Flutter packages. If you identify a vulnerable dependency, please report it.
- **Web target** — Eddy currently runs as a web app. Standard web security considerations apply (XSS, content injection, etc.)

---

## Responsible disclosure

We ask that you:

- Give us a reasonable amount of time to address the issue before disclosing publicly
- Not exploit the vulnerability beyond what is needed to demonstrate it
- Not access or modify data that does not belong to you

In return, we will:

- Acknowledge your report promptly
- Keep you informed as the issue is investigated and resolved
- Credit you in the fix if you would like to be named

---

*Thank you for helping keep Eddy safe for the people who rely on it.*
