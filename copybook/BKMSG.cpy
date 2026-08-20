      *****************************************************************
      * BKMSG - Operator-searchable reason codes
      *****************************************************************
       01  BK-REASON-TEXT           PIC X(16).
           88  BK-W-FILEWAIT        VALUE 'FILEWAIT'.
           88  BK-E-HASH            VALUE 'HASH-FAIL'.
           88  BK-E-LOCMISMATCH     VALUE 'LOC-MISMATCH'.
           88  BK-E-ONLINEUP        VALUE 'ONLINEUP'.
           88  BK-E-DUPGEN          VALUE 'DUP-GEN'.
           88  BK-E-RESTART         VALUE 'RESTART'.
           88  BK-E-CUTOFF          VALUE 'CUTOFF'.
           88  BK-E-UNMATCHED       VALUE 'UNMATCHED'.
           88  BK-E-BUSY            VALUE 'RES-BUSY'.
           88  BK-E-CICS-ACTIVE     VALUE 'CICS-ACTIVE'.
           88  BK-E-NOT-VALID       VALUE 'NOT-VALID'.
           88  BK-E-ORPHAN-REV      VALUE 'ORPHAN-REV'.
           88  BK-I-OK              VALUE 'OK'.
           88  BK-W-EMPTY           VALUE 'EMPTY-FILE'.
       01  BK-OP-MSG                PIC X(80).
