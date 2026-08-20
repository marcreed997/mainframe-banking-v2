//BKCAL000 JOB (LABV2),'CALENDAR LOAD',
//             CLASS=A,MSGCLASS=X,MSGLEVEL=(1,1),
//             RD=R,NOTIFY=&SYSUID,TIME=5
//* Synthetic lab system. Not a real bank. Educational / portfolio only.
//* RC: 0 OK / 4 WARN / 8 WAIT-RETRY / 12 INTEGRITY / 16 SEVERE
//* COND=EVEN only on notify/dump, never on monetary post steps.
//* First-day LISTCAT not-found is acceptable — SET MAXCC.
//STEPLST  EXEC PGM=IDCAMS
//SYSPRINT DD   SYSOUT=*
//SYSIN    DD   *
  LISTCAT ENTRIES(HUB.CAL.LOAD.D0)
  IF LASTCC > 0 THEN SET MAXCC = 4
/*
//STEPCAL  EXEC PGM=BKCAL01,COND=(8,LE)
//STEPLIB  DD   DSN=HUB.LOAD,DISP=SHR
//UCALIN   DD   DSN=HUB.CAL.LOAD.D0,DISP=SHR
//SYSOUT   DD   SYSOUT=*

