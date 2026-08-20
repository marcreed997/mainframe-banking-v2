//BKABD000 JOB (LABV2),'USER ABEND DEMO',
//             CLASS=A,MSGCLASS=X,MSGLEVEL=(1,1),
//             RD=R,NOTIFY=&SYSUID,TIME=5
//* Synthetic lab system. Not a real bank. Educational / portfolio only.
//* RC: 0 OK / 4 WARN / 8 WAIT-RETRY / 12 INTEGRITY / 16 SEVERE
//* COND=EVEN only on notify/dump, never on monetary post steps.
//* Demonstration only. SYSUDUMP. Production uses LE TRAP/TERMTHDACT.
//* Do NOT COND=EVEN on monetary steps — ONLY on this dump job.
//STEPABD  EXEC PGM=BKABD01
//STEPLIB  DD   DSN=HUB.LOAD,DISP=SHR
//SYSUDUMP DD   SYSOUT=*
//SYSMDUMP DD   SYSOUT=*
//SYSIN    DD   *
ABEND
/*
//STEPNTF  EXEC PGM=BKNTF01,COND=EVEN
//UNTF     DD   SYSOUT=*
//SYSIN    DD   *
BK-E-RESTART U4038
/*

