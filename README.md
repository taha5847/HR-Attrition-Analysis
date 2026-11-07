# HR Employee Attrition Analysis

An end-to-end HR analytics project: **Python** for cleaning and feature engineering, **SQL Server** for analysis, and **Power BI** for an interactive dashboard.

The goal is to find out **who is leaving the company and why**, so HR can focus retention efforts where they matter most.

---

## Project at a glance

| Item | Detail |
|---|---|
| Dataset | IBM HR Analytics Employee Attrition (public sample dataset, fictional employees) |
| Records | 1,470 employees |
| Overall attrition | **16.12%** (237 left, 1,233 stayed) |
| Tools | Python (pandas), SQL Server (T-SQL), Power BI |
| Dashboard | 4 pages, 1720 x 1100 canvas, shared slicers and page navigation |

> The data is a public sample released by IBM for learning. This project is not an official IBM report.

---

## Repository contents

| File | Purpose |
|---|---|
| `HR-Employee-Attrition.csv` | Original raw dataset (35 columns) |
| `hr_attrition.ipynb` | Python notebook: cleaning, feature engineering, first exploration |
| `hr_data.csv` | Output of the notebook: cleaned dataset with new columns (43 columns) |
| `HR_Analysis.sql` | SQL Server queries for exploratory analysis (about 18 queries) |
| `HR_Dashboard.pbix` | Power BI dashboard built on `hr_data` |

`HR-Employee-Attrition_1.csv` is an exact duplicate of the original file and can be deleted.

---

## Workflow

```
HR-Employee-Attrition.csv
        |
        v   Python (pandas): clean + feature engineering
   hr_data.csv
        |
        v   Load into SQL Server table `hr_data`
  HR_Analysis.sql  (EDA and KPIs)
        |
        v   Connect Power BI to `hr_data`
  HR_Dashboard.pbix
```

### 1. Python: data preparation (`hr_attrition.ipynb`)

**Cleaning**
- Dropped 3 columns that never change: `EmployeeCount`, `Over18`, `StandardHours`
- Data quality check: no missing values and no duplicate rows

**Feature engineering (11 new columns)**

| New column | How it was created |
|---|---|
| `Attrition_Flag` | 1 if `Attrition` = Yes, else 0 (makes rates easy to calculate) |
| `Age_Group` | `pd.cut` on Age: 18-25, 26-35, 36-45, 46-55, 56-60 |
| `MonthlyIncome_Band` | `pd.cut` on MonthlyIncome: see the known issue below about the first label |
| `Tenure_Band` | `pd.cut` on YearsAtCompany: 0-2, 3-5, 6-10, 11-20, 20+ |
| `EnvironmentSatisfaction_label` | 1-4 mapped to Low, Medium, High, Very High |
| `JobSatisfaction_label` | same mapping |
| `RelationshipSatisfaction_label` | same mapping |
| `JobInvolvement_label` | same mapping |
| `WorkLifeBalance_label` | 1-4 mapped to Bad, Good, Better, Best |
| `PerformanceRating_label` | 1-4 mapped to Low, Good, Excellent, Outstanding (only Excellent and Outstanding appear) |
| `Education_label` | 1-5 mapped to Below College, College, Bachelor, Master, Doctor |

The original numeric columns were kept next to the labels, so averages and sorting still work.

### 2. SQL Server: analysis (`HR_Analysis.sql`)

The cleaned file was loaded into a table named `hr_data`. `Attrition_Flag` was stored as 1/0, and the `Attrition` column was converted to Yes/No text.

Questions answered, from basic to advanced:

| Level | Topics |
|---|---|
| Basic | Total employees, left vs. stayed, overall attrition %, headcount by department, min/max/avg income |
| Group by | Attrition by department, overtime, job role, gender split, tenure of leavers vs. stayers |
| Intermediate | Roles above company average (HAVING + subquery), income by role and gender, gender pay gap, overtime x marital status, attrition by income band, departments with more than 100 employees and rate above 15% |
| Advanced | CTE + `RANK() OVER (PARTITION BY Department ...)` to rank job roles by attrition within each department |

### 3. Power BI: dashboard (`HR_Dashboard.pbix`)

All visuals use a shared measures table (`Measures Table 1`) with these measures: **Total Employees, Leavers, Attrition Rate, Average Income, Average Age, Average Tenure**.

Every page has the same header: logo, page navigator, a back button, and slicers for **Age Group, Education Field, Gender, Department, and Job Role**.

| Page | Visuals |
|---|---|
| **Executive Overview** | 6 KPI cards; attrition rate by department; attrition rate by job role; headcount by gender (donut); headcount by age group |
| **Attrition Drivers** | Attrition rate by overtime, marital status, business travel, tenure band, and income band; matrix of attrition vs. job satisfaction |
| **Compensation & Promotion** | Average income by job level and gender; monthly income by job role; salary hike % by performance rating; attrition vs. years since last promotion; attrition by stock option level |
| **Employee Details** | Employee-level table (EmployeeNumber, Department, JobRole, MonthlyIncome, OverTime, YearsAtCompany, Attrition_Flag) |

---

## Key findings

All figures below were recalculated from `hr_data.csv`.

