//BKNSF000 JOB (LABV2),'BANK V2 NSF BATCH',
//             CLASS=A,MSGCLASS=X,MSGLEVEL=(1,1),
//             NOTIFY=&SYSUID
//* Synthetic lab system. Not a real bank. Educational / portfolio only.
//* RC: 0 OK / 4 WARN / 8 WAIT-RETRY / 12 INTEGRITY / 16 SEVERE
//* Restart: N/A — rerun from top if no DB updates
//STEPNS   EXEC PGM=BKNSF01
//STEPLIB  DD   DSN=HUB.LOAD,DISP=SHR
//UNSFIN   DD   DSN=HUB.NSF.IN(0),DISP=SHR
