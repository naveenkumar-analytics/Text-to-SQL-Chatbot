-- 1. sales_order Table
CREATE TABLE sales_order (
    order_number VARCHAR(20),
    order_date DATE,
    customer_name_index INT,
    channel VARCHAR(50),
    currency_code VARCHAR(10),
    warehouse_code VARCHAR(20),
    delivery_region_index INT,
    product_description_index INT,
    order_quantity INT,
    unit_price DECIMAL(10, 2),
    line_total DECIMAL(12, 2),
    total_unit_cost DECIMAL(10, 3)
);
-- 2. Customers Table
CREATE TABLE customers (
    customer_index INT PRIMARY KEY,
    customer_names VARCHAR(100)
);

-- 3. Products Table
CREATE TABLE products (
    product_index INT PRIMARY KEY,
    product_name VARCHAR(100)
);

-- 4. Regions Table
CREATE TABLE regions (
    id INT PRIMARY KEY,
    name VARCHAR(100),
    county VARCHAR(150),
    state_code VARCHAR(10),
    state VARCHAR(100),
    type VARCHAR(50),
    latitude DECIMAL(9, 6),
    longitude DECIMAL(9, 6),
    area_code INT,
    population BIGINT,
    households BIGINT,
    median_income BIGINT,
    land_area BIGINT,
    water_area BIGINT,
    time_zone VARCHAR(100)
);

-- 5. State Regions Table
CREATE TABLE state_regions (
    state_code VARCHAR(10) PRIMARY KEY,
    state VARCHAR(100),
    region VARCHAR(50)
);

-- 6. 2017 Budgets Table
CREATE TABLE budgets_2017 (
    product_name VARCHAR(100),
    budget_2017 DECIMAL(15, 3)
);

-- 7. Sales Orders Old Table
CREATE TABLE sales_orders_old (
    order_number VARCHAR(20),
    order_date DATE,
    customer_name_index INT,
    channel VARCHAR(50),
    currency_code VARCHAR(10),
    warehouse_code VARCHAR(20),
    delivery_region_index INT,
    product_description_index INT,
    order_quantity INT,
    unit_price DECIMAL(10, 2),
    line_total DECIMAL(12, 2),
    total_unit_cost DECIMAL(10, 3)
);

select sum(line_total) from sales_order;
