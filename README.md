<h1>
  <img src="https://www.thiings.co/_next/image?url=https%3A%2F%2Flftz25oez4aqbxpq.public.blob.vercel-storage.com%2Fimage-4kQFEaKNo512mbGmCymn7uvt2HttTE.png&w=2048&q=75" width="100"/>
  SQL Data Warehouse with Medallion Architecture
</h1>

 <h2> 
 <img src="https://www.thiings.co/_next/image?url=https%3A%2F%2Flftz25oez4aqbxpq.public.blob.vercel-storage.com%2Fimage-H3zVpKzbK29AtbWl2npvIMnpDjJqkl.png&w=320&q=75" width="60"/>
Overview
 <h2>

This project demonstrates an end-to-end **ETL pipeline** built using the **Medallion Architecture** within **Microsoft SQL Server** and **SQL Server Management Studio (SSMS)**. The solution transforms raw CRM and ERP datasets (in CSV format) into a clean, analytical **data warehouse** optimized for **BI**, **ad-hoc queries**, and **machine learning**.

---

## 🖼️ Architecture

The warehouse follows the **Medallion Architecture** pattern, which divides data into Bronze, Silver, and Gold layers. Each layer represents a distinct stage of data processing and transformation.

<img src="docs/data_architecture.png" alt="Medallion Architecture Diagram" width="800"/>

- **Bronze Layer**: Raw staging layer for batch ingestion.
- **Silver Layer**: Cleansed and standardized data.
- **Gold Layer**: Business-ready, denormalized views modeled using a **star schema**.

---

## 📥 Data Ingestion

### 🔄 Source Systems

Data is ingested from two structured source systems:

- **CRM (Customer Relationship Management)**
- **ERP (Enterprise Resource Planning)**

Each source contributes 3 CSV files (6 files total) as part of the ETL process:

**CRM Files**
- `cust_info.csv`
- `prd_info.csv`
- `sales_details.csv`

**ERP Files**
- `cust_az12.csv`
- `loc_a101.csv`
- `px_cat_g1v2.csv`

---

## 🔄 ETL Data Pipeline (Bronze → Silver → Gold)

The flow of data through the warehouse is shown below:

<img src="docs/data_flow.png" alt="ETL Data Flow Pipeline" width="800"/>

### 🔸 Bronze Layer (Staging)
- **Object Type**: Tables  
- **Purpose**: Ingest raw CSVs using batch processing  
- **ETL Action**: `TRUNCATE + BULK INSERT`  
- **Transformations**: ❌ None  

### 🔸 Silver Layer (Refined)
- **Object Type**: Tables  
- **Purpose**: Apply transformations and prepare for analytics  
- **ETL Action**: `TRUNCATE + INSERT`  
- **Transformations**:  
  - Data cleaning (nulls, invalid dates)
  - Standardization (e.g., gender, country codes)
  - Derived columns (e.g., `cat_id`)
  - Enrichment via joins across CRM and ERP

### 🔸 Gold Layer (Semantic)
- **Object Type**: Views  
- **Purpose**: Business-facing model for analytics  
- **ETL Action**: Logical views, no data duplication  
- **Transformations**:  
  - Data integration across domains  
  - Business logic and aggregation  
  - Star schema modeling

---

## 🧹 Silver Layer: Data Cleaning & Integration

This layer performs core **data wrangling** tasks to convert raw datasets into structured forms. It includes deduplication, type casting, null handling, and value mapping.

<img src="docs/silver_data_integration.png" alt="Silver Layer Data Integration" width="800"/>

✅ Key Tasks:
- Normalize `gender`, `marital_status`, `country`
- Validate `birthdates`, `sales calculations`
- Generate surrogate and category keys
- Ensure referential integrity between domains

---

## 🌟 Gold Layer: Star Schema

The Gold layer presents data in a **denormalized** format designed for **OLAP**, **dashboards**, and **machine learning pipelines**.

<img src="docs/star_schema.png" alt="Star Schema Design" width="800"/>

### 🔹 Dimension Tables:
- `gold.dim_customers`: Combines customer + demographic + location info  
- `gold.dim_products`: Combines product + category + pricing info  

### 🔸 Fact Table:
- `gold.fact_sales`: Transactional sales fact with foreign key references  

✅ Modeled for performance, accuracy, and compatibility with BI tools.

---

## 📊 Use Cases Enabled

The warehouse supports the following downstream use cases:

- 📈 **Business Intelligence Dashboards** (Power BI, Tableau)
- 🔍 **Ad-Hoc SQL Analytics**
- 🤖 **Machine Learning Models** (e.g., churn, recommendation)
- 🧠 **Data Exploration for Analysts & Scientists**

---

## 🛠️ Tech Stack

| Component        | Tool / Technology                      |
|------------------|----------------------------------------|
| RDBMS            | Microsoft SQL Server                   |
| IDE              | SQL Server Management Studio (SSMS)    |
| Language         | T-SQL (Stored Procedures, Views, DDL)  |
| Ingestion Format | CSV (local flat files)                 |
| Architecture     | Medallion (Bronze → Silver → Gold)     |


---

## 🧪 Execution Order

1. Run DDL scripts to create Bronze, Silver, and Gold schemas
2. Execute: `EXEC bronze.load_bronze;`
3. Execute: `EXEC silver.load_silver;`
4. Run Gold layer view scripts
