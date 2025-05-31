-- ==============================================================================
-- TPC-DS Iceberg Table DDLs (All 24 Tables)
--
-- Notes:
-- | Table Name              | Table Type | Key Columns (Surrogate Keys / Important)                    | Partitioning / Bucketing Details                                       |
-- | ----------------------- | ---------- | ----------------------------------------------------------- | ---------------------------------------------------------------------- |
-- | store_sales            | Fact       | ss_sold_date_sk, ss_store_sk, ss_customer_sk                 | `years(ss_sold_date_sk)`, bucket on ss_store_sk optional               |
-- | store_returns          | Fact       | sr_returned_date_sk, sr_store_sk, sr_customer_sk             | `years(sr_returned_date_sk)`, bucket on sr_store_sk optional           |
-- | catalog_sales          | Fact       | cs_sold_date_sk, cs_catalog_page_sk, cs_customer_sk          | `years(cs_sold_date_sk)`, bucket on cs_catalog_page_sk optional        |
-- | catalog_returns        | Fact       | cr_returned_date_sk, cr_catalog_page_sk                      | `years(cr_returned_date_sk)`, bucket on cr_catalog_page_sk optional    |
-- | web_sales              | Fact       | ws_sold_date_sk, ws_web_page_sk, ws_customer_sk              | `years(ws_sold_date_sk)`, bucket on ws_web_page_sk optional            |
-- | web_returns            | Fact       | wr_returned_date_sk, wr_web_page_sk                          | `years(wr_returned_date_sk)`, bucket on wr_web_page_sk optional        |
-- | inventory              | Fact       | inv_date_sk, inv_item_sk, inv_warehouse_sk                   | `days(inv_date_sk)`, bucket on inv_warehouse_sk optional               |
-- | store                  | Dimension  | s_store_sk                                                   | *No partitioning or bucketing*                                         |
-- | call_center            | Dimension  | cc_call_center_sk                                            | *No partitioning or bucketing*                                         |
-- | catalog_page           | Dimension  | cp_catalog_page_sk                                           | *No partitioning or bucketing*                                         |
-- | web_site               | Dimension  | web_site_sk                                                  | *No partitioning or bucketing*                                         |
-- | web_page               | Dimension  | wp_web_page_sk                                               | *No partitioning or bucketing*                                         |
-- | warehouse              | Dimension  | w_warehouse_sk                                               | `bucket(8, w_warehouse_sk)`                                            |
-- | customer               | Dimension  | c_customer_sk                                                | `bucket(16, c_customer_sk)`                                            |
-- | customer_address       | Dimension  | ca_address_sk                                                | `bucket(16, ca_address_sk)`                                            |
-- | customer_demographics  | Dimension  | cd_demo_sk                                                   | `bucket(8, cd_demo_sk)`                                                |
-- | household_demographics | Dimension  | hd_demo_sk                                                   | `bucket(8, hd_demo_sk)`                                                |
-- | item                   | Dimension  | i_item_sk                                                    | `bucket(32, i_item_sk)`                                                |
-- | income_band            | Dimension  | ib_income_band_sk                                            | *No partitioning or bucketing*                                         |
-- | promotion              | Dimension  | p_promo_sk                                                   | `bucket(8, p_promo_sk)`                                                |
-- | reason                 | Dimension  | r_reason_sk                                                  | *No partitioning or bucketing*                                         |
-- | ship_mode              | Dimension  | sm_ship_mode_sk                                              | *No partitioning or bucketing*                                         |
-- | time_dim               | Dimension  | t_time_sk                                                    | *No partitioning or bucketing*                                         |
-- | date_dim               | Dimension  | d_date_sk, d_date                                            | `years(d_date)`                                                        |

-- - The number of buckets in bucket(N, col) should be tuned based on cardinality
--   and data size.
--  https://www.tpc.org/tpc_documents_current_versions/pdf/tpc-ds_v2.7.0.pdf
-- ==============================================================================

-- ==============================================================================
-- Fact Tables (7)
-- ==============================================================================

