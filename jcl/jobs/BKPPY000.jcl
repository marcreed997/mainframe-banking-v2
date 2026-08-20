//BKPPY000 JOB (LABV2),'POS PAY MATCH',
//             CLASS=A,MSGCLASS=X,MSGLEVEL=(1,1),
//             RD=R,NOTIFY=&SYSUID,TIME=5
//* Synthetic lab system. Not a real bank. Educational / portfolio only.
//* RC: 0 OK / 4 WARN / 8 WAIT-RETRY / 12 INTEGRITY / 16 SEVERE
//* COND=EVEN only on notify/dump, never on monetary post steps.
//* Presentment vs issued. Exceptions stay pending for BKPP01.
//STEPLST  EXEC PGM=IDCAMS
//SYSPRINT DD   SYSOUT=*
//SYSIN    DD   *
  LISTCAT ENTRIES(HUB.PP.PRESENT.D0)
  IF LASTCC > 0 THEN SET MAXCC = 8
/*
//STEPPPY  EXEC PGM=BKPPY01,COND=(4,LT)
//STEPLIB  DD   DSN=HUB.LOAD,DISP=SHR
//UPPIN    DD   DSN=HUB.PP.PRESENT.D0,DISP=SHR
//SYSOUT   DD   SYSOUT=*

