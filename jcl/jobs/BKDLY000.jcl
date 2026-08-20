//BKDLY000 JOB (LABV2),'BANK V2 DAILY DRIVER COMMENTS',
//             CLASS=A,MSGCLASS=X,MSGLEVEL=(1,1),
//             NOTIFY=&SYSUID
//* Synthetic lab system. Not a real bank. Educational / portfolio only.
//* RC: 0 OK / 4 WARN / 8 WAIT-RETRY / 12 INTEGRITY / 16 SEVERE
//* Restart: N/A — rerun from top if no DB updates
//* SCHEDULER VIEW (TWS/OPC analog) — do not EXEC all in one JOB
//* 1 BKFIL01 EAST,WEST,ATM  wait if RC=8 FILEWAIT
//* 2 BKVLDPR LOC=RGNEAST / RGNWEST / ATMNET
//* 3 BKMRG01 after all validates RC<=4
//* 4 BKCKP01 INHIBIT (CICS still up -> RC=12 on post)
//* 5 BKPST01
//* 6 BKRCN01 + BKRCN02
//* 7 BKGL01 only if recon closed
//* 8 BKRPT01 COND=EVEN
//* 9 BKCKP01 ENABLE
//STEP000  EXEC PGM=IEFBR14
