<!-- icm:start -->
## Persistent memory (ICM) — MANDATORY

This project uses [ICM](https://github.com/rtk-ai/icm) for persistent memory across sessions.
You MUST use it actively. Not optional.

### Recall (before starting work)
```bash
icm recall "query"                        # search memories
icm recall "query" -t "topic-name"        # filter by topic
icm recall-context "query" --limit 5      # formatted for prompt injection
```

### Store — MANDATORY triggers
You MUST call `icm store` when ANY of the following happens:
1. **Error resolved** → `icm store -t errors-resolved -c "description" -i high -k "keyword1,keyword2"`
2. **Architecture/design decision** → `icm store -t decisions-{project} -c "description" -i high`
3. **User preference discovered** → `icm store -t preferences -c "description" -i critical`
4. **Significant task completed** → `icm store -t context-{project} -c "summary of work done" -i high`
5. **Conversation exceeds ~20 tool calls without a store** → store a progress summary

Do this BEFORE responding to the user. Not after. Not later. Immediately.

Do NOT store: trivial details, info already in this file, ephemeral state (build logs, git status).

### Memoirs (permanent knowledge graphs)
Use memoirs for durable, structured knowledge that outlasts individual memories.
```bash
icm memoir create -n "my-memoir" -d "Description"   # create knowledge container
icm memoir add-concept -m "my-memoir" -n "concept" \
  -d "Dense definition" -l "type:decision,domain:arch" # add concept with labels
icm memoir link -m "my-memoir" --from "a" --to "b" \
  -r depends-on                                        # link concepts (relations:
                                                       # part-of, depends-on, related-to,
                                                       # contradicts, refines,
                                                       # alternative-to, caused-by,
                                                       # instance-of, superseded-by)
icm memoir export -m "my-memoir" -f json              # dump graph as JSON (or -f dot)
icm memoir search -m "my-memoir" "query"              # full-text search concepts
icm memoir list                                        # list all memoirs
icm memoir show "my-memoir"                            # stats + concept list
icm memoir inspect --memoir "my-memoir" "concept"      # full definition + graph
icm memoir refine --memoir "my-memoir" --name "concept" \
  --definition "new text"                              # update concept (bumps revision)
```

### Other commands
```bash
icm forget <id>                          # remove a memory by ID
icm list --all                           # list all memories
icm list --topic <name>                  # list memories in a topic
icm update <id> -c "updated content"     # edit memory in-place
icm health                                # topic hygiene audit
icm topics                                # list all topics
```
<!-- icm:end -->