-- ------------------------------------------------------------------------------
-- store_sales (ss)
-- Partitioning: By month of sale, then bucketed by item and customer.
-- ------------------------------------------------------------------------------
CREATE TABLE tps.ds.store_sales (
  ss_sold_date_sk       BIGINT,
  ss_sold_time_sk       BIGINT,
  ss_item_sk            BIGINT,
  ss_customer_sk        BIGINT,
  ss_cdemo_sk           BIGINT,
  ss_hdemo_sk           BIGINT,
  ss_addr_sk            BIGINT,
  ss_store_sk           BIGINT,
  ss_promo_sk           BIGINT,
  ss_ticket_number      BIGINT,
  ss_quantity           INTEGER,
  ss_wholesale_cost     DECIMAL(7,2),
  ss_list_price         DECIMAL(7,2),
  ss_sales_price        DECIMAL(7,2),
  ss_ext_discount_amt   DECIMAL(7,2),
  ss_ext_sales_price    DECIMAL(7,2),
  ss_ext_wholesale_cost DECIMAL(7,2),
  ss_ext_list_price     DECIMAL(7,2),
  ss_ext_tax            DECIMAL(7,2),
  ss_coupon_amt         DECIMAL(7,2),
  ss_net_paid           DECIMAL(7,2),
  ss_net_paid_inc_tax   DECIMAL(7,2),
  ss_net_profit         DECIMAL(7,2)
)
USING iceberg
PARTITIONED BY (
  bucket(16, ss_item_sk),           -- Optimizes joins & filters on item
  bucket(16, ss_store_sk),          -- Optimizes store-level queries
  days(ss_sold_date_sk)             -- Prunes by date; assuming it's an epoch date
) 
TBLPROPERTIES (
  'format-version' = '2',           -- Enable features like row-level deletes
  'write.format.default' = 'parquet',
  'write.target-file-size-bytes' = '134217728',  -- 128 MB target files
  'write.metadata.compression-codec' = 'zstd',
  'write.parquet.compression-codec' = 'zstd',
  'read.split.target-size' = '134217728'
);

-- ------------------------------------------------------------------------------
-- store_returns (sr)
-- Partitioning: By month of return, then bucketed by item and customer.
-- ------------------------------------------------------------------------------
CREATE TABLE tps.ds.store_returns (
  sr_returned_date_sk     BIGINT,
  sr_return_time_sk       BIGINT,
  sr_item_sk              BIGINT,
  sr_customer_sk          BIGINT,
  sr_cdemo_sk             BIGINT,
  sr_hdemo_sk             BIGINT,
  sr_addr_sk              BIGINT,
  sr_store_sk             BIGINT,
  sr_reason_sk            BIGINT,
  sr_ticket_number        BIGINT,
  sr_return_quantity      INTEGER,
  sr_return_amt           DECIMAL(7,2),
  sr_return_tax           DECIMAL(7,2),
  sr_return_amt_inc_tax   DECIMAL(7,2),
  sr_fee                  DECIMAL(7,2),
  sr_return_ship_cost     DECIMAL(7,2),
  sr_refunded_cash        DECIMAL(7,2),
  sr_reversed_charge      DECIMAL(7,2),
  sr_store_credit         DECIMAL(7,2),
  sr_net_loss             DECIMAL(7,2)
)
USING iceberg
PARTITIONED BY (
  bucket(16, sr_item_sk),             -- Helps with item-level filtering
  bucket(16, sr_store_sk),            -- Store-level partitioning
  days(sr_returned_date_sk)           -- Enables date pruning
)
TBLPROPERTIES (
  'format-version' = '2',
  'write.format.default' = 'parquet',
  'write.target-file-size-bytes' = '134217728',  -- 128MB
  'write.parquet.compression-codec' = 'zstd',
  'write.metadata.compression-codec' = 'zstd',
  'read.split.target-size' = '134217728'
);

-- ------------------------------------------------------------------------------
-- catalog_sales (cs)
-- Partitioning: By month of sale, then bucketed by item and customer.
-- ------------------------------------------------------------------------------
CREATE TABLE tps.ds.catalog_sales (
  cs_sold_date_sk          BIGINT,
  cs_sold_time_sk          BIGINT,
  cs_ship_date_sk          BIGINT,
  cs_bill_customer_sk      BIGINT,
  cs_bill_cdemo_sk         BIGINT,
  cs_bill_hdemo_sk         BIGINT,
  cs_bill_addr_sk          BIGINT,
  cs_ship_customer_sk      BIGINT,
  cs_ship_cdemo_sk         BIGINT,
  cs_ship_hdemo_sk         BIGINT,
  cs_ship_addr_sk          BIGINT,
  cs_call_center_sk        BIGINT,
  cs_catalog_page_sk       BIGINT,
  cs_ship_mode_sk          BIGINT,
  cs_warehouse_sk          BIGINT,
  cs_item_sk               BIGINT,
  cs_promo_sk              BIGINT,
  cs_order_number          BIGINT,
  cs_quantity              INTEGER,
  cs_wholesale_cost        DECIMAL(7,2),
  cs_list_price            DECIMAL(7,2),
  cs_sales_price           DECIMAL(7,2),
  cs_ext_discount_amt      DECIMAL(7,2),
  cs_ext_sales_price       DECIMAL(7,2),
  cs_ext_wholesale_cost    DECIMAL(7,2),
  cs_ext_list_price        DECIMAL(7,2),
  cs_ext_tax               DECIMAL(7,2),
  cs_coupon_amt            DECIMAL(7,2),
  cs_ext_ship_cost         DECIMAL(7,2),
  cs_net_paid              DECIMAL(7,2),
  cs_net_paid_inc_tax      DECIMAL(7,2),
  cs_net_paid_inc_ship     DECIMAL(7,2),
  cs_net_paid_inc_ship_tax DECIMAL(7,2),
  cs_net_profit            DECIMAL(7,2)
)
USING iceberg
PARTITIONED BY (
  bucket(16, cs_item_sk),          -- High cardinality key, useful for joins and filtering
  bucket(16, cs_warehouse_sk),     -- Shipping warehouse filters
  days(cs_sold_date_sk)            -- Enables partition pruning by sale date
)
TBLPROPERTIES (
  'format-version' = '2',
  'write.format.default' = 'parquet',
  'write.parquet.compression-codec' = 'zstd',
  'write.metadata.compression-codec' = 'zstd',
  'write.target-file-size-bytes' = '134217728',     -- 128 MB files
  'read.split.target-size' = '134217728'
);


