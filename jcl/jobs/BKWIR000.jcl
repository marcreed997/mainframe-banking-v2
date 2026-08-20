//BKWIR000 JOB (LABV2),'BANK V2 WIRE INBOX',
//             CLASS=A,MSGCLASS=X,MSGLEVEL=(1,1),
//             NOTIFY=&SYSUID
//* Synthetic lab system. Not a real bank. Educational / portfolio only.
//* RC: 0 OK / 4 WARN / 8 WAIT-RETRY / 12 INTEGRITY / 16 SEVERE
//* Restart: N/A — rerun from top if no DB updates
//STEPWI   EXEC PGM=BKWIR01
//STEPLIB  DD   DSN=HUB.LOAD,DISP=SHR
//UWIRE    DD   DSN=HUB.CORRBANK.EXTRACT.D0,DISP=SHR
//IFW      IF (STEPWI.RC = 8) THEN
//STEPN    EXEC PGM=BKNTF01
//UNTF     DD   SYSOUT=*
//SYSIN    DD   *
FILEWAIT
/*
//         ENDIF
