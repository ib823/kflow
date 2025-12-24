# KerjaFlow Operations Runbook

**Deployment • Monitoring • Security • Incident Response**

Version 1.0 — December 2025

**⚠️ CONFIDENTIAL — Operations Team Only**

---

## PART 1: DEPLOYMENT PROCEDURES

### 1.1 Environment Overview

| Environment | Backend URL | Purpose | Access |
|-------------|-------------|---------|--------|
| Development | localhost:8069 | Local development | Developers only |
| Staging | staging-api.kerjaflow.my | QA testing, UAT | Dev + QA teams |
| Production | api.kerjaflow.my | Live system | All users |

### 1.2 Deployment Checklist

**Pre-Deployment Checks:**
1. ☐ All tests passing on CI/CD pipeline
2. ☐ Code reviewed and approved (minimum 2 reviewers for production)
3. ☐ Database migrations tested on staging
4. ☐ Release notes prepared
5. ☐ Rollback plan documented
6. ☐ Stakeholders notified of deployment window
7. ☐ On-call engineer confirmed available

### 1.3 Backend Deployment Steps

```bash
# 1. SSH to deployment server
ssh deploy@api.kerjaflow.my

# 2. Navigate to application directory
cd /opt/kerjaflow/backend

# 3. Pull latest code
git fetch origin
git checkout v1.2.3  # Use specific tag

# 4. Run database migrations
./scripts/migrate.sh

# 5. Restart application (zero-downtime)
sudo systemctl reload kerjaflow-api

# 6. Verify deployment
curl https://api.kerjaflow.my/health
# Expected: {"status": "healthy", "version": "1.2.3"}
```

### 1.4 Rollback Procedure

**⚠️ EXECUTE WITHIN 15 MINUTES OF DEPLOYMENT IF ISSUES DETECTED**

```bash
# 1. Identify previous working version
git tag --list | head -5

# 2. Rollback to previous version
git checkout v1.2.2  # Previous version

# 3. Rollback migrations (if needed)
./scripts/migrate.sh --rollback 1

# 4. Restart application
sudo systemctl restart kerjaflow-api

# 5. Notify team
# Post in #kerjaflow-alerts Slack channel
```

### 1.5 Database Migration Safety

| Setting | Value |
|---------|-------|
| Migration Tool | Alembic (Python/FastAPI) or Django Migrations |
| Backup Before | ALWAYS create backup before running migrations |
| Backup Command | `pg_dump -Fc kerjaflow > backup_$(date +%Y%m%d_%H%M%S).dump` |
| Safe Migrations | ADD column, ADD index, ADD table only |
| Risky Migrations | DROP column, RENAME column, MODIFY type → Require maintenance window |
| Migration Lock | Use advisory locks to prevent concurrent migrations |

---

## PART 2: MONITORING & ALERTING

### 2.1 Health Check Endpoints

| Endpoint | Expected Response | Checks Performed |
|----------|-------------------|------------------|
| GET /health | 200 OK | Basic liveness check |
| GET /health/ready | 200 OK | Database connection, Redis connection |
| GET /health/db | 200 OK | PostgreSQL connectivity, query latency |
| GET /health/storage | 200 OK | S3 bucket accessibility |

**Health Response Format:**
```json
{
  "status": "healthy",
  "version": "1.2.3",
  "timestamp": "2025-12-20T10:30:00+08:00",
  "components": {
    "database": { "status": "up", "latency_ms": 5 },
    "redis": { "status": "up", "latency_ms": 2 },
    "storage": { "status": "up" }
  }
}
```

### 2.2 Key Metrics

| Metric | Target | Alert Threshold | Severity |
|--------|--------|-----------------|----------|
| API Response Time (p95) | < 500ms | > 1000ms for 5min | WARNING |
| API Response Time (p95) | < 500ms | > 3000ms for 2min | CRITICAL |
| Error Rate (5xx) | < 0.1% | > 1% for 5min | WARNING |
| Error Rate (5xx) | < 0.1% | > 5% for 2min | CRITICAL |
| CPU Usage | < 70% | > 80% for 10min | WARNING |
| Memory Usage | < 80% | > 90% for 5min | CRITICAL |
| Database Connections | < 80% of max | > 90% of max | WARNING |
| Disk Usage | < 70% | > 85% | WARNING |
| Failed Login Attempts | < 10/min | > 50/min | WARNING |

### 2.3 Alert Channels

| Severity | Channel | Response Time |
|----------|---------|---------------|
| CRITICAL | PagerDuty + Slack #alerts + SMS | Immediate (< 15 minutes) |
| WARNING | Slack #kerjaflow-alerts | Within 1 hour (business hours) |
| INFO | Slack #kerjaflow-monitoring | Next business day |

---

## PART 3: LOG MANAGEMENT

### 3.1 Log Locations

| Component | Log Path / Service | Retention |
|-----------|-------------------|-----------|
| API Application | /var/log/kerjaflow/api.log | 30 days |
| API Errors | /var/log/kerjaflow/error.log | 90 days |
| Nginx Access | /var/log/nginx/access.log | 14 days |
| Nginx Error | /var/log/nginx/error.log | 30 days |
| PostgreSQL | /var/log/postgresql/postgresql-15-main.log | 7 days |
| Audit Logs | Database: kf_audit_log table | 7 years |
| Centralized | AWS CloudWatch / Elastic Stack | Per policy |

