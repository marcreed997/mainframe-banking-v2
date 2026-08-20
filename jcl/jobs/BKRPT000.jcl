//BKRPT000 JOB (LABV2),'BANK V2 XCPT REPORT EVEN',
//             CLASS=A,MSGCLASS=X,MSGLEVEL=(1,1),
//             NOTIFY=&SYSUID
//* Synthetic lab system. Not a real bank. Educational / portfolio only.
//* RC: 0 OK / 4 WARN / 8 WAIT-RETRY / 12 INTEGRITY / 16 SEVERE
//* Restart: N/A — rerun from top if no DB updates
//STEPRP   EXEC PGM=BKRPT01,COND=EVEN
//STEPLIB  DD   DSN=HUB.LOAD,DISP=SHR
//URPT     DD   SYSOUT=*
//STEPSM   EXEC PGM=BKRPT02,COND=(16,LT)
//USUM     DD   SYSOUT=*
