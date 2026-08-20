# Mainframe Banking System V2

**Synthetic lab** COBOL / CICS / DB2 / JCL suite. Not a real bank. Educational.

V1 was five programs and a happy path. V2 is a **job network**: multi-site
settlement (HQ, RGN-EAST, RGN-WEST, ATM-NET, CORR-BANK), wait states when
files or predecessors are missing, and JCL RC handling so **out-of-order
runs fail closed** instead of double-posting money.

**Counted source lines:** 5361 (see `docs/LOC-REPORT.md`).

## Happy-path daily order

1. Register inbound files (`BKFIL01` / `BKFILE*`)
2. Validate per location (`BKVLDPR` / `RCNV*`) — hash + loc header
3. Merge + sort (`BKMRG000`, `BKSORT00`)
4. Inhibit CICS (`BKINH000`)
5. Post DDA with checkpoint (`BKPST000`)
6. Recon location vs hub + ATM (`BKRCN000`)
7. GL extract (`BKGL0000`) — blocked until recon closed
8. Close cycle + enable online (`BKCLO000`, `BKENA000`)

## Wait / fail (implemented)

| Condition | RC | Program/Job |
|-----------|----|-------------|
| File not arrived | 8 | BKVLD01, BKMRG01, BKWIR01 |
| Hash/trailer | 12 | BKVLD01, BKHT01 |
| Wrong location DD | 12 | BKVLD01 |
| CICS still up | 12 | BKPST01, BKCKP01 |
| Duplicate gen | 8 | BKFIL01 |
| Post before validate | 8 | BKPST01 / BADORDER.jcl |
| GL before recon | 8 | BKGL01 |
| Deadlock SQL -911 | 8 | BKSQL mapping |
| Cold restart with token | 16 | BKPST01 |

## Layout

See directories `copybook/`, `cobol/online/`, `cobol/batch/`, `cics/`, `jcl/`, `db2/`, `testdata/`, `docs/`.

## License

Lab / educational. Invented identifiers (`BKxxxxxx`). Not IBM sample code.
