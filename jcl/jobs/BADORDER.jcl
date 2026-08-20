//BADORDER JOB (LABV2),'BANK V2 INTENTIONAL POST BEFORE VALIDATE',
//             CLASS=A,MSGCLASS=X,MSGLEVEL=(1,1),
//             NOTIFY=&SYSUID
//* Synthetic lab system. Not a real bank. Educational / portfolio only.
//* RC: 0 OK / 4 WARN / 8 WAIT-RETRY / 12 INTEGRITY / 16 SEVERE
//* Restart: N/A — rerun from top if no DB updates
//* FOR TEST of out-of-order detection — expected STEPPST RC=8
//* NOT-VALID because VALIDATED_IND still N and/or CICS still up.
//STEPPST  EXEC PGM=BKPST01
//STEPLIB  DD   DSN=HUB.LOAD,DISP=SHR
//URST     DD   DUMMY
//SYSIN    DD   *
COLD
/*
//STEPRPT  EXEC PGM=BKRPT01,COND=EVEN
//URPT     DD   SYSOUT=*
