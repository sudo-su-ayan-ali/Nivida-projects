# Backup, Point-in-Time Recovery (PITR) & Data Integrity

- **Status:** Approved
- **Owner:** Database Administrator / Reliability Engineer
- **Last Updated:** 2026-10-29
- **Related Documents:** [`../04-architecture/reliability-and-failure-modes.md`](../04-architecture/reliability-and-failure-modes.md), [`database-architecture.md`](database-architecture.md)

---

## 1. Backup Topology & Cadence

* **Daily Snapshot Backups**: Automated daily full snapshots retained for 30 days in off-site encrypted AWS S3 storage.
* **Continuous Write-Ahead Log (WAL) Archiving**: Continuous WAL streaming enables **Point-in-Time Recovery (PITR)** down to the exact minute of failure.

---

## 2. Recovery Objectives & Disaster Procedures

* **Recovery Point Objective (RPO)**: $< 1\text{ hour}$ data loss in catastrophic disaster scenarios.
* **Recovery Time Objective (RTO)**: $< 30\text{ minutes}$ to restore services to a warm standby replica.

### Disaster Recovery Runbook (CLI Restore)
```bash
# 1. Fetch latest verified snapshot from encrypted backup bucket
pg_restore -h <db_host> -U <db_user> -d <target_db> --clean --if-exists backup_snapshot.dump

# 2. Re-apply WAL segment logs to recover up to timestamp
SELECT pg_wal_replay_resume();

# 3. Verify RLS policy integrity and run smoke tests
supabase db test
```
