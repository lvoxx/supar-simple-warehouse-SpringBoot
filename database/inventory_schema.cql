-- Cassandra Schema for Inventory Service
-- Optimized for high write throughput and time-series queries

-- Create keyspace
CREATE KEYSPACE IF NOT EXISTS inventory_keyspace
WITH replication = {
    'class': 'NetworkTopologyStrategy',
    'datacenter1': 3  -- Adjust based on your cluster setup
}
AND durable_writes = true;

USE inventory_keyspace;

-- ============================================================================
-- INVENTORY TABLE
-- ============================================================================
-- Main inventory table with composite primary key
-- Partition key: warehouse_id (distributes data across nodes)
-- Clustering keys: product_id, location_id, batch_number (for ordering)
CREATE TABLE IF NOT EXISTS inventory (
    warehouse_id bigint,
    product_id bigint,
    location_id bigint,
    batch_number text,
    id uuid,
    sku text,
    serial_number text,
    quantity decimal,
    available_quantity decimal,
    reserved_quantity decimal,
    damaged_quantity decimal,
    unit_of_measure text,
    unit_cost decimal,
    total_cost decimal,
    currency text,
    manufacture_date date,
    expiry_date date,
    received_date date,
    supplier_id bigint,
    purchase_order_number text,
    lot_number text,
    pallet_id text,
    status text,
    quality_status text,
    weight decimal,
    weight_unit text,
    volume decimal,
    volume_unit text,
    min_stock_level decimal,
    max_stock_level decimal,
    reorder_point decimal,
    notes text,
    version bigint,
    created_at timestamp,
    updated_at timestamp,
    created_by text,
    updated_by text,
    PRIMARY KEY ((warehouse_id), product_id, location_id, batch_number)
) WITH CLUSTERING ORDER BY (product_id ASC, location_id ASC, batch_number ASC)
AND comment = 'Main inventory table for real-time stock levels'
AND compaction = {'class': 'LeveledCompactionStrategy'}
AND gc_grace_seconds = 864000;  -- 10 days

-- Secondary index for status queries
CREATE INDEX IF NOT EXISTS idx_inventory_status 
ON inventory (status);

-- Secondary index for expiry date queries
CREATE INDEX IF NOT EXISTS idx_inventory_expiry 
ON inventory (expiry_date);

-- Materialized view for product-centric queries
CREATE MATERIALIZED VIEW IF NOT EXISTS inventory_by_product AS
    SELECT warehouse_id, product_id, location_id, batch_number, 
           sku, quantity, available_quantity, status, expiry_date
    FROM inventory
    WHERE warehouse_id IS NOT NULL 
      AND product_id IS NOT NULL 
      AND location_id IS NOT NULL 
      AND batch_number IS NOT NULL
    PRIMARY KEY ((product_id), warehouse_id, location_id, batch_number)
    WITH CLUSTERING ORDER BY (warehouse_id ASC, location_id ASC, batch_number ASC);

-- Materialized view for location-centric queries
CREATE MATERIALIZED VIEW IF NOT EXISTS inventory_by_location AS
    SELECT warehouse_id, product_id, location_id, batch_number,
           sku, quantity, available_quantity, status
    FROM inventory
    WHERE warehouse_id IS NOT NULL 
      AND product_id IS NOT NULL 
      AND location_id IS NOT NULL 
      AND batch_number IS NOT NULL
    PRIMARY KEY ((location_id), warehouse_id, product_id, batch_number)
    WITH CLUSTERING ORDER BY (warehouse_id ASC, product_id ASC, batch_number ASC);

-- ============================================================================
-- INVENTORY TRANSACTIONS TABLE
-- ============================================================================
-- Time-series design for transaction history
-- Partition key: warehouse_id (distributes data)
-- Clustering keys: transaction_date DESC (recent first), transaction_id
CREATE TABLE IF NOT EXISTS inventory_transactions (
    warehouse_id bigint,
    transaction_date timestamp,
    transaction_id uuid,
    id uuid,
    transaction_number text,
    transaction_type text,
    product_id bigint,
    sku text,
    from_location_id bigint,
    to_location_id bigint,
    quantity decimal,
    unit_of_measure text,
    batch_number text,
    serial_number text,
    reference_number text,
    reference_type text,
    unit_cost decimal,
    total_cost decimal,
    currency text,
    reason_code text,
    status text,
    completed_date timestamp,
    user_id text,
    notes text,
    previous_quantity decimal,
    new_quantity decimal,
    created_at timestamp,
    updated_at timestamp,
    created_by text,
    updated_by text,
    PRIMARY KEY ((warehouse_id), transaction_date, transaction_id)
) WITH CLUSTERING ORDER BY (transaction_date DESC, transaction_id ASC)
AND comment = 'Inventory transaction history with time-series design'
AND compaction = {'class': 'TimeWindowCompactionStrategy', 
                  'compaction_window_unit': 'DAYS', 
                  'compaction_window_size': 1}
