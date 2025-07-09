# 📊 Data Catalog – Gold Layer

## 📘 Overview

The **Gold Layer** represents the business-ready, analytical data model in a **star schema** format. It consists of:

- **Dimension tables**: Enriched reference data (customers, products).
- **Fact tables**: Core transactional metrics (sales).

This layer supports dashboards, reporting tools, and advanced analytics use cases.

---

## 📁 Table: `gold.dim_customers`

### 🧩 Purpose  
Stores customer details enriched with **demographic** and **geographic** attributes.

### 📐 Schema

| Column Name       | Data Type     | Description                                                                 |
|-------------------|---------------|-----------------------------------------------------------------------------|
| `customer_key`    | INT           | Surrogate key uniquely identifying each customer record.                    |
| `customer_id`     | INT           | Original ID assigned to the customer.                                       |
| `customer_number` | NVARCHAR(50)  | Alphanumeric reference for tracking customers.                              |
| `first_name`      | NVARCHAR(50)  | Customer's first name.                                                      |
| `last_name`       | NVARCHAR(50)  | Customer's last/family name.                                                |
| `country`         | NVARCHAR(50)  | Customer’s country of residence (e.g., `Australia`).                        |
| `marital_status`  | NVARCHAR(50)  | Customer's marital status (`Single`, `Married`).                            |
| `gender`          | NVARCHAR(50)  | Customer’s gender (`Male`, `Female`, `N/A`).                                |
| `birth_date`      | DATE          | Date of birth (`YYYY-MM-DD`).                                               |
| `create_date`     | DATE          | Date when the customer record was created in the system.                    |

---

## 📁 Table: `gold.dim_products`

### 🧩 Purpose  
Provides details about **products**, including classifications and pricing.

### 📐 Schema

| Column Name            | Data Type     | Description                                                                 |
|------------------------|---------------|-----------------------------------------------------------------------------|
| `product_key`          | INT           | Surrogate key uniquely identifying each product.                            |
| `product_id`           | INT           | Internal product tracking ID.                                               |
| `product_number`       | NVARCHAR(50)  | Alphanumeric product reference.                                             |
| `product_name`         | NVARCHAR(50)  | Product’s descriptive name.                                                 |
| `category_id`          | NVARCHAR(50)  | Identifier linking to high-level product category.                          |
| `category`             | NVARCHAR(50)  | General classification (e.g., `Bikes`).                                     |
| `sub_category`         | NVARCHAR(50)  | Specific product type within the category.                                  |
| `maintenance_required` | NVARCHAR(50)  | Indicates if product requires maintenance (`Yes`, `No`).                    |
| `cost`                 | INT           | Product cost in monetary units.                                             |
| `product_line`         | NVARCHAR(50)  | Product series/line (e.g., `Mountain`, `Road`).                             |
| `start_date`           | DATE          | Date when product became available.                                         |

---

## 📁 Table: `gold.fact_sales`

### 🧩 Purpose  
Stores **transactional sales data** for analytical purposes.

### 📐 Schema

| Column Name     | Data Type     | Description                                                                 |
|-----------------|---------------|-----------------------------------------------------------------------------|
| `order_number`  | NVARCHAR(50)  | Unique alphanumeric ID for each sales order (e.g., `SO54496`).              |
| `product_key`   | INT           | Foreign key linking to `gold.dim_products`.                                 |
| `customer_key`  | INT           | Foreign key linking to `gold.dim_customers`.                                |
| `order_date`    | DATE          | Date when the order was placed.                                             |
| `shipping_date` | DATE          | Date when the order was shipped to the customer.                            |
| `due_date`      | DATE          | Date when the order payment was due.                                        |
| `sales_amount`  | INT           | Total value of the sale (line item), in whole currency units.               |
| `quantity`      | INT           | Number of product units ordered in the line item.                           |
| `price`         | INT           | Price per product unit, in whole currency units.                            |

---
