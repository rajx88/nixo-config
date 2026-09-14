---
name: icm-recall
description: >
  Search ICM persistent memory for relevant context. Use when user says "/recall", "icm recall",
  "search memory", "what do you remember about", or wants to retrieve stored context.
---

Search ICM memory for: $ARGUMENTS

Run:
```bash
if [ -z "$ARGUMENTS" ]; then
  icm wake-up --max-tokens 800
else
  icm recall "$ARGUMENTS" --limit 10
fi
```