### 3.2 Log Format

```json
{
  "timestamp": "2025-12-20T10:30:00.123+08:00",
  "level": "INFO",
  "logger": "api.leave",
  "message": "Leave request created",
  "request_id": "abc123",
  "user_id": 456,
  "company_id": 1,
  "duration_ms": 45,
  "extra": { "leave_type": "AL", "days": 3 }
}
```

### 3.3 Common Log Queries

```bash
# Find errors for specific request
grep "request_id.*abc123" /var/log/kerjaflow/api.log

# Find all errors in last hour
journalctl -u kerjaflow-api --since "1 hour ago" | grep ERROR

# Find failed login attempts
grep "INVALID_CREDENTIALS" /var/log/kerjaflow/api.log | tail -50

# Find slow queries (> 1s)
grep "duration_ms.*[0-9]\{4,\}" /var/log/kerjaflow/api.log
```

---

## PART 4: BACKUP & RECOVERY

### 4.1 Backup Schedule

| Data Type | Frequency | Retention | Location |
|-----------|-----------|-----------|----------|
| PostgreSQL Full | Daily 2:00 AM MYT | 30 days | S3 + Cross-region |
| PostgreSQL WAL | Continuous | 7 days | S3 |
| File Storage (S3) | Cross-region replication | Same as source | ap-southeast-2 |
| Application Config | On change (Git) | Unlimited | GitHub |

### 4.2 Backup Verification

Monthly backup restoration test procedure:
1. Select random backup from past 30 days
2. Restore to isolated test database instance
3. Run data integrity checks (row counts, checksums)
4. Start test API instance against restored database
5. Run smoke tests (login, view payslip, apply leave)
6. Document results in backup verification log
7. Destroy test infrastructure

### 4.3 Disaster Recovery

| Setting | Value |
|---------|-------|
| RTO (Recovery Time Objective) | 4 hours |
| RPO (Recovery Point Objective) | 1 hour (WAL archiving) |
| DR Region | ap-southeast-2 (Sydney) |
| Failover Trigger | Manual decision by CTO + Ops Lead |

---

## PART 5: INCIDENT RESPONSE

### 5.1 Severity Levels

| Level | Definition | Examples |
|-------|------------|----------|
| SEV-1 | Complete service outage | API down, database unavailable |
| SEV-2 | Major feature unavailable | Login broken, payslips inaccessible |
| SEV-3 | Minor feature degraded | Slow performance, notification delays |
| SEV-4 | Cosmetic or minor issue | UI glitch, non-critical bug |

### 5.2 Response Times

| Severity | Response Time | Update Frequency | Resolution Target |
|----------|---------------|------------------|-------------------|
| SEV-1 | 15 minutes | Every 30 minutes | 4 hours |
| SEV-2 | 1 hour | Every 2 hours | 8 hours |
| SEV-3 | 4 hours | Daily | 72 hours |
| SEV-4 | Next business day | Weekly | Next sprint |

### 5.3 Incident Commander Checklist

**For SEV-1 and SEV-2 incidents:**
1. ☐ Acknowledge alert and claim incident
2. ☐ Create incident channel: #incident-YYYYMMDD-brief-description
3. ☐ Post initial assessment to channel
4. ☐ Assemble response team (backend, frontend, infra as needed)
5. ☐ Establish bridge call if needed
6. ☐ Post status updates at required intervals
7. ☐ Document all actions taken with timestamps
8. ☐ When resolved, update status page
9. ☐ Schedule post-mortem within 48 hours

### 5.4 On-Call Rotation

| Setting | Value |
|---------|-------|
| Rotation Length | 1 week (Monday 9 AM to Monday 9 AM) |
| Primary On-Call | First responder, must acknowledge within 15 minutes |
| Secondary On-Call | Backup if primary doesn't respond within 15 minutes |
| Escalation Path | Primary → Secondary → Engineering Manager → CTO |
| Handoff | Brief sync at rotation change, document any ongoing issues |

---

## PART 6: SCHEDULED JOBS

### 6.1 Cron Job Schedule

| Job Name | Schedule (MYT) | Description | Timeout |
|----------|----------------|-------------|---------|
| backup_database | Daily 2:00 AM | Full PostgreSQL backup to S3 | 2 hours |
| cleanup_tokens | Daily 3:00 AM | Delete expired refresh tokens | 30 minutes |
| send_leave_reminders | Daily 8:00 AM | Notify employees of leave starting tomorrow | 15 minutes |
| check_permit_expiry | Daily 9:00 AM | Alert HR of permits expiring in 30/60/90 days | 15 minutes |
| update_leave_balances | Daily 12:01 AM | Move approved leaves to 'taken' after date_to | 30 minutes |
| expire_carried_leave | Monthly 1st, 12:01 AM | Expire carried leave per policy | 1 hour |
| archive_audit_logs | Monthly 1st, 4:00 AM | Move old audit logs to cold storage | 4 hours |
| year_end_carry_forward | Configurable (year end) | Process leave carry-forward | 2 hours |

### 6.2 Job Monitoring

- All jobs log start/complete/error to centralized logging
- Failed jobs trigger PagerDuty alert
- Jobs exceeding timeout are killed and logged as failed
- Dashboard shows last run time and status for each job

---

*— End of Operations Runbook —*

**⚠️ Review and update quarterly or after major infrastructure changes**