**1. Overall:** 16.12% of employees left (237 of 1,470).

**2. Overtime is the strongest single driver.** Employees who work overtime leave at **30.5%** vs. **10.4%** for those who don't, about 3 times higher. Single employees working overtime leave at **49.6%** (131 people).

**3. Sales and a few specific roles carry the risk.**

| Job role | Attrition rate |
|---|---|
| Sales Representative | **39.8%** |
| Laboratory Technician | 23.9% |
| Human Resources | 23.1% |
| Sales Executive | 17.5% |
| Research Scientist | 16.1% |
| Healthcare Representative | 6.9% |
| Manufacturing Director | 6.9% |
| Manager | 4.9% |
| Research Director | 2.5% |

By department: Sales 20.6%, Human Resources 19.0%, Research & Development 13.8%.

**4. New and young employees leave most.**
- 0-2 years at the company: **29.8%** (vs. 6.7% for 11-20 years)
- Age 18-25: **35.8%** (vs. 9.2% for age 36-45)

**5. Low pay goes with high attrition.** The lowest income band (under 3,000) has **28.6%** attrition vs. **8.9%** for the 10,000-20,000 band. Leavers earned on average 4,787 vs. 6,833 for stayers.

**6. Other risk factors**
- Single: 25.5% (married 12.5%, divorced 10.1%)
- Frequent business travel: 24.9% (non-travel 8.0%)
- Low job satisfaction: 22.8% (very high satisfaction 11.3%)
- Bad work-life balance: 31.2%
- No stock options: 24.4% (level 1 and 2: 9.4% and 7.6%)

**7. No meaningful gender pay gap within job levels.** Differences between men and women are under about 3% at every level and do not consistently favor one gender. Overall average pay is slightly higher for women (6,687 vs. 6,381) because of how women are spread across levels. Attrition is 17.0% for men and 14.8% for women.

### Suggested actions
1. Review overtime workloads, especially for single and junior employees.
2. Investigate the Sales Representative role (pay, targets, management).
3. Strengthen onboarding and mentoring in the first 2 years.
4. Review pay for the lowest income band and the role of stock options.
5. Monitor frequent travelers and employees with low satisfaction or bad work-life balance.

---

## Known issues and improvements

**Data**
- The first income band label is `>3k`, but it contains incomes **below** 3,000. It should be `<3k`. The same label is used in SQL and Power BI, so fix it in the notebook (`labels = ['<3k', ...]`), regenerate `hr_data.csv`, and refresh the table and report.
- `Distance_Band` was planned but was not created.
- `MonthlyRate` (and `DailyRate`, `HourlyRate`) do not relate to income in this dataset and are better ignored in analysis.

**SQL (`HR_Analysis.sql`)**
- **Integer division:** several rate queries use `100 * SUM(...) / COUNT(...)` with whole numbers, so SQL Server truncates the result and `ROUND` has no effect. Use `100.0 *` instead, as in the gender split query.
- The **attrition by department** query does not select `Department`, so the rows are not labeled.
- The **average income by job level and gender** query groups by `JobRole`, not `JobLevel`.
- The **gap** query uses `ABS()`, which hides the direction of the gap. Female minus Male shows who earns more.
- The **earn less than the average of their own job role** query compares with the company-wide average, not the role average. Use a correlated subquery or `AVG(MonthlyIncome) OVER (PARTITION BY JobRole)`.
- **Job roles above company average** appears twice, and the first version has no filter.
- `UPDATE` statements that convert Attrition from 1/0 to Yes/No are included in the analysis script. Move them to a separate setup script, because re-running them in order can fail on text values.

**Power BI**
- **Employee Details** is a normal page. It is not set up as a drill-through page, so right-clicking a bar will not open it filtered. To add that, put Department and JobRole in the page's **Drill through** well.
- Several charts have no title. Add titles that state the finding (for example, "Overtime triples attrition risk").
- Add a reference line at the company average (16.12%) on the attrition rate charts.
- Show headcount in tooltips, because small groups (for example, 11 HR Managers) can make rates misleading.
- The DAX measure definitions are stored in the compressed data model, so they could not be listed here. Document them in the repository if you want others to reuse them.

**Next steps**
- Build an attrition prediction model (for example, logistic regression or random forest) and add risk scores to the dashboard.
- Add a Distance-from-home analysis and a high-risk profile list (overtime + single + under 3 years + low satisfaction).

---

## How to reproduce

1. **Python:** open `hr_attrition.ipynb`, run all cells with `HR-Employee-Attrition.csv` in the same folder. This writes `hr_data.csv`. Requires `pandas` and `numpy`.
2. **SQL Server:** import `hr_data.csv` into a table named `hr_data` (SSMS Import Flat File, or `pandas.to_sql`), then run `HR_Analysis.sql`.
3. **Power BI:** open `HR_Dashboard.pbix`, update the data source to your server or CSV path, and click **Refresh**.

---

## Skills demonstrated

Data cleaning and feature engineering (pandas), T-SQL (aggregation, CASE WHEN, HAVING, subqueries, CTEs, window functions), DAX measures, dashboard design (KPI cards, slicers, navigation, multi-page layout), and turning data into business recommendations.