AND default_time_to_live = 7776000;  -- 90 days TTL

-- Materialized view for product transaction history
CREATE MATERIALIZED VIEW IF NOT EXISTS inventory_transactions_by_product AS
    SELECT warehouse_id, transaction_date, transaction_id, 
           product_id, transaction_type, quantity, status
    FROM inventory_transactions
    WHERE warehouse_id IS NOT NULL 
      AND transaction_date IS NOT NULL 
      AND transaction_id IS NOT NULL
      AND product_id IS NOT NULL
    PRIMARY KEY ((product_id), transaction_date, warehouse_id, transaction_id)
    WITH CLUSTERING ORDER BY (transaction_date DESC, warehouse_id ASC, transaction_id ASC);

-- Materialized view for transaction type queries
CREATE MATERIALIZED VIEW IF NOT EXISTS inventory_transactions_by_type AS
    SELECT warehouse_id, transaction_date, transaction_id,
           transaction_type, product_id, quantity, status
    FROM inventory_transactions
    WHERE warehouse_id IS NOT NULL 
      AND transaction_date IS NOT NULL 
      AND transaction_id IS NOT NULL
      AND transaction_type IS NOT NULL
    PRIMARY KEY ((warehouse_id, transaction_type), transaction_date, transaction_id)
    WITH CLUSTERING ORDER BY (transaction_date DESC, transaction_id ASC);

-- ============================================================================
-- INVENTORY SNAPSHOTS TABLE
-- ============================================================================
-- Periodic snapshots for historical analysis and reporting
-- Partition key: warehouse_id
-- Clustering keys: snapshot_date DESC, product_id, location_id, batch_number
CREATE TABLE IF NOT EXISTS inventory_snapshots (
    warehouse_id bigint,
    snapshot_date timestamp,
    product_id bigint,
    location_id bigint,
    batch_number text,
    id uuid,
    sku text,
    quantity decimal,
    available_quantity decimal,
    reserved_quantity decimal,
    damaged_quantity decimal,
    unit_cost decimal,
    total_cost decimal,
    currency text,
    status text,
    snapshot_reason text,
    created_at timestamp,
    updated_at timestamp,
    PRIMARY KEY ((warehouse_id), snapshot_date, product_id, location_id, batch_number)
) WITH CLUSTERING ORDER BY (snapshot_date DESC, product_id ASC, location_id ASC, batch_number ASC)
AND comment = 'Periodic inventory snapshots for historical analysis'
AND compaction = {'class': 'TimeWindowCompactionStrategy',
                  'compaction_window_unit': 'DAYS',
                  'compaction_window_size': 7}
AND default_time_to_live = 31536000;  -- 1 year TTL

-- Materialized view for product snapshot history
CREATE MATERIALIZED VIEW IF NOT EXISTS inventory_snapshots_by_product AS
    SELECT warehouse_id, snapshot_date, product_id, location_id, batch_number,
           sku, quantity, available_quantity, status
    FROM inventory_snapshots
    WHERE warehouse_id IS NOT NULL 
      AND snapshot_date IS NOT NULL 
      AND product_id IS NOT NULL
      AND location_id IS NOT NULL
      AND batch_number IS NOT NULL
    PRIMARY KEY ((product_id), snapshot_date, warehouse_id, location_id, batch_number)
    WITH CLUSTERING ORDER BY (snapshot_date DESC, warehouse_id ASC, location_id ASC, batch_number ASC);

-- ============================================================================
-- COUNTERS TABLE (Optional - for aggregate statistics)
-- ============================================================================
CREATE TABLE IF NOT EXISTS inventory_counters (
    warehouse_id bigint,
    counter_type text,  -- total_items, total_value, low_stock_items, etc.
    counter_value counter,
    PRIMARY KEY (warehouse_id, counter_type)
) WITH comment = 'Aggregate counters for inventory statistics';

-- ============================================================================
-- PERFORMANCE TUNING NOTES
-- ============================================================================
-- 1. Use LeveledCompactionStrategy for main inventory table (read-heavy)
-- 2. Use TimeWindowCompactionStrategy for time-series tables (write-heavy)
-- 3. Set appropriate TTL for transactional data
-- 4. Use Materialized Views sparingly - only for critical queries
-- 5. Consider bucketing for very high cardinality partitions
-- 6. Monitor partition sizes and adjust bucketing if needed
-- 7. Use LOCAL_QUORUM for consistency vs performance balance

-- ============================================================================
-- QUERY PATTERNS SUPPORTED
-- ============================================================================
-- 1. Get inventory by warehouse + product + location + batch
-- 2. Get all inventory for a warehouse
-- 3. Get all inventory for a product (across warehouses)
-- 4. Get all inventory at a location
-- 5. Get transactions for a warehouse in date range
-- 6. Get transactions for a product
-- 7. Get transactions by type
-- 8. Get inventory snapshots for historical analysis
-- 9. Low stock alerts (via status index)
-- 10. Expiring items (via expiry_date index)
