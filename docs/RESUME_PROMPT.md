# Resume prompt — AI Cluster / Mainframe V2

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
| V2 mainframe source | `D:\AIcomp\mainframe-banking-v2` (create via script below if missing) |

## Canonical repos

1. Cluster / agents / backlog: https://github.com/marcreed997/grok/tree/main/projects/ai-cluster
2. **V2 source (new, public):** https://github.com/marcreed997/mainframe-banking-v2  
   Commit: `b113ca7` — *Correct LOC-REPORT: 10397 distinct source lines, uniqueness check*  
   Do not confuse with V1 under `testcpl`.

## What is already done — do not redo

- Workstation GPU / Docker / Ollama / Memgraph lab is up.
- V1 five COBOL programs modernized to Spring Boot + Compose + Postgres (`bankdb` + `bank_audit`) + AuditWriter.
- KG P0 seed, Converter BL-030 fidelity, ingest_scan BL-050c–e / 050d / 054c, SHARES_MAP / PRODUCES_FOR, 3270.html, /health.
- INTERIM_REVIEW + BACKLOG through BL-067. BL-056 still deferred.
- **V2 generated and pushed.** Inventory (authoritative = `docs/LOC-REPORT.md`, not the README summary if they disagree):
  - **10,397** counted source lines (cics 486, cobol 7868, copybook 765, db2 372, jcl 906)
  - 67 COBOL PROGRAM-IDs, 35 copybooks, 14 BMS maps, 57+ JCL members
  - Worst procedure Jaccard among largest programs **0.18** (not clones)
  - Locations: HQ, RGNEAST, RGNWEST, ATMNET, CORRBANK
  - RC contract 0/4/8/12/16; wait states coded (file, CICS inhibit, ENQ, GDG, predecessor)
  - **No Java/Spring port of V2** (prompt forbade it)

V2 generation prompt (already executed): project file `V2_MAINFRAME_BANKING_GENERATION_PROMPT.md`. Do not regenerate V2 unless uniqueness/LOC is proven broken.

## Current gap

V2 exists on GitHub. It may **not** yet exist on `D:\`. Memgraph still has the V1-shaped graph. Next work is **local clone, then KG ingest of V2 jobs + wait edges** — not converting V2, not rewriting V1, not BL-056.

## This session — one deliverable

**Deliverable A (do first if `D:\AIcomp\mainframe-banking-v2` is missing):**

Run the PowerShell script `Setup-MainframeBankingV2.ps1` (paste from the last session / project artifacts). It:

- Creates `D:\AIcomp` if needed
- `git clone`s V2 into `D:\AIcomp\mainframe-banking-v2`
- **Never** writes under `testcpl`, `agents`, or `modernized`
- Verifies ≥67 `.cbl`, ≥35 `.cpy`, ≥14 `.bms`, LOC-REPORT in 9000–12000

PowerShell (after saving the script, e.g. `D:\AIcomp\Setup-MainframeBankingV2.ps1`):

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
cd D:\AIcomp
# if the .ps1 is only in the chat, save it first, then:
.\Setup-MainframeBankingV2.ps1
# later updates:
.\Setup-MainframeBankingV2.ps1 -PullIfExists
```

If git is missing: install Git for Windows. `-SkeletonOnly` makes empty folders and is **not** a substitute for the clone.

Verify:

```powershell
Test-Path D:\AIcomp\testcpl
Test-Path D:\AIcomp\mainframe-banking-v2\docs\LOC-REPORT.md
Get-ChildItem D:\AIcomp\mainframe-banking-v2 -Recurse -Include *.cbl | Measure-Object
Select-String -Path D:\AIcomp\mainframe-banking-v2\docs\LOC-REPORT.md -Pattern 'Total counted source lines'
```

Expect V1 path still present; V2 cbl count 67; LOC **10397**.

**Deliverable B (only after A verifies — next session is OK):**

Ingest **V2 job network + wait edges** into Memgraph (BL-060 shaped, using V2 `docs/JOB-NETWORK.md` + JCL predecessors). Do **not** ingest V1’s five programs as the job graph. Do **not** auto-wire ingest_scan. One Cypher verification after persist. Then stop.

Do not start BL-057 (batch-convert all V1 files) or a V2 Java port in the same turn.

## Flags / agents (unchanged)

- `--kg-xai` coordinator only; `--force-xai` all agents.
- Converter `run` must pass `source_file`, `source_code`, `target_tech` (BL-030).
- JDBC in Docker: host `bank-postgres`, not `localhost`.

END RESUME
