//BKCLO000 JOB (LABV2),'BANK V2 CLOSE CYCLE',
//             CLASS=A,MSGCLASS=X,MSGLEVEL=(1,1),
//             NOTIFY=&SYSUID
//* Synthetic lab system. Not a real bank. Educational / portfolio only.
//* RC: 0 OK / 4 WARN / 8 WAIT-RETRY / 12 INTEGRITY / 16 SEVERE
//* Restart: N/A — rerun from top if no DB updates
//STEPC    EXEC PGM=BKCKP01
//STEPLIB  DD   DSN=HUB.LOAD,DISP=SHR
//UDUMMY   DD   DUMMY
//SYSIN    DD   *
CLOSE
/*
//IFC      IF (STEPC.RC = 8) THEN
//STEPN    EXEC PGM=BKNTF01
//UNTF     DD   SYSOUT=*
//SYSIN    DD   *
NOT-VALID
/*
//         ENDIF
