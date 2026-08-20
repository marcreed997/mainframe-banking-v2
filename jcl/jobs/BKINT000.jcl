//BKINT000 JOB (LABV2),'BANK V2 INTEREST ACCRUAL',
//             CLASS=A,MSGCLASS=X,MSGLEVEL=(1,1),
//             NOTIFY=&SYSUID
//* Synthetic lab system. Not a real bank. Educational / portfolio only.
//* RC: 0 OK / 4 WARN / 8 WAIT-RETRY / 12 INTEGRITY / 16 SEVERE
//* Restart: N/A — rerun from top if no DB updates
//STEPIN   EXEC PGM=BKINT01
//STEPLIB  DD   DSN=HUB.LOAD,DISP=SHR
//UINTOUT  DD   DSN=HUB.INT.ACCR(+1),DISP=(NEW,CATLG,DELETE),
//             SPACE=(TRK,(1,1))