-- ------------------------------------------------------------------------------
-- catalog_returns (cr)
-- Partitioning: By month of return, then bucketed by item and customer.
-- ------------------------------------------------------------------------------
CREATE TABLE tps.ds.catalog_returns (
  cr_returned_date_sk      BIGINT,
  cr_returned_time_sk      BIGINT,
  cr_item_sk               BIGINT,
  cr_refunded_customer_sk  BIGINT,
  cr_refunded_cdemo_sk     BIGINT,
  cr_refunded_hdemo_sk     BIGINT,
  cr_refunded_addr_sk      BIGINT,
  cr_returning_customer_sk BIGINT,
  cr_returning_cdemo_sk    BIGINT,
  cr_returning_hdemo_sk    BIGINT,
  cr_returning_addr_sk     BIGINT,
  cr_call_center_sk        BIGINT,
  cr_catalog_page_sk       BIGINT,
  cr_ship_mode_sk          BIGINT,
  cr_warehouse_sk          BIGINT,
  cr_reason_sk             BIGINT,
  cr_order_number          BIGINT,
  cr_return_quantity       INTEGER,
  cr_return_amount         DECIMAL(7,2),
  cr_return_tax            DECIMAL(7,2),
  cr_return_amt_inc_tax    DECIMAL(7,2),
  cr_fee                   DECIMAL(7,2),
  cr_return_ship_cost      DECIMAL(7,2),
  cr_refunded_cash         DECIMAL(7,2),
  cr_reversed_charge       DECIMAL(7,2),
  cr_store_credit          DECIMAL(7,2),
  cr_net_loss              DECIMAL(7,2)
)
USING iceberg
PARTITIONED BY (
  bucket(16, cr_item_sk),           -- High-cardinality, common join/filter key
  bucket(16, cr_warehouse_sk),      -- Optimizes queries involving return logistics
  days(cr_returned_date_sk)         -- Enables date pruning for time-series queries
)
TBLPROPERTIES (
  'format-version' = '2',
  'write.format.default' = 'parquet',
  'write.parquet.compression-codec' = 'zstd',
  'write.metadata.compression-codec' = 'zstd',
  'write.target-file-size-bytes' = '134217728',  -- 128 MB files
  'read.split.target-size' = '134217728'
);


-- ------------------------------------------------------------------------------
-- web_sales (ws)
-- Partitioning: By month of sale, then bucketed by item and customer.
-- ------------------------------------------------------------------------------
CREATE TABLE tps.ds.web_sales (
  ws_sold_date_sk          BIGINT,
  ws_sold_time_sk          BIGINT,
  ws_ship_date_sk          BIGINT,
  ws_item_sk               BIGINT,
  ws_bill_customer_sk      BIGINT,
  ws_bill_cdemo_sk         BIGINT,
  ws_bill_hdemo_sk         BIGINT,
  ws_bill_addr_sk          BIGINT,
  ws_ship_customer_sk      BIGINT,
  ws_ship_cdemo_sk         BIGINT,
  ws_ship_hdemo_sk         BIGINT,
  ws_ship_addr_sk          BIGINT,
  ws_web_page_sk           BIGINT,
  ws_web_site_sk           BIGINT,
  ws_ship_mode_sk          BIGINT,
  ws_warehouse_sk          BIGINT,
  ws_promo_sk              BIGINT,
  ws_order_number          BIGINT,
  ws_quantity              INTEGER,
  ws_wholesale_cost        DECIMAL(7,2),
  ws_list_price            DECIMAL(7,2),
  ws_sales_price           DECIMAL(7,2),
  ws_ext_discount_amt      DECIMAL(7,2),
  ws_ext_sales_price       DECIMAL(7,2),
  ws_ext_wholesale_cost    DECIMAL(7,2),
  ws_ext_list_price        DECIMAL(7,2),
  ws_ext_tax               DECIMAL(7,2),
  ws_coupon_amt            DECIMAL(7,2),
  ws_ext_ship_cost         DECIMAL(7,2),
  ws_net_paid              DECIMAL(7,2),
  ws_net_paid_inc_tax      DECIMAL(7,2),
  ws_net_paid_inc_ship     DECIMAL(7,2),
  ws_net_paid_inc_ship_tax DECIMAL(7,2),
  ws_net_profit            DECIMAL(7,2)
)
USING iceberg
PARTITIONED BY (
  bucket(16, ws_item_sk),          -- Improves join/filter performance on item
  bucket(16, ws_warehouse_sk),     -- Useful for fulfillment center filtering
  days(ws_sold_date_sk)            -- Enables efficient pruning for time-based queries
)
TBLPROPERTIES (
  'format-version' = '2',
  'write.format.default' = 'parquet',
  'write.parquet.compression-codec' = 'zstd',
  'write.metadata.compression-codec' = 'zstd',
  'write.target-file-size-bytes' = '134217728',  -- 128 MB
  'read.split.target-size' = '134217728'
);


