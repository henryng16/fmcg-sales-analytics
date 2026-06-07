# Project Plan: FMCG Sales Analytics

## Goal
Build a showcase analytics engineering portfolio project.
Full pipeline: raw CSV → PostgreSQL → dbt models → dashboard.

## Stack
- PostgreSQL 16 (Docker container: postgres-analytics)
- dbt Core 1.11 (dbt-postgres adapter)
- Python 3.12 (ingestion scripts)
- DBeaver (SQL client)
- Power BI Desktop (BI / dashboard, Windows-only)
- Git + GitHub

## Data
- 7 CSV files, 6.76M sales transactions
- Source: Kaggle Grocery Sales Database
- Exercise from Vietnamese analytics Facebook group
- Tasks defined in: "Đề bài.docx" (14 business questions, 5 scenarios)

## Phases

### Phase 1: Data Engineering ✅ DONE
- [x] PostgreSQL + Docker setup
- [x] Database schema (raw layer, 7 tables, foreign keys)
- [x] Python ingestion pipeline (idempotent, COPY-based)
- [x] 6.76M rows loaded successfully
- [x] Git repo on GitHub

### Phase 2: dbt Models — NEXT
- [ ] Staging models (stg_) — 1:1 with source, light cleaning only
      (rename/cast). NO business logic, NO joins.
- [ ] Intermediate models — joins + calculated fields, incl. real revenue:
      quantity × product.price × (1 - discount) (raw total_price is 0).
- [ ] Mart models — answer the 14 business questions
- [ ] Schema tests (not_null, unique, relationships)
- [ ] dbt docs

### Phase 3: Visualization (Power BI)
- [ ] Connect Power BI to mart models
      (Power BI runs on Windows; Postgres is in WSL/Docker — reach it via
      localhost:5432 across the WSL boundary. Watch for connectivity friction.)
- [ ] Page 1: Executive Overview (KPIs, monthly trends)
- [ ] Page 2: Product & Inventory Risk
- [ ] Page 3: Customer & Sales Effectiveness
- [ ] Professional README with architecture diagram

## Key Data Note
raw.sales.total_price is 0 for all rows.
Must calculate: quantity × product.price × (1 - discount) in dbt models.

## Known gaps / tech-debt (housekeeping for later)
- No docker-compose.yml — Postgres is started manually via Docker Desktop.
  A compose file would make the DB reproducible from the repo.
- No virtual environment or requirements.txt — packages install globally in
  WSL, which is why missing-module errors happen (e.g. dotenv). A `.venv` +
  `requirements.txt` would make the Python setup reproducible and isolated.


