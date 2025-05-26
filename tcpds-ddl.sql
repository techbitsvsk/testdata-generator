-- TPC-DS 2.10.0 Hive DDL Scripts
-- This script contains CREATE TABLE statements for all 24 TPC-DS tables.
-- Note: Data types are Hive-compatible. Adjust partitioning and storage formats as needed for your environment.

-- 1. CALL_CENTER
CREATE TABLE IF NOT EXISTS call_center (
    cc_call_center_sk         INT,
    cc_call_center_id         STRING,
    cc_rec_start_date         DATE,
    cc_rec_end_date           DATE,
    cc_closed_date_sk         INT,
    cc_open_date_sk           INT,
    cc_name                   STRING,
    cc_class                  STRING,
    cc_employees              INT,
    cc_sq_ft                  INT,
    cc_hours                  STRING,
    cc_manager                STRING,
    cc_mkt_id                 INT,
    cc_mkt_class              STRING,
    cc_mkt_desc               STRING,
    cc_market_manager         STRING,
    cc_division               INT,
    cc_division_name          STRING,
    cc_company                INT,
    cc_company_name           STRING,
    cc_street_number          STRING,
    cc_street_name            STRING,
    cc_street_type            STRING,
    cc_suite_number           STRING,
    cc_city                   STRING,
    cc_county                 STRING,
    cc_state                  STRING,
    cc_
    cc_country                STRING,
    cc_gmt_offset             DECIMAL(5,2),
    cc_tax_percentage         DECIMAL(5,2)
)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY '|'
STORED AS TEXTFILE;

-- 2. CATALOG_PAGE
CREATE TABLE IF NOT EXISTS catalog_page (
    cp_catalog_page_sk        INT,
    cp_catalog_page_id        STRING,
    cp_start_date_sk          INT,
    cp_end_date_sk            INT,
    cp_department             STRING,
    cp_catalog_number         INT,
    cp_catalog_page_number    INT,
    cp_description            STRING,
    cp_type                   STRING
)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY '|'
STORED AS TEXTFILE;

--3. CATALOG_RETURNS
CREATE TABLE IF NOT EXISTS catalog_returns (
    cr_returned_date_sk       BIGINT,
    cr_returned_time_sk       BIGINT,
    cr_item_sk                BIGINT,
    cr_refunded_customer_sk   BIGINT,
    cr_refunded_cdemo_sk      BIGINT,
    cr_refunded_hdemo_sk      BIGINT,
    cr_refunded_addr_sk       BIGINT,
    cr_returning_customer_sk  BIGINT,
    cr_returning_cdemo_sk     BIGINT,
    cr_returning_hdemo_sk     BIGINT,
    cr_returning_addr_sk      BIGINT,
    cr_call_center_sk         BIGINT,
    cr_catalog_page_sk        BIGINT,
    cr_ship_mode_sk           BIGINT,
    cr_warehouse_sk           BIGINT,
    cr_reason_sk              BIGINT,
    cr_order_number           BIGINT,
    cr_return_quantity        INT,
    cr_return_amount          DECIMAL(7,2),
    cr_return_tax             DECIMAL(7,2),
    cr_return_amt_inc_tax     DECIMAL(7,2),
    cr_fee                    DECIMAL(7,2),
    cr_return_ship_cost       DECIMAL(7,2),
    cr_refunded_cash          DECIMAL(7,2),
    cr_reversed_charge        DECIMAL(7,2),
    cr_store_credit           DECIMAL(7,2),
    cr_net_loss               DECIMAL(7,2)
)
COMMENT 'Catalog returns table from TPC-DS benchmark'
ROW FORMAT DELIMITED
FIELDS TERMINATED BY '|'
STORED AS TEXTFILE;

