# CIYJ Analytics — dbt Project

A dbt + Snowflake analytics project for the **Center for Innovative Youth Justice (CIYJ)**, focused on analyzing family engagement, incident patterns, staff outcomes, and youth behavior across juvenile justice facilities.

---

## Project Overview

This project transforms raw PbS (Performance-based Standards) survey and incident data loaded into Snowflake into clean, analytics-ready models for research and reporting.

**Core research questions:**
- Does family engagement predict lower rates of violent/safety incidents at a facility?
- Is family engagement associated with better staff climate and lower staff turnover?
- Do facilities with stronger family engagement show better youth behavior outcomes aligned with CIYJ's mission?

---

## Tech Stack

| Tool | Purpose |
|---|---|
| Snowflake | Cloud data warehouse |
| dbt Core | Data transformation and modeling |
| Python | Statistical analysis and modeling |
| Jupyter Notebooks | Exploratory data analysis |

---

## Project Structure

```
CIYJ_ANALYTICS/
├── dbt_project.yml          # dbt project configuration
├── profiles.yml             # (stored in ~/.dbt — NOT here)
├── README.md
├── models/
│   ├── staging/             # stg_* — typed, cleaned 1:1 with raw tables
│   │   ├── sources.yml
│   │   ├── stg_admin_form.sql
│   │   ├── stg_youth_climate.sql
│   │   ├── stg_staff_climate.sql
│   │   ├── stg_incidents_all.sql
│   │   └── stg_outcome_measures.sql
│   ├── intermediate/        # int_* — metric computation and joins
│   │   ├── int_family_engagement_facility_period.sql
│   │   ├── int_incidents_facility_period.sql
│   │   ├── int_staff_outcomes_facility_period.sql
│   │   └── int_youth_behavior_facility_period.sql
│   └── marts/               # mart_* — analytics-ready wide tables
│       └── mart_family_engagement_incidents.sql
├── macros/                  # Reusable SQL macros
├── tests/                   # Custom data tests
├── notebooks/               # EDA and statistical analysis
└── seeds/                   # Static reference data (if any)
```

---

## Data Sources

All raw data is loaded from an internal Snowflake stage (`CIYJ_STAGE`) into `CIYJ_ANALYTICS.CIYJ_SCHEMA`. Source tables include:

| Table | Description |
|---|---|
| `admin_form` | Facility-level administrative data per collection period |
| `youth_climate` | Youth climate survey responses |
| `staff_climate` | Staff climate survey responses |
| `outcome_measures` | PbS performance outcome metrics |
| `incident_reports_fights` | Fight incident records |
| `incident_reports_injury` | Injury incident records |
| `incident_reports_medical` | Medical examination records |
| `incident_reports_restraint` | Restraint use records |
| `incident_reports_confinement` | Confinement/isolation records |
| `incident_reports_youth_involved` | Youth involvement in incidents |

---

## Getting Started

### Prerequisites

- Python 3.12+
- [uv](https://github.com/astral-sh/uv) (recommended) or pip
- Snowflake account with access to `CIYJ_ANALYTICS`
- Rust/Cargo (required for `cryptography` package)

### 1. Clone the repo and set up the environment

```bash
git clone <your-repo-url>
cd CIYJ_ANALYTICS

# Create and activate virtual environment
uv venv ciyj_env
source ciyj_env/bin/activate

# Install dependencies
uv pip install dbt-core dbt-snowflake dbt-postgres
```

### 2. Configure your Snowflake connection

Create `~/.dbt/profiles.yml` (do **not** put this inside the project folder):

```yaml
ciyj_analytics:
  target: dev
  outputs:
    dev:
      type: snowflake
      account: your_account_id
      user: your_username
      password: "{{ env_var('SNOWFLAKE_PASSWORD') }}"
      role: ACCOUNTADMIN
      database: CIYJ_ANALYTICS
      warehouse: your_warehouse
      schema: CIYJ_SCHEMA
      threads: 4
```

Store your password in a `.env` file (never commit this):

```bash
echo "SNOWFLAKE_PASSWORD=YourPassword" >> .env
echo ".env" >> .gitignore
```

### 3. Test the connection

```bash
dbt debug
# Expected: "All checks passed."
```

### 4. Build all models

```bash
# Run all models in dependency order
dbt build

# Or run a specific model and its upstream dependencies
dbt run --select +mart_family_engagement_incidents
```

---

## Model Layers

| Layer | Prefix | Materialization | Purpose |
|---|---|---|---|
| Staging | `stg_` | View | Clean and type-cast raw source data |
| Intermediate | `int_` | View | Compute metrics and aggregate to facility-period grain |
| Marts | `mart_` | Table | Final wide analytics table for analysis |

---

## Key Metrics Produced

- `incident_rate_per_100yd` — incidents per 100 youth-days (standard correctional metric)
- `family_engagement_composite` — normalized 0–1 index combining visit rates, phone contact, staff attitudes, and policy inclusion
- `staff_turnover_proxy` — staff left as a proportion of total staff movement in the period
- `pct_youth_with_visits` — proportion of surveyed youth who received a family visit
- `avg_staff_value_family` — mean staff Likert score on family partnership items

---

## Running Tests

```bash
dbt test
```

Tests validate that:
- `respondent_id` is unique and not null in the mart
- `youth_days` and incident rates are non-negative
- `family_engagement_composite` is bounded between 0 and 1

---

## Analysis

After building models, pull the mart into a Jupyter notebook:

```python
import snowflake.connector
import pandas as pd

conn = snowflake.connector.connect(
    account='your_account_id',
    user='your_username',
    password='your_password',
    warehouse='your_warehouse',
    database='CIYJ_ANALYTICS',
    schema='CIYJ_SCHEMA'
)

df = pd.read_sql(
    "SELECT * FROM CIYJ_ANALYTICS.CIYJ_SCHEMA.mart_family_engagement_incidents",
    conn
)
```

Statistical models used:
- **Negative Binomial Regression** (incident rates with youth-days offset)
- **OLS / Beta Regression** (staff turnover)
- **Multilevel Logistic Regression** (youth behavior, nested in facilities)

---

## Environment Variables

| Variable | Description |
|---|---|
| `SNOWFLAKE_PASSWORD` | Snowflake account password |

---

## Notes

- All columns in raw tables are loaded as `VARCHAR` and cast to proper types in the staging layer
- `profiles.yml` is stored in `~/.dbt/` and is never committed to version control
- `ciyj_env/` virtual environment folder should be added to `.gitignore`

---

## Author

**Abby Nyakara**  
ML/AI Engineer & Data Scientist  
Lansing, Michigan
