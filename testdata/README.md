# Test fixtures

| File | Trigger | Expected |
|------|---------|----------|
| EAST/WEST/ATM.happy.txt | Happy path | Validate RC=0, recon match if hub journal loaded |
| WEST.badhash.txt | Trailer count 99 vs 1 body | BKVLD01 RC=12 BK-E-HASH |
| EAST.wrongloc.txt | Header WEST on EAST job | RC=12 BK-E-LOCMISMATCH |
| ATM.orphanrev.txt | Credit without original dispense | BKRCN02 / BKAT02 ORPHAN-REV |
| (omit WEST file) | File not arrived | BKMRG01 RC=8 FILEWAIT |
| CICS inhibit not set | Post while online | BKPST01 RC=12 CICS-ACTIVE |
| BADORDER.jcl | Post before validate | RC=8 NOT-VALID |
| ACH.prenote.txt | Prenote amount must be zero | BKACH01 RC=0 (zero-dollar 28/23) |
| ACH.badhash.txt | Batch control tot_dr != body | BKACH01 RC=12 BK-E-HASH |
| PP.mismatch.txt | Issued amt != presented | BKPPY01 exception PEND, BKPP01 dual-control if >5000 |
