//BKACH002 JOB (LABV2),'ACH RETURNS',
//             CLASS=A,MSGCLASS=X,MSGLEVEL=(1,1),
//             RD=R,NOTIFY=&SYSUID,TIME=5
//* Synthetic lab system. Not a real bank. Educational / portfolio only.
//* RC: 0 OK / 4 WARN / 8 WAIT-RETRY / 12 INTEGRITY / 16 SEVERE
//* COND=EVEN only on notify/dump, never on monetary post steps.
//* Predecessor: BKACH000 RC<=4. Returns after 2 banking days R01.
//STEPCK   EXEC PGM=IEFBR14
//UACHRET  DD   DSN=HUB.ACH.RETURNS.D0,DISP=SHR
//IFOK     IF (STEPCK.RC < 8) THEN
//STEPRET  EXEC PGM=BKACH02
//STEPLIB  DD   DSN=HUB.LOAD,DISP=SHR
//UACHRET  DD   DSN=HUB.ACH.RETURNS.D0,DISP=(OLD,KEEP,KEEP)
//SYSOUT   DD   SYSOUT=*
//         ELSE
//STEPNTF  EXEC PGM=BKNTF01
//UNTF     DD   SYSOUT=*
//SYSIN    DD   *
BK-W-FILEWAIT RET
/*
//         ENDIF

