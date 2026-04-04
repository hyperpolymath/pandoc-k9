<!-- SPDX-License-Identifier: PMPL-1.0-or-later -->
<!-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk> -->

# TOPOLOGY.md — pandoc-k9

## Purpose

Pandoc K9 filter enables document transformation to/from K9 format. Implements Lua-based reader, writer, and filter for Pandoc, allowing seamless integration of K9 documents into documentation pipelines and supporting K9's role as an extensible knowledge representation format in the hyperpolymath ecosystem.

## Module Map

```
pandoc-k9/
├── k9.lua               # Core K9 Lua module
├── k9-reader.lua        # K9 document reader
├── k9-writer.lua        # K9 document writer
├── k9-filter.lua        # Pandoc filter implementation
├── k9.html              # HTML reference documentation
├── container/           # Containerfile for portable builds
└── docs/                # Filter usage guides and examples
```

## Data Flow

```
[K9 Source] ──► [Lua Reader] ──► [Pandoc AST] ──► [Writer] ──► [Output Format]
                    ↑                                    ↓
               [Filter Chain] ◄────────────────────────┘
```

## Integration

- Part of RSR standard documentation pipeline
- Works with Pandoc's Lua filter interface
- K9 as knowledge representation layer in hyperpolymath ecosystem
- Containerized for consistent CI/CD processing
- Pairs with pandoc-a2ml for dual-format document workflows
