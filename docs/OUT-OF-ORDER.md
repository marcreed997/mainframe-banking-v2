# Out-of-order outcomes

| If this happens | Detected by | Outcome |
|-----------------|-------------|---------|
| Post before validate | BKPST01 VALIDATED_IND | RC=8 NOT-VALID |
| GL extract before recon | BKGL01 RECON_CLOSED | RC=8 |
| EAST job given WEST file | BKVLD01 header LOC | RC=12 LOC-MISMATCH |
| Restart COLD while token exists | BKPST01 | RC=16 unless FORCE=Y |
| Online tx after inhibit | BKCS01/02 flag | Map: SYSTEM IN BATCH |
| ATM file after cycle closed | cutoff vs cycle | Suspend / CUTOFF |
| Post while CICS up | ONLINE_INHIBIT=N | RC=12 CICS-ACTIVE |
| Merge before all arrivals | BKMRG01 count | RC=8 FILEWAIT |
| Sort fail | DFSORT RC | no post (COND) |
| Duplicate gen | BKFIL01 | RC=8 DUP-GEN |