-- ------------------------------------------------------------------------------
-- web_returns (wr)
-- Partitioning: By month of return, then bucketed by item and customer.
-- ------------------------------------------------------------------------------
CREATE TABLE tps.ds.web_returns (
  wr_returned_date_sk      BIGINT,
  wr_returned_time_sk      BIGINT,
  wr_item_sk               BIGINT,
  wr_refunded_customer_sk  BIGINT,
  wr_refunded_cdemo_sk     BIGINT,
  wr_refunded_hdemo_sk     BIGINT,
  wr_refunded_addr_sk      BIGINT,
  wr_returning_customer_sk BIGINT,
  wr_returning_cdemo_sk    BIGINT,
  wr_returning_hdemo_sk    BIGINT,
  wr_returning_addr_sk     BIGINT,
  wr_web_page_sk           BIGINT,
  wr_reason_sk             BIGINT,
  wr_order_number          BIGINT,
  wr_return_quantity       INTEGER,
  wr_return_amt            DECIMAL(7,2),
  wr_return_tax            DECIMAL(7,2),
  wr_return_amt_inc_tax    DECIMAL(7,2),
  wr_fee                   DECIMAL(7,2),
  wr_return_ship_cost      DECIMAL(7,2),
  wr_refunded_cash         DECIMAL(7,2),
  wr_reversed_charge       DECIMAL(7,2),
  wr_account_credit        DECIMAL(7,2),
  wr_net_loss              DECIMAL(7,2)
)
USING iceberg
PARTITIONED BY (
  bucket(16, wr_item_sk),           -- Improves filtering and joins on item
  bucket(16, wr_returning_customer_sk), -- Good for customer-level return analysis
  days(wr_returned_date_sk)         -- Prunes partitions efficiently by return date
)
TBLPROPERTIES (
  'format-version' = '2',
  'write.format.default' = 'parquet',
  'write.parquet.compression-codec' = 'zstd',
  'write.metadata.compression-codec' = 'zstd',
  'write.target-file-size-bytes' = '134217728',  -- 128 MB file size
  'read.split.target-size' = '134217728'
);


-- ------------------------------------------------------------------------------
-- inventory (inv)
-- Partitioning: By day of inventory snapshot, warehouse, then bucketed by item.
-- ------------------------------------------------------------------------------
CREATE TABLE tps.ds.inventory (
  inv_date_sk       BIGINT,
  inv_item_sk       BIGINT,
  inv_warehouse_sk  BIGINT,
  inv_quantity_on_hand INTEGER
)
USING iceberg
PARTITIONED BY (
  days(inv_date_sk),               -- Enables time-based partition pruning
  bucket(16, inv_item_sk),         -- Efficient item-level filtering and joins
  bucket(8, inv_warehouse_sk)      -- Useful for warehouse/location analysis
)
TBLPROPERTIES (
  'format-version' = '2',
  'write.format.default' = 'parquet',
  'write.parquet.compression-codec' = 'zstd',
  'write.metadata.compression-codec' = 'zstd',
  'write.target-file-size-bytes' = '134217728',   -- 128 MB
  'read.split.target-size' = '134217728'
);


-- ==============================================================================
-- Dimension Tables (17)
-- ==============================================================================

