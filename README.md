# Refret-Genesis Monorepo

This monorepo contains all REFRET, GENESIS, Exodus, and related projects.

## Structure

- `refret/` - Core REFRET project with skin management system
- `refret-too/` - REFRET variant with extensive asset collection (chrome, tweed, tube sets)
- `refret-three/` - Simplified REFRET variant with segmented fretboard
- `final-fret/` - Final production-ready REFRET version
- `project-genesis/` - GENESIS 2, 3, 4 projects and Elephant development snapshots
- `project-exodus/` - Exodus 1-6 versions and BEGINNER MODE variants
- `project-numbers/` - Numbers 1 (Pupil), Numbers 2 (Prototype), Numbers 3
- `passive-scale-listener/` - Core passive scale detection project
- `passive-scale-listener-express/` - Streamlined variant

## Migration Notes

All projects were consolidated from separate local repositories into this monorepo on April 5, 2026.
Individual git histories are preserved within each subdirectory using git subtree.

## Backup

Each original repository has a backup branch `backup-before-github-migration-20260405` for rollback if needed.
