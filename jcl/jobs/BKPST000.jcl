//BKPST000 JOB (LABV2),'BANK V2 DDA POST',
//             CLASS=A,MSGCLASS=X,MSGLEVEL=(1,1),
//             RD=R,NOTIFY=&SYSUID
//* Synthetic lab system. Not a real bank. Educational / portfolio only.
//* RC: 0 OK / 4 WARN / 8 WAIT-RETRY / 12 INTEGRITY / 16 SEVERE
//* Restart: RESTART=STEPPST
//* RD=R restartable. RESTART=STEPPST after deadlock RC=8.
//* Do not COND=EVEN on STEPPST.
//         JCLLIB ORDER=(HUB.PROCLIB)
//STEPLCK  EXEC PGM=IEFBR14
//* ENQ analog: DISP=OLD on lock dataset
//LOCK     DD   DSN=HUB.POST.LOCK,DISP=OLD
//* If lock busy, job waits on allocation — resource busy
//STEPPST  EXEC BKPSTPR,CYCLE=0,MODE=RESTART
//IFINT    IF (STEPPST.STEPPST.RC >= 12) THEN
//STEPNTF  EXEC PGM=BKNTF01,COND=ONLY
//UNTF     DD   SYSOUT=*
//SYSIN    DD   *
CICS-ACTIVE
/*
//STEPSEV  EXEC PGM=BKNTE01,COND=ONLY
//UDMP     DD   SYSOUT=*
//SYSIN    DD   *
NODUMP
/*
//         ENDIF
