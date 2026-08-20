# Multi-site recon

HQ journal is system of record. EAST, WEST, ATM-NET (and CORR) send daily extracts.

Three-way:
1. Location body vs trailer (BKVLD01)
2. Location events vs BANK_JOURNAL (BKRCN01)
3. Posted nets vs GL feed (BKGL01 after recon closed)

Unmatched TRACE_ID → BANK_RECON_XCPT. Duplicate TRACE across sites → DUP-TRACE.
ATM reversals must cite original TRACE (BKAT02 / BKRCN02).