-- ------------------------------------------------------------------------------
-- store (s)
-- Partitioning: Bucketed by store_sk, then by state.
-- ------------------------------------------------------------------------------
CREATE TABLE tps.ds.store (
  s_store_sk        BIGINT,
  s_store_id        STRING,
  s_rec_start_date  DATE,
  s_rec_end_date    DATE,
  s_closed_date_sk  BIGINT,
  s_store_name      STRING,
  s_number_employees INTEGER,
  s_floor_space     INTEGER,
  s_hours           STRING,
  s_manager         STRING,
  s_market_id       INTEGER,
  s_geography_class STRING,
  s_market_desc     STRING,
  s_market_manager  STRING,
  s_division_id     INTEGER,
  s_division_name   STRING,
  s_company_id      INTEGER,
  s_company_name    STRING,
  s_street_number   STRING,
  s_street_name     STRING,
  s_street_type     STRING,
  s_suite_number    STRING,
  s_city            STRING,
  s_county          STRING,
  s_state           STRING,
  s_zip             STRING,
  s_country         STRING,
  s_gmt_offset      DECIMAL(5,2),
  s_tax_precentage  DECIMAL(5,2)
)
USING iceberg
PARTITIONED BY (
  bucket(8, s_store_sk)  -- Optional: Helps with distributed query planning in large environments
)
TBLPROPERTIES (
  'format-version' = '2',
  'write.format.default' = 'parquet',
  'write.parquet.compression-codec' = 'zstd',
  'write.metadata.compression-codec' = 'zstd',
  'write.target-file-size-bytes' = '67108864'   -- 64 MB file size for dimension tables
);


-- ------------------------------------------------------------------------------
-- call_center (cc)
-- Partitioning: Bucketed by call_center_sk.
-- ------------------------------------------------------------------------------
CREATE TABLE tps.ds.call_center (
  cc_call_center_sk       BIGINT,
  cc_call_center_id       STRING,
  cc_rec_start_date       DATE,
  cc_rec_end_date         DATE,
  cc_closed_date_sk       BIGINT,
  cc_open_date_sk         BIGINT,
  cc_name                 STRING,
  cc_class                STRING,
  cc_employees            INTEGER,
  cc_sq_ft                INTEGER,
  cc_hours                STRING,
  cc_manager              STRING,
  cc_mkt_id               INTEGER,
  cc_mkt_class            STRING,
  cc_mkt_desc             STRING,
  cc_market_manager       STRING,
  cc_division             INTEGER,
  cc_division_name        STRING,
  cc_company              INTEGER,
  cc_company_name         STRING,
  cc_street_number        STRING,
  cc_street_name          STRING,
  cc_street_type          STRING,
  cc_suite_number         STRING,
  cc_city                 STRING,
  cc_county               STRING,
  cc_state                STRING,
  cc_zip                  STRING,
  cc_country              STRING,
  cc_gmt_offset           DECIMAL(5,2),
  cc_tax_percentage       DECIMAL(5,2)
)
USING iceberg
PARTITIONED BY (
  bucket(8, cc_call_center_sk)  -- Optional: distributes reads if table grows large
)
TBLPROPERTIES (
  'format-version' = '2',
  'write.format.default' = 'parquet',
  'write.parquet.compression-codec' = 'zstd',
  'write.metadata.compression-codec' = 'zstd',
  'write.target-file-size-bytes' = '67108864'   -- 64 MB for small-to-medium dimension tables
);


-- ------------------------------------------------------------------------------
-- catalog_page (cp)
-- Partitioning: Bucketed by catalog_page_sk.
-- ------------------------------------------------------------------------------
CREATE TABLE tps.ds.catalog_page (
  cp_catalog_page_sk    BIGINT,
  cp_catalog_page_id    STRING,
  cp_start_date_sk      BIGINT,
  cp_end_date_sk        BIGINT,
  cp_department         STRING,
  cp_catalog_number     INTEGER,
  cp_catalog_page_number INTEGER,
  cp_description        STRING,
  cp_type               STRING
)
USING iceberg
TBLPROPERTIES (
  'format-version' = '2',
  'write.format.default' = 'parquet',
  'write.parquet.compression-codec' = 'zstd',
  'write.metadata.compression-codec' = 'zstd',
  'write.target-file-size-bytes' = '33554432'   -- 32 MB: optimal for small static dimensions
);


-- ------------------------------------------------------------------------------
-- web_site (web)
-- ------------------------------------------------------------------------------
CREATE TABLE tps.ds.web_site (
  web_site_sk          BIGINT,
  web_site_id          STRING,
  web_rec_start_date   DATE,
  web_rec_end_date     DATE,
  web_name             STRING,
  web_open_date_sk     BIGINT,
  web_close_date_sk    BIGINT,
  web_class            STRING,
  web_manager          STRING,
  web_mkt_id           INTEGER,
  web_mkt_class        STRING,
  web_mkt_desc         STRING,
  web_market_manager   STRING,
  web_company_id       INTEGER,
  web_company_name     STRING,
  web_street_number    STRING,
  web_street_name      STRING,
  web_street_type      STRING,
  web_suite_number     STRING,
  web_city             STRING,
  web_county           STRING,
  web_state            STRING,
  web_zip              STRING,
  web_country          STRING,
  web_gmt_offset       DECIMAL(5,2),
  web_tax_percentage   DECIMAL(5,2)
)
USING iceberg
TBLPROPERTIES (
  'format-version' = '2',
  'write.format.default' = 'parquet',
  'write.parquet.compression-codec' = 'zstd',
  'write.metadata.compression-codec' = 'zstd',
  'write.target-file-size-bytes' = '67108864'  -- 64 MB, good size for dimension tables
);