--4. CATALOG_SALES
CREATE TABLE IF NOT EXISTS catalog_sales (
    cs_sold_date_sk           BIGINT,
    cs_sold_time_sk           BIGINT,
    cs_ship_date_sk           BIGINT,
    cs_bill_customer_sk       BIGINT,
    cs_bill_cdemo_sk          BIGINT,
    cs_bill_hdemo_sk          BIGINT,
    cs_bill_addr_sk           BIGINT,
    cs_ship_customer_sk       BIGINT,
    cs_ship_cdemo_sk          BIGINT,
    cs_ship_hdemo_sk          BIGINT,
    cs_ship_addr_sk           BIGINT,
    cs_call_center_sk         BIGINT,
    cs_catalog_page_sk        BIGINT,
    cs_ship_mode_sk           BIGINT,
    cs_warehouse_sk           BIGINT,
    cs_item_sk                BIGINT,
    cs_promo_sk               BIGINT,
    cs_order_number           BIGINT,
    cs_quantity               INT,
    cs_wholesale_cost         DECIMAL(7,2),
    cs_list_price             DECIMAL(7,2),
    cs_sales_price            DECIMAL(7,2),
    cs_ext_discount_amt       DECIMAL(7,2),
    cs_ext_sales_price        DECIMAL(7,2),
    cs_ext_wholesale_cost     DECIMAL(7,2),
    cs_ext_list_price         DECIMAL(7,2),
    cs_ext_tax                DECIMAL(7,2),
    cs_coupon_amt             DECIMAL(7,2),
    cs_ext_ship_cost          DECIMAL(7,2),
    cs_net_paid               DECIMAL(7,2),
    cs_net_paid_inc_tax       DECIMAL(7,2),
    cs_net_paid_inc_ship      DECIMAL(7,2),
    cs_net_paid_inc_ship_tax  DECIMAL(7,2),
    cs_net_profit             DECIMAL(7,2)
)
COMMENT 'Catalog Sales table from TPC-DS benchmark'
ROW FORMAT DELIMITED
FIELDS TERMINATED BY '|'
STORED AS TEXTFILE;

--5. CUSTOMER
CREATE TABLE customer (
    c_customer_sk             BIGINT,
    c_customer_id             CHAR(16),
    c_current_cdemo_sk        BIGINT,
    c_current_hdemo_sk        BIGINT,
    c_current_addr_sk         BIGINT,
    c_first_shipto_date_sk    BIGINT,
    c_first_sales_date_sk     BIGINT,
    c_salutation              CHAR(10),
    c_first_name              CHAR(20),
    c_last_name               CHAR(30),
    c_preferred_cust_flag     CHAR(1),
    c_birth_day               INT,
    c_birth_month             INT,
    c_birth_year              INT,
    c_birth_country           VARCHAR(20),
    c_login                   CHAR(13),
    c_email_address           CHAR(50),
    c_last_review_date_sk     BIGINT
)
COMMENT 'Customer table from TPC-DS benchmark'
ROW FORMAT DELIMITED
FIELDS TERMINATED BY '|'
STORED AS TEXTFILE;

--6. CUSTOMER_ADDRESS
CREATE TABLE customer_address (
    ca_address_sk             BIGINT,
    ca_address_id             CHAR(16),
    ca_street_number          CHAR(10),
    ca_street_name            VARCHAR(60),
    ca_street_type            CHAR(15),
    ca_suite_number           CHAR(10),
    ca_city                   VARCHAR(60),
    ca_county                 VARCHAR(30),
    ca_state                  CHAR(2),
    ca_zip                    CHAR(10),
    ca_country                VARCHAR(20),
    ca_gmt_offset             DECIMAL(5,2),
    ca_location_type          CHAR(20)
)
COMMENT 'Customer Address table from TPC-DS benchmark'
ROW FORMAT DELIMITED
FIELDS TERMINATED BY '|'
STORED AS TEXTFILE;

--7.CUSTOMER_DEMOGRAPHICS
CREATE TABLE customer_demographics (
    cd_demo_sk                BIGINT,
    cd_gender                 CHAR(1),
    cd_marital_status         CHAR(1),
    cd_education_status       CHAR(20),
    cd_purchase_estimate      INT,
    cd_credit_rating          CHAR(10),
    cd_dep_count              INT,
    cd_dep_employed_count     INT,
    cd_dep_college_count      INT
)
COMMENT 'Customer Demographics table from TPC-DS benchmark'
ROW FORMAT DELIMITED
FIELDS TERMINATED BY '|'
STORED AS TEXTFILE;

--8. DATE_DIM
CREATE TABLE date_dim (
    d_date_sk                 BIGINT,
    d_date_id                 CHAR(16),
    d_date                    DATE,
    d_month_seq               INT,
    d_week_seq                INT,
    d_quarter_seq             INT,
    d_year                    INT,
    d_dow                     INT,
    d_moy                     INT,
    d_dom                     INT,
    d_qoy                     INT,
    d_fy_year                 INT,
    d_fy_quarter_seq          INT,
    d_fy_week_seq             INT,
    d_day_name                CHAR(9),
    d_quarter_name            CHAR(6),
    d_holiday                 CHAR(1),
    d_weekend                 CHAR(1),
    d_following_holiday       CHAR(1),
    d_first_dom               INT,
    d_last_dom                INT,
    d_same_day_ly             INT,
    d_same_day_lq             INT,
    d_current_day             CHAR(1),
    d_current_week            CHAR(1),
    d_current_month           CHAR(1),
    d_current_quarter         CHAR(1),
    d_current_year            CHAR(1)
)
COMMENT 'Date Dimension table from TPC-DS benchmark'
ROW FORMAT DELIMITED
FIELDS TERMINATED BY '|'
STORED AS TEXTFILE;

