//BKSDD000 JOB (LABV2),'ACH SAME DAY',
//             CLASS=A,MSGCLASS=X,MSGLEVEL=(1,1),
//             RD=R,NOTIFY=&SYSUID,TIME=5
//* Synthetic lab system. Not a real bank. Educational / portfolio only.
//* RC: 0 OK / 4 WARN / 8 WAIT-RETRY / 12 INTEGRITY / 16 SEVERE
//* COND=EVEN only on notify/dump, never on monetary post steps.
//* Same-day ACH window. Uses BKACH01 PARM window=SAMEDAY.
//* Cutoff from BANK_CALENDAR SAME_DAY_CUT.
//STEPLST  EXEC PGM=IDCAMS
//SYSPRINT DD   SYSOUT=*
//SYSIN    DD   *
  LISTCAT ENTRIES(HUB.ACH.SDD.D0)
  IF LASTCC > 0 THEN SET MAXCC = 8
/*
//STEPSDD  EXEC PGM=BKACH01,COND=(8,LE)
//STEPLIB  DD   DSN=HUB.LOAD,DISP=SHR
//UACHIN   DD   DSN=HUB.ACH.SDD.D0,DISP=SHR
//SYSIN    DD   *
SAMEDAY
/*
//SYSOUT   DD   SYSOUT=*