-- ------------------------------------------------------------------------------
-- web_page (wp)
-- Partitioning: Bucketed by web_page_sk.
-- ------------------------------------------------------------------------------
CREATE TABLE tps.ds.web_page (
  wp_web_page_sk       BIGINT,
  wp_web_page_id       STRING,
  wp_rec_start_date    DATE,
  wp_rec_end_date      DATE,
  wp_creation_date_sk  BIGINT,
  wp_access_date_sk    BIGINT,
  wp_autogen_flag      STRING,
  wp_customer_sk       BIGINT,
  wp_url               STRING,
  wp_type              STRING,
  wp_char_count        INTEGER,
  wp_link_count        INTEGER,
  wp_image_count       INTEGER,
  wp_max_ad_count      INTEGER
)
USING iceberg
PARTITIONED BY (
  bucket(8, wp_web_page_sk)    -- Helps with join performance and scan parallelism
)
TBLPROPERTIES (
  'format-version' = '2',
  'write.format.default' = 'parquet',
  'write.parquet.compression-codec' = 'zstd',
  'write.metadata.compression-codec' = 'zstd',
  'write.target-file-size-bytes' = '67108864'   -- 64 MB target file size
);


-- ------------------------------------------------------------------------------
-- warehouse (w)
-- Partitioning: Bucketed by warehouse_sk, then by state.
-- ------------------------------------------------------------------------------
CREATE TABLE tps.ds.warehouse (
  w_warehouse_sk       BIGINT,
  w_warehouse_id       STRING,
  w_warehouse_name     STRING,
  w_warehouse_sq_ft    INTEGER,
  w_street_number      STRING,
  w_street_name        STRING,
  w_street_type        STRING,
  w_suite_number       STRING,
  w_city               STRING,
  w_county             STRING,
  w_state              STRING,
  w_zip                STRING,
  w_country            STRING,
  w_gmt_offset         DECIMAL(5,2)
)
USING iceberg
PARTITIONED BY (
  bucket(8, w_warehouse_sk)  -- Helps parallelize scans and joins by warehouse
)
TBLPROPERTIES (
  'format-version' = '2',
  'write.format.default' = 'parquet',
  'write.parquet.compression-codec' = 'zstd',
  'write.metadata.compression-codec' = 'zstd',
  'write.target-file-size-bytes' = '67108864'  -- 64 MB files for dimension tables
);


-- ------------------------------------------------------------------------------
-- customer (c)
-- Partitioning: Bucketed by customer_sk, then by birth year.
-- ------------------------------------------------------------------------------
CREATE TABLE tps.ds.customer (
  c_customer_sk        BIGINT,
  c_customer_id        STRING,
  c_current_cdemo_sk   BIGINT,
  c_current_hdemo_sk   BIGINT,
  c_current_addr_sk    BIGINT,
  c_first_shipto_date_sk BIGINT,
  c_first_sales_date_sk  BIGINT,
  c_salutation        STRING,
  c_first_name        STRING,
  c_last_name         STRING,
  c_preferred_cust_flag STRING,
  c_birth_day         INTEGER,
  c_birth_month       INTEGER,
  c_birth_year        INTEGER,
  c_birth_country     STRING,
  c_login             STRING,
  c_email_address     STRING,
  c_last_review_date  DATE
)
USING iceberg
PARTITIONED BY (
  bucket(16, c_customer_sk)  -- Large dimension: bucketing improves query parallelism
)
TBLPROPERTIES (
  'format-version' = '2',
  'write.format.default' = 'parquet',
  'write.parquet.compression-codec' = 'zstd',
  'write.metadata.compression-codec' = 'zstd',
  'write.target-file-size-bytes' = '134217728'  -- 128 MB for larger dimension
);