--9. HOUSEHOLD_DEMOGRAPHICS
CREATE TABLE household_demographics (
    hd_demo_sk                BIGINT,
    hd_income_band_sk         BIGINT,
    hd_buy_potential          CHAR(15),
    hd_dep_count              INT,
    hd_vehicle_count          INT
)
COMMENT 'Household Demographics table from TPC-DS benchmark'
ROW FORMAT DELIMITED
FIELDS TERMINATED BY '|'
STORED AS TEXTFILE;

--10. INCOME_BAND
CREATE TABLE income_band (
    ib_income_band_sk         BIGINT,
    ib_lower_bound            INT,
    ib_upper_bound            INT
)
COMMENT 'Income Band table from TPC-DS benchmark'
ROW FORMAT DELIMITED
FIELDS TERMINATED BY '|'
STORED AS TEXTFILE;

--11. Inventory
CREATE TABLE inventory (
    inv_item_sk               BIGINT,
    inv_warehouse_sk          BIGINT,
    inv_quantity_on_hand      INT
)
COMMENT 'Inventory table from TPC-DS benchmark'
PARTITIONED BY (inv_date_sk BIGINT)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY '|'
STORED AS TEXTFILE;

--12. ITEM
CREATE TABLE item (
    i_item_sk                 BIGINT,
    i_item_id                 CHAR(16),
    i_rec_start_date          DATE,
    i_rec_end_date            DATE,
    i_item_desc               VARCHAR(200),
    i_current_price           DECIMAL(7,2),
    i_wholesale_cost          DECIMAL(7,2),
    i_brand_id                INT,
    i_brand                   CHAR(50),
    i_class_id                INT,
    i_class                   CHAR(50),
    i_category_id             INT,
    i_category                CHAR(50),
    i_manufact_id             INT,
    i_manufact                CHAR(50),
    i_size                    CHAR(20),
    i_formulation             CHAR(20),
    i_color                   CHAR(20),
    i_units                   CHAR(10),
    i_container               CHAR(10),
    i_manager_id              INT,
    i_product_name            CHAR(50)
)
COMMENT 'Item table from TPC-DS benchmark'
ROW FORMAT DELIMITED
FIELDS TERMINATED BY '|'
STORED AS TEXTFILE;

--13. promotion
CREATE TABLE promotion (
    p_promo_sk                BIGINT,
    p_promo_id                CHAR(16),
    p_start_date_sk           BIGINT,
    p_end_date_sk             BIGINT,
    p_item_sk                 BIGINT,
    p_cost                    DECIMAL(15,2),
    p_response_target         INT,
    p_promo_name              CHAR(50),
    p_channel_dmail           CHAR(1),
    p_channel_email           CHAR(1),
    p_channel_catalog         CHAR(1),
    p_channel_tv              CHAR(1),
    p_channel_radio           CHAR(1),
    p_channel_press           CHAR(1),
    p_channel_event           CHAR(1),
    p_channel_demo            CHAR(1),
    p_channel_details         VARCHAR(100),
    p_purpose                 CHAR(15),
    p_discount_active         CHAR(1)
)
COMMENT 'Promotion table from TPC-DS benchmark'
ROW FORMAT DELIMITED
FIELDS TERMINATED BY '|'
STORED AS TEXTFILE;

--14. Reason
CREATE TABLE reason (
    r_reason_sk               BIGINT,
    r_reason_id               CHAR(16),
    r_reason_desc             CHAR(100)
)
COMMENT 'Reason table from TPC-DS benchmark, describes reasons for returns'
ROW FORMAT DELIMITED
FIELDS TERMINATED BY '|'
STORED AS TEXTFILE;

--15.ship_mode
CREATE TABLE ship_mode (
    sm_ship_mode_sk           BIGINT,
    sm_ship_mode_id           CHAR(16),
    sm_type                   CHAR(30),
    sm_code                   CHAR(10),
    sm_carrier                CHAR(20),
    sm_contract               CHAR(20)
)
COMMENT 'Ship Mode table from TPC-DS benchmark'
ROW FORMAT DELIMITED
FIELDS TERMINATED BY '|'
STORED AS TEXTFILE;


