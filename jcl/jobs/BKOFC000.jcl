//BKOFC000 JOB (LABV2),'OFAC SCREEN',
//             CLASS=A,MSGCLASS=X,MSGLEVEL=(1,1),
//             RD=R,NOTIFY=&SYSUID,TIME=5
//* Synthetic lab system. Not a real bank. Educational / portfolio only.
//* RC: 0 OK / 4 WARN / 8 WAIT-RETRY / 12 INTEGRITY / 16 SEVERE
//* COND=EVEN only on notify/dump, never on monetary post steps.
//* SDN file existence check. Hits -> RC=12, do not open CIF dual.
//STEPLST  EXEC PGM=IDCAMS
//SYSPRINT DD   SYSOUT=*
//SYSIN    DD   *
  LISTCAT ENTRIES(HUB.OFAC.SDN.D0)
  IF LASTCC > 0 THEN SET MAXCC = 8
/*
//STEPOFC  EXEC PGM=BKOFC01,COND=(8,LE)
//STEPLIB  DD   DSN=HUB.LOAD,DISP=SHR
//USDNIN   DD   DSN=HUB.OFAC.SDN.D0,DISP=SHR
//SYSOUT   DD   SYSOUT=*

