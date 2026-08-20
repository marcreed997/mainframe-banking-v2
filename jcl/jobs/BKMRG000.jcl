//BKMRG000 JOB (LABV2),'BANK V2 MERGE LOCATIONS',
//             CLASS=A,MSGCLASS=X,MSGLEVEL=(1,1),
//             NOTIFY=&SYSUID
//* Synthetic lab system. Not a real bank. Educational / portfolio only.
//* RC: 0 OK / 4 WARN / 8 WAIT-RETRY / 12 INTEGRITY / 16 SEVERE
//* Restart: N/A — rerun from top if no DB updates
//STEPMRG  EXEC PGM=BKMRG01
//STEPLIB  DD   DSN=HUB.LOAD,DISP=SHR
//UMERGE   DD   DSN=HUB.MERGE.EXTRACT(+1),
//             DISP=(NEW,CATLG,DELETE),
//             SPACE=(CYL,(5,5),RLSE),UNIT=SYSDA
//* If a location not arrived BKMRG01 sets RC=8 FILEWAIT
//IFWAIT   IF (STEPMRG.RC = 8) THEN
//STEPW    EXEC PGM=BKNTF01
//UNTF     DD   SYSOUT=*
//SYSIN    DD   *
FILEWAIT
/*
//         ENDIF
