//BKACH000 JOB (LABV2),'ACH NACHA IN',
//             CLASS=A,MSGCLASS=X,MSGLEVEL=(1,1),
//             RD=R,NOTIFY=&SYSUID,TIME=5
//* Synthetic lab system. Not a real bank. Educational / portfolio only.
//* RC: 0 OK / 4 WARN / 8 WAIT-RETRY / 12 INTEGRITY / 16 SEVERE
//* COND=EVEN only on notify/dump, never on monetary post steps.
//* Restart: RESTART=STEPACH after deadlock RC=8 (2 min wait).
//* Inbound DISP=SHR KEEP. Output CATLG/DELETE (no partial catalog).
//         JCLLIB ORDER=(HUB.PROCLIB)
//STEPLST  EXEC PGM=IDCAMS
//SYSPRINT DD   SYSOUT=*
//SYSIN    DD   *
  LISTCAT ENTRIES(HUB.ACH.NACHA.D0)
  IF LASTCC > 0 THEN SET MAXCC = 8
/*
//IFWAIT   IF (STEPLST.RC >= 8) THEN
//STEPNTF  EXEC PGM=BKNTF01,COND=EVEN
//UNTF     DD   SYSOUT=*
//SYSIN    DD   *
BK-W-FILEWAIT ACH
/*
//         ELSE
//STEPACH  EXEC PGM=BKACH01,COND=(8,LE,STEPLST)
//STEPLIB  DD   DSN=HUB.LOAD,DISP=SHR
//UACHIN   DD   DSN=HUB.ACH.NACHA.D0,DISP=SHR
//SYSOUT   DD   SYSOUT=*
//SYSIN    DD   *
NIGHT
/*
//IFBAD    IF (STEPACH.RC >= 12) THEN
//STEPFLS  EXEC PGM=BKNTE01,COND=ONLY
//UDMP     DD   SYSOUT=*
//SYSIN    DD   *
BK-E-HASH ACH
/*
//         ENDIF
//         ENDIF

