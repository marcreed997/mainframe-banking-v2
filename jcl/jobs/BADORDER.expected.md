# BADORDER expected RC

| Step | Expected RC | Reason |
|------|-------------|--------|
| STEPPST | 8 or 12 | NOT-VALID (no validate) and/or CICS-ACTIVE (inhibit not set) |
| STEPRPT | 0 | COND=EVEN report still runs |

Do not catalog a GL extract from this job.