-- ------------------------------------------------------------------------------
-- customer_address (ca)
-- Partitioning: Bucketed by address_sk, then by state.
-- ------------------------------------------------------------------------------
CREATE TABLE tps.ds.customer_address (
  ca_address_sk       BIGINT,
  ca_address_id       STRING,
  ca_street_number    STRING,
  ca_street_name      STRING,
  ca_street_type      STRING,
  ca_suite_number     STRING,
  ca_city             STRING,
  ca_county           STRING,
  ca_state            STRING,
  ca_zip              STRING,
  ca_country          STRING,
  ca_gmt_offset       DECIMAL(5,2)
)
USING iceberg
PARTITIONED BY (
  bucket(16, ca_address_sk)   -- Helps distribute queries and joins evenly
)
TBLPROPERTIES (
  'format-version' = '2',
  'write.format.default' = 'parquet',
  'write.parquet.compression-codec' = 'zstd',
  'write.metadata.compression-codec' = 'zstd',
  'write.target-file-size-bytes' = '134217728'   -- 128 MB files for efficient scans
);


-- ------------------------------------------------------------------------------
-- customer_demographics (cd)
-- Partitioning: Bucketed by demo_sk, then by gender and marital status.
-- ------------------------------------------------------------------------------
CREATE TABLE tps.ds.customer_demographics (
  cd_demo_sk            BIGINT,
  cd_gender             STRING,
  cd_marital_status     STRING,
  cd_education_status   STRING,
  cd_purchase_estimate  INTEGER,
  cd_credit_rating      STRING,
  cd_dep_count          INTEGER,
  cd_dep_employed_count INTEGER,
  cd_dep_college_count  INTEGER
)
USING iceberg
PARTITIONED BY (
  bucket(8, cd_demo_sk)   -- Optional bucketing for improved join performance
)
TBLPROPERTIES (
  'format-version' = '2',
  'write.format.default' = 'parquet',
  'write.parquet.compression-codec' = 'zstd',
  'write.metadata.compression-codec' = 'zstd',
  'write.target-file-size-bytes' = '67108864'   -- 64 MB target file size for dimension tables
);


-- ------------------------------------------------------------------------------
-- date_dim (d)
-- Partitioning: By year, then by month of year.
-- ------------------------------------------------------------------------------
CREATE TABLE tps.ds.date_dim (
  d_date_sk           BIGINT,
  d_date_id           STRING,
  d_date              DATE,
  d_month_seq         INTEGER,
  d_week_seq          INTEGER,
  d_quarter_seq       INTEGER,
  d_year              INTEGER,
  d_dow               INTEGER,
  d_moy               INTEGER,
  d_dom               INTEGER,
  d_qoy               INTEGER,
  d_fy_year           INTEGER,
  d_fy_quarter_seq    INTEGER,
  d_fy_week_seq       INTEGER,
  d_day_name          STRING,
  d_quarter_name      STRING,
  d_holiday           STRING,
  d_weekend           STRING,
  d_following_holiday STRING,
  d_first_dom         INTEGER,
  d_last_dom          INTEGER,
  d_same_day_ly       INTEGER,
  d_same_day_lq       INTEGER,
  d_current_day       STRING
)
USING iceberg
PARTITIONED BY (
  years(d_date)          -- Partition by year for efficient pruning on year filters
)
TBLPROPERTIES (
  'format-version' = '2',
  'write.format.default' = 'parquet',
  'write.parquet.compression-codec' = 'zstd',
  'write.metadata.compression-codec' = 'zstd',
  'write.target-file-size-bytes' = '67108864'   -- 64 MB file size
);


-- ------------------------------------------------------------------------------
-- household_demographics (hd)
-- Partitioning: Bucketed by demo_sk, then by income band.
-- ------------------------------------------------------------------------------
CREATE TABLE tps.ds.household_demographics (
  hd_demo_sk              BIGINT,
  hd_income_band_sk       BIGINT,
  hd_buy_potential        STRING,
  hd_dep_count            INTEGER,
  hd_vehicle_count        INTEGER
)
USING iceberg
PARTITIONED BY (
  bucket(8, hd_demo_sk)  -- Optional bucketing for better join performance
)
TBLPROPERTIES (
  'format-version' = '2',
  'write.format.default' = 'parquet',
  'write.parquet.compression-codec' = 'zstd',
  'write.metadata.compression-codec' = 'zstd',
  'write.target-file-size-bytes' = '67108864'  -- 64 MB file size
);


-- ------------------------------------------------------------------------------
-- item (i)
-- Partitioning: Bucketed by item_sk, then by category.
-- ------------------------------------------------------------------------------
CREATE TABLE tps.ds.item (
  i_item_sk             BIGINT,
  i_item_id             STRING,
  i_rec_start_date      DATE,
  i_rec_end_date        DATE,
  i_item_desc           STRING,
  i_current_price       DECIMAL(7,2),
  i_wholesale_cost      DECIMAL(7,2),
  i_brand_id            INTEGER,
  i_brand              STRING,
  i_class_id            INTEGER,
  i_class               STRING,
  i_category_id         INTEGER,
  i_category            STRING,
  i_manufact_id         INTEGER,
  i_manufact            STRING,
  i_size                STRING,
  i_formulation         STRING,
  i_color               STRING,
  i_units               STRING,
  i_container           STRING,
  i_manager_id          INTEGER,
  i_product_name        STRING
)
USING iceberg
PARTITIONED BY (
  bucket(32, i_item_sk)  -- Large dimension; bucketing improves scan and join parallelism
)
TBLPROPERTIES (
  'format-version' = '2',
  'write.format.default' = 'parquet',
  'write.parquet.compression-codec' = 'zstd',
  'write.metadata.compression-codec' = 'zstd',
  'write.target-file-size-bytes' = '134217728'  -- 128 MB files for large dimensions
);


