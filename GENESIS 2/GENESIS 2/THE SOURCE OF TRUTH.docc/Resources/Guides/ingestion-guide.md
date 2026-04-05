---
title: Transcript Ingestion Guide
description: How to capture, summarize, and link new Cascade conversations
---

## 1. Collect Source Material
1. Confirm the conversation title + date with the user.
2. Copy the full transcript into the chat and wrap it with clear `BEGIN …` / `END …` markers.
3. Save the raw transcript verbatim inside `Resources/Transcripts/<slug>.md` with:
   - `# <Title> – <Date>` heading
   - `## Raw Transcript` block fenced in triple backticks

## 2. Summarize Each Conversation
1. Add `## Highlights` with 3–6 actionable bullet points referencing files/paths (`@REFRET THREE/ContentView.swift#70-150`).
2. Add `## Timeline` table (`Date | Topic | Action / Outcome | Follow-ups`).
3. Add `## Pending` bullet list (unresolved items, cross-project dependencies, or requests for other assistants).

## 3. Link from THE SOURCE OF TRUTH Overview
1. Under **Latest Entries**, add a slugged code span (e.g., ``FixingSwiftUIErrors``) followed by a one-line description and file link.
2. Maintain chronological order (most recent first) and keep the reminder callout about linking line references.

## 4. Tagging & Cross-References
1. Mention affected projects (FINAL_FRET, REFRET TOO, REFRET THREE) in Highlights or Pending.
2. If the session references other transcripts, cross-link them (e.g., “See `IntegratingFretboardComponents` for Round Completed plan”).

## 5. Review Checklist
- [ ] Raw transcript block present
- [ ] Highlights, Timeline, Pending sections complete
- [ ] Paths/line refs cited with `@path#line-range`
- [ ] Overview updated
- [ ] Pending tasks noted for Keith/other assistants

> Tip: when multiple assistants collaborate, drop work-in-progress notes into `Resources/Guides/tagging-followups.md` to keep everyone aligned.
