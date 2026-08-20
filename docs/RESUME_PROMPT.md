# Resume prompt — AI Cluster / Mainframe V2
**Session close: 2026-08-20 ~19:52 EDT**

Copy everything between `BEGIN RESUME` and `END RESUME` into a **new** session.

---

BEGIN RESUME

This is the AI Cluster project (local-first hybrid: Ollama qwen2.5-coder:14b primary, xAI Grok fallback, Memgraph KG, specialist agents).

## Operator constraints (always)

- Scientific accuracy over speed. Triple-check. One focused deliverable at a time. Verify before claiming done.
- Step-by-step **PowerShell** for anything run on the Windows workstation.
- Do **not** re-implement completed work.
- IngestionAgent for unknowns (not Decisions). KGCoordinator for architectural Decisions only.
- Do **not** auto-wire `ingest_scan` (BL-056 deferred).
- GitHub login: `marcreed997`. Canonical cluster: https://github.com/marcreed997/grok/tree/main/projects/ai-cluster
- Live agents: `D:\AIcomp\agents` — keep in sync with GitHub `projects/ai-cluster/src`.
- Do **not** rewrite V1 in place.

## Hardware / lab

Windows workstation: Xeon w5-2445, RTX A4000 16GB, 64GB RAM, **D:** data drive.

| Role | Path |
|------|------|
| Lab root | `D:\AIcomp` |
| V1 COBOL (five programs) | `D:\AIcomp\testcpl` — **leave untouched** |
| Live agents | `D:\AIcomp\agents` |
| Spring Boot V1 port | `D:\AIcomp\modernized\bank-system-java` |
| V2 mainframe source | `D:\AIcomp\mainframe-banking-v2` (**verified present**) |

## Canonical repos

1. Cluster / agents / backlog: https://github.com/marcreed997/grok/tree/main/projects/ai-cluster
2. **V2 source (public):** https://github.com/marcreed997/mainframe-banking-v2  
   HEAD at close of 2026-08-20 session: `f28aa35` (and subsequent resume update)

## What is already done — do not redo

### Platform & V1
- Workstation GPU / Docker / Ollama / Memgraph lab is up.
- V1 five COBOL programs modernized to Spring Boot + Compose + Postgres (`bankdb` + `bank_audit`) + AuditWriter.
- KG P0 seed, Converter BL-030 fidelity, ingest_scan BL-050c–e / 050d / 054c, SHARES_MAP / PRODUCES_FOR, 3270.html, /health.
- INTERIM_REVIEW + BACKLOG through BL-068. BL-056 still deferred.

### V2 source (verified 2026-08-20)
- Local clone at `D:\AIcomp\mainframe-banking-v2` confirmed:
  - 67 `.cbl`, 35 `.cpy`, 14 `.bms`
  - LOC-REPORT total = **10397**
  - V1 path (`testcpl`) still present and untouched
- Setup script exists: `D:\AIcomp\Setup-MainframeBankingV2.ps1`

### V2 job network in Memgraph (verified 2026-08-20)
Manual bootstrap seed completed and verified:

| Metric | Value |
|--------|-------|
| `JclJob` nodes (suite='V2') | **30** |
| `PREDECESSOR_OF` edges | **~31** |
| `WaitGate` nodes | **10** |
| Happy-path length BKCAL000 → BKENA000 | **14** |

WaitGate types present and verified:
- FILE_EXISTENCE ×4 (RC 8)
- ALL_LOCS_ARRIVED (RC 8)
- CICS_INHIBITED (RC 12)
- RESOURCE_LOCK (RC 8)
- RECON_CLOSED (RC 8)
- VALIDATED_IND (RC 8)
- GDG_READY (RC 12)

This seed is now **institutional memory** and the evaluation gold standard for future agent work.

### Architectural capture
- **BL-068** added and committed on the cluster repo (`b8fc8c6`):
  *Agent-driven Ground Zero for job network & wait semantics*
  Manual Cypher was a necessary bootstrap only. Mature path requires an IngestionAgent / JobNetworkIngestionAgent that discovers the graph from source with provenance. Continuing hand-crafted Cypher defeats the state-plane thesis.

## Current open priority (P1)

1. **BL-068** (architectural priority) — Design / implement agent that can re-derive the V2 job network + wait gates from raw JCL + docs and write them with provenance. Use the existing seed as evaluation target.
2. BL-060 remainder — program-level / map-level dependency completeness.
3. BL-059 — Examine KG *read* path during conversion (currently write-only).
4. BL-057 / BL-058 — batch conversion + E2E gates (lower urgency than the agent-driven discovery principle).

## Explicit non-goals until BL-068 advances
- Do not convert V2 COBOL to Java.
- Do not expand the manual Cypher seed further as the primary growth mechanism.
- Do not auto-wire ingest_scan (BL-056 remains deferred).
- Do not touch V1 (`testcpl`).

## Suggested first action tomorrow
Decide whether the next focused deliverable is:
- A) Spec / scaffold for the JobNetworkIngestionAgent (BL-068), or
- B) Enrich the existing seed with program-level relationships while keeping the agent path as the stated goal.

Confirm the decision, then execute **one** deliverable only.

## Flags / agents (unchanged)
- `--kg-xai` coordinator only; `--force-xai` all agents.
- Converter `run` must pass `source_file`, `source_code`, `target_tech` (BL-030).
- JDBC in Docker: host `bank-postgres`, not `localhost`.

END RESUME