-- ------------------------------------------------------------------------------
-- income_band (ib)
-- Partitioning: Bucketed by income_band_sk. (Small table)
-- ------------------------------------------------------------------------------
CREATE TABLE tps.ds.income_band (
  ib_income_band_sk   BIGINT,
  ib_lower_bound      INTEGER,
  ib_upper_bound      INTEGER,
  ib_income_band      STRING
)
USING iceberg
TBLPROPERTIES (
  'format-version' = '2',
  'write.format.default' = 'parquet',
  'write.parquet.compression-codec' = 'zstd',
  'write.metadata.compression-codec' = 'zstd',
  'write.target-file-size-bytes' = '33554432'  -- 32 MB small table size
);


-- ------------------------------------------------------------------------------
-- promotion (p)
-- Partitioning: Bucketed by promo_sk, then by channel flags.
-- ------------------------------------------------------------------------------
CREATE TABLE tps.ds.promotion (
  p_promo_sk          BIGINT,
  p_promo_id          STRING,
  p_start_date_sk     BIGINT,
  p_end_date_sk       BIGINT,
  p_category          STRING,
  p_class             STRING,
  p_brand             STRING,
  p_channel_dmail     STRING,
  p_channel_email     STRING,
  p_channel_catalog   STRING,
  p_channel_tv        STRING,
  p_channel_radio     STRING,
  p_channel_press     STRING,
  p_channel_event     STRING,
  p_channel_demo      STRING,
  p_channel_details   STRING,
  p_purpose           STRING,
  p_discount_active   STRING
)
USING iceberg
PARTITIONED BY (
  bucket(8, p_promo_sk)  -- Bucketing improves join and scan performance
)
TBLPROPERTIES (
  'format-version' = '2',
  'write.format.default' = 'parquet',
  'write.parquet.compression-codec' = 'zstd',
  'write.metadata.compression-codec' = 'zstd',
  'write.target-file-size-bytes' = '67108864'  -- 64 MB target file size
);


-- ------------------------------------------------------------------------------
-- reason (r)
-- No partitioning for very small tables.
-- ------------------------------------------------------------------------------
CREATE TABLE tps.ds.reason (
  r_reason_sk        BIGINT,
  r_reason_id        STRING,
  r_reason_desc      STRING
)
USING iceberg
TBLPROPERTIES (
  'format-version' = '2',
  'write.format.default' = 'parquet',
  'write.parquet.compression-codec' = 'zstd',
  'write.metadata.compression-codec' = 'zstd',
  'write.target-file-size-bytes' = '33554432'  -- 32 MB target size for small dimension
);


-- ------------------------------------------------------------------------------
-- ship_mode (sm)
-- No partitioning for very small tables.
-- ------------------------------------------------------------------------------
CREATE TABLE tps.ds.ship_mode (
  sm_ship_mode_sk    BIGINT,
  sm_ship_mode_id    STRING,
  sm_type            STRING,
  sm_code            STRING,
  sm_carrier         STRING,
  sm_contract       STRING
)
USING iceberg
TBLPROPERTIES (
  'format-version' = '2',
  'write.format.default' = 'parquet',
  'write.parquet.compression-codec' = 'zstd',
  'write.metadata.compression-codec' = 'zstd',
  'write.target-file-size-bytes' = '33554432'  -- 32 MB small table size
);


-- ------------------------------------------------------------------------------
-- time_dim (t)
-- ------------------------------------------------------------------------------
CREATE TABLE tps.ds.time_dim (
  t_time_sk          BIGINT,
  t_time_id          STRING,
  t_time             INTEGER,
  t_hour             INTEGER,
  t_minute           INTEGER,
  t_second           INTEGER,
  t_am_pm            STRING,
  t_shift            STRING,
  t_sub_shift        STRING,
  t_meal_time        STRING
)
USING iceberg
TBLPROPERTIES (
  'format-version' = '2',
  'write.format.default' = 'parquet',
  'write.parquet.compression-codec' = 'zstd',
  'write.metadata.compression-codec' = 'zstd',
  'write.target-file-size-bytes' = '33554432'  -- 32 MB small table size
);


