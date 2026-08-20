      *****************************************************************
      * BKCRD - Card presentment / authorization / chargeback
      *****************************************************************
       01  BK-CARD-AUTH.
           05  CRD-AUTH-ID          PIC X(12).
           05  CRD-PAN-HASH         PIC X(16).
           05  CRD-EXP-YYMM         PIC 9(4).
           05  CRD-AUTH-AMT         PIC S9(13)V99 COMP-3.
           05  CRD-CAPTURE-AMT      PIC S9(13)V99 COMP-3.
           05  CRD-MCC              PIC X(4).
           05  CRD-NETWORK          PIC X(4).
               88  NET-VISA         VALUE 'VISA'.
               88  NET-MC           VALUE 'MAST'.
               88  NET-DISC         VALUE 'DISC'.
               88  NET-AMEX         VALUE 'AMEX'.
           05  CRD-POS-MODE         PIC X(2).
               88  POS-CHIP         VALUE '05'.
               88  POS-SWIPE        VALUE '02'.
               88  POS-KEYED        VALUE '01'.
               88  POS-ECOM         VALUE '81'.
           05  CRD-AUTH-TS          PIC X(26).
           05  CRD-STATUS           PIC X.
               88  CRD-OPEN-AUTH    VALUE 'A'.
               88  CRD-CAPTURED     VALUE 'C'.
               88  CRD-VOID         VALUE 'V'.
               88  CRD-EXPIRED      VALUE 'E'.
           05  CRD-HOLD-ID          PIC X(12).
           05  CRD-ACC-NO           PIC X(6).
           05  CRD-STAN             PIC 9(6).
       01  BK-CARD-PRESENT.
           05  CRD-P-TRACE          PIC X(26).
           05  CRD-P-AUTH-ID        PIC X(12).
           05  CRD-P-AMT            PIC S9(13)V99 COMP-3.
           05  CRD-P-SURCHARGE      PIC S9(7)V99 COMP-3.
           05  CRD-P-ICA            PIC X(6).
           05  CRD-P-ARN            PIC X(23).
           05  CRD-P-REASON         PIC X(4).
       01  BK-CHARGEBACK.
           05  CB-ARN               PIC X(23).
           05  CB-REASON            PIC X(4).
               88  CB-FRAUD         VALUE '4837'.
               88  CB-NOT-RCVD      VALUE '4853'.
               88  CB-DUP           VALUE '4834'.
               88  CB-CREDIT-NOT    VALUE '4860'.
           05  CB-AMT               PIC S9(13)V99 COMP-3.
           05  CB-CYCLE             PIC 9.
           05  CB-REPRESENT-IND     PIC X.
