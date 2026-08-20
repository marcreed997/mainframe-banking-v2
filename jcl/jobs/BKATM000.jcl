//BKATM000 JOB (LABV2),'BANK V2 ATM CASSETTE',
//             CLASS=A,MSGCLASS=X,MSGLEVEL=(1,1),
//             NOTIFY=&SYSUID
//* Synthetic lab system. Not a real bank. Educational / portfolio only.
//* RC: 0 OK / 4 WARN / 8 WAIT-RETRY / 12 INTEGRITY / 16 SEVERE
//* Restart: N/A — rerun from top if no DB updates
//STEPAT   EXEC PGM=BKATM03
//STEPLIB  DD   DSN=HUB.LOAD,DISP=SHR
//UCASIN   DD   DSN=HUB.ATM.CASSETTE.D0,DISP=SHR
