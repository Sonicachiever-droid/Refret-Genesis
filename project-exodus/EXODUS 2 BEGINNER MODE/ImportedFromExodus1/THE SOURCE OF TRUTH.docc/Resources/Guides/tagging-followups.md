---
title: Tagging & Follow-up Playbook
description: Shared taxonomy for Cascade documentation + how to flag next steps
---

## 1. Tag Taxonomy
Use these canonical tags (multiple allowed per transcript):
- `GameplayLogic` – score flow, fret advances, round mechanics
- `UIVisual` – layout, rendering, materials, animations
- `Assets` – textures, images, audio, catalog sourcing
- `ProcessComms` – comm conventions, prompts, workflows
- `DebugFixes` – compile errors, performance, instrumentation
- `Documentation` – catalog structure, transcript capture, guides/prompts

Apply tags via bullet list or inline callouts inside Highlights/Pending (e.g., `_Tags: GameplayLogic, UIVisual_`).

## 2. Cross-Project References
When work touches multiple projects:
1. Mention each repo/path explicitly (`@REFRET TOO/ContentView.swift`, `@FINAL_FRET/...`).
2. Note dependency direction (“REFRET THREE uses assets copied from REFRET TOO strings”).
3. Flag any required sync (e.g., “propagate chrome fretwire gradient to FINAL_FRET”).

## 3. Follow-up Entries
Add a **Pending** bullet for every open question, including:
- Specific file/task (“Re-enable open-string note lettering @REFRET THREE/ContentView.swift#120-150”).
- Ownership hint (Keith vs other assistant, or “User decision required”).
- Blocking context (“Need iPhone 17 Pro screenshot to verify”).

## 4. Status Tracking
For ongoing efforts (e.g., multi-step UI refactor):
- Create a short callout in Pending summarizing status and next checkpoint.
- Optionally mirror the item inside `.windsurf/plans/` for longer-lived tasks.

## 5. Review Cycle
Before marking a follow-up as complete:
1. Verify the linked transcript reflects the change.
2. Remove or update the Pending bullet.
3. Note completion in the relevant transcript or THE SOURCE OF TRUTH overview if cross-cutting.
