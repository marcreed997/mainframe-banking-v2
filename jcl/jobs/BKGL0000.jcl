//BKGL0000 JOB (LABV2),'BANK V2 GL EXTRACT',
//             CLASS=A,MSGCLASS=X,MSGLEVEL=(1,1),
//             NOTIFY=&SYSUID
//* Synthetic lab system. Not a real bank. Educational / portfolio only.
//* RC: 0 OK / 4 WARN / 8 WAIT-RETRY / 12 INTEGRITY / 16 SEVERE
//* Restart: N/A — rerun from top if no DB updates
//* Out-of-order: RC=8 if recon not closed
//STEPGL   EXEC PGM=BKGL01
//STEPLIB  DD   DSN=HUB.LOAD,DISP=SHR
//UGLOUT   DD   DSN=HUB.GL.FEED(+1),
//             DISP=(NEW,CATLG,DELETE),SPACE=(TRK,(5,5))
//IFGL     IF (STEPGL.RC = 8) THEN
//STEPN    EXEC PGM=BKNTF01
//UNTF     DD   SYSOUT=*
//SYSIN    DD   *
NOT-VALID
/*
//         ENDIF
