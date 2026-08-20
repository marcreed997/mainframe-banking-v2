//BKCRD000 JOB (LABV2),'CARD SETTLE',
//             CLASS=A,MSGCLASS=X,MSGLEVEL=(1,1),
//             RD=R,NOTIFY=&SYSUID,TIME=5
//* Synthetic lab system. Not a real bank. Educational / portfolio only.
//* RC: 0 OK / 4 WARN / 8 WAIT-RETRY / 12 INTEGRITY / 16 SEVERE
//* COND=EVEN only on notify/dump, never on monetary post steps.
//* Capture vs auth. No silent EVEN on STEPCAP.
//STEPLST  EXEC PGM=IDCAMS
//SYSPRINT DD   SYSOUT=*
//SYSIN    DD   *
  LISTCAT ENTRIES(HUB.CARD.PRES.D0)
  IF LASTCC > 0 THEN SET MAXCC = 8
/*
//STEPCAP  EXEC PGM=BKCRD01,COND=(8,LE)
//STEPLIB  DD   DSN=HUB.LOAD,DISP=SHR
//UCRDIN   DD   DSN=HUB.CARD.PRES.D0,DISP=SHR
//SYSOUT   DD   SYSOUT=*
//IFINT    IF (STEPCAP.RC >= 12) THEN
//STEPNTF  EXEC PGM=BKNTE01,COND=ONLY
//UDMP     DD   SYSOUT=*
//SYSIN    DD   *
CAPTURE-GT-AUTH
/*
//         ENDIF

