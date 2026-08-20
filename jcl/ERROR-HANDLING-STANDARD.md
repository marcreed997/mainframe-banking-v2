# JCL error-handling standard (V2)

| RC | Meaning | Action |
|----|---------|--------|
| 0 | OK | Continue |
| 4 | Warning / empty / unmatched recon items remain | Continue unless posting requires data |
| 8 | Wait / retry / file not arrived / deadlock / recon not closed | Skip downstream **update** steps |
| 12 | Integrity (hash, loc mismatch, vault, CICS still active) | Flush remaining update steps; reports EVEN ok |
| 16 | Severe restart token | Fail job |

- `COND=EVEN` / `ONLY` **only** on BKNTF01 / BKRPT01 / BKNTE01 — never BKPST01.
- Inbound DISP KEEP on abend. Output extracts `DISP=(NEW,CATLG,DELETE)`.
- Restart posting with `RD=R` and `RESTART=STEPPST`; operations wait 2 min on RC=8 deadlock.
