-- Create goods receipts table
CREATE TABLE IF NOT EXISTS goods_receipts (
    id BIGSERIAL PRIMARY KEY,
    receipt_number VARCHAR(100) UNIQUE NOT NULL,
    warehouse_id BIGINT NOT NULL,
    supplier_id BIGINT,
    purchase_order_number VARCHAR(100),
    receipt_date DATE NOT NULL,
    expected_date DATE,
    carrier_name VARCHAR(255),
    tracking_number VARCHAR(100),
    vehicle_number VARCHAR(50),
    driver_name VARCHAR(255),
    driver_phone VARCHAR(50),
    receipt_type VARCHAR(50),
    status VARCHAR(50) DEFAULT 'DRAFT',
    total_items INTEGER,
    total_quantity NUMERIC(15, 2),
    received_by VARCHAR(100),
    inspection_status VARCHAR(50),
    inspection_date TIMESTAMP,
    inspected_by VARCHAR(100),
    notes TEXT,
    attachment_url TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by VARCHAR(100),
    updated_by VARCHAR(100),
    CONSTRAINT fk_receipt_warehouse FOREIGN KEY (warehouse_id) REFERENCES warehouses(id)
);

-- Create goods receipt items table
CREATE TABLE IF NOT EXISTS goods_receipt_items (
    id BIGSERIAL PRIMARY KEY,
    receipt_id BIGINT NOT NULL,
    line_number INTEGER NOT NULL,
    product_id BIGINT NOT NULL,
    sku VARCHAR(100) NOT NULL,
    batch_number VARCHAR(100),
    serial_number VARCHAR(100),
    expected_quantity NUMERIC(15, 2) NOT NULL,
    received_quantity NUMERIC(15, 2) DEFAULT 0,
    accepted_quantity NUMERIC(15, 2) DEFAULT 0,
    rejected_quantity NUMERIC(15, 2) DEFAULT 0,
    unit_of_measure VARCHAR(20),
    location_id BIGINT,
    unit_cost NUMERIC(15, 2),
    total_cost NUMERIC(15, 2),
    currency VARCHAR(10),
    manufacture_date DATE,
    expiry_date DATE,
    lot_number VARCHAR(100),
    quality_status VARCHAR(50),
    rejection_reason TEXT,
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by VARCHAR(100),
    updated_by VARCHAR(100),
    CONSTRAINT fk_receipt_item_receipt FOREIGN KEY (receipt_id) REFERENCES goods_receipts(id),
    CONSTRAINT fk_receipt_item_location FOREIGN KEY (location_id) REFERENCES storage_locations(id),
    CONSTRAINT uk_receipt_item_line UNIQUE (receipt_id, line_number)
);

-- Create goods issues table
CREATE TABLE IF NOT EXISTS goods_issues (
    id BIGSERIAL PRIMARY KEY,
    issue_number VARCHAR(100) UNIQUE NOT NULL,
    warehouse_id BIGINT NOT NULL,
    customer_id BIGINT,
    sales_order_number VARCHAR(100),
    issue_date DATE NOT NULL,
    requested_date DATE,
    ship_to_address TEXT,
    ship_to_city VARCHAR(100),
    ship_to_province VARCHAR(100),
    ship_to_country VARCHAR(100),
    ship_to_postal_code VARCHAR(20),
    carrier_name VARCHAR(255),
    tracking_number VARCHAR(100),
    vehicle_number VARCHAR(50),
    driver_name VARCHAR(255),
    driver_phone VARCHAR(50),
    issue_type VARCHAR(50),
    priority VARCHAR(50) DEFAULT 'NORMAL',
    status VARCHAR(50) DEFAULT 'DRAFT',
    total_items INTEGER,
    total_quantity NUMERIC(15, 2),
    picked_by VARCHAR(100),
    packed_by VARCHAR(100),
    shipped_by VARCHAR(100),
    picking_started_at TIMESTAMP,
    picking_completed_at TIMESTAMP,
    packing_started_at TIMESTAMP,
    packing_completed_at TIMESTAMP,
    shipped_at TIMESTAMP,
    notes TEXT,
    attachment_url TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by VARCHAR(100),
    updated_by VARCHAR(100),
    CONSTRAINT fk_issue_warehouse FOREIGN KEY (warehouse_id) REFERENCES warehouses(id)
);

-- Create goods issue items table
CREATE TABLE IF NOT EXISTS goods_issue_items (
    id BIGSERIAL PRIMARY KEY,
    issue_id BIGINT NOT NULL,
    line_number INTEGER NOT NULL,
    product_id BIGINT NOT NULL,
    sku VARCHAR(100) NOT NULL,
    batch_number VARCHAR(100),
    serial_number VARCHAR(100),
    requested_quantity NUMERIC(15, 2) NOT NULL,
    picked_quantity NUMERIC(15, 2) DEFAULT 0,
    shipped_quantity NUMERIC(15, 2) DEFAULT 0,
    unit_of_measure VARCHAR(20),
    from_location_id BIGINT,
    unit_price NUMERIC(15, 2),
    total_price NUMERIC(15, 2),
    currency VARCHAR(10),
    lot_number VARCHAR(100),
    picking_status VARCHAR(50),
    short_pick_reason TEXT,
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by VARCHAR(100),
    updated_by VARCHAR(100),
    CONSTRAINT fk_issue_item_issue FOREIGN KEY (issue_id) REFERENCES goods_issues(id),
    CONSTRAINT fk_issue_item_location FOREIGN KEY (from_location_id) REFERENCES storage_locations(id),
    CONSTRAINT uk_issue_item_line UNIQUE (issue_id, line_number)
);

CREATE INDEX idx_receipt_warehouse ON goods_receipts(warehouse_id);
CREATE INDEX idx_receipt_number ON goods_receipts(receipt_number);
CREATE INDEX idx_receipt_status ON goods_receipts(status);
CREATE INDEX idx_receipt_date ON goods_receipts(receipt_date);

CREATE INDEX idx_receipt_item_receipt ON goods_receipt_items(receipt_id);
CREATE INDEX idx_receipt_item_product ON goods_receipt_items(product_id);

CREATE INDEX idx_issue_warehouse ON goods_issues(warehouse_id);
CREATE INDEX idx_issue_number ON goods_issues(issue_number);
CREATE INDEX idx_issue_status ON goods_issues(status);
CREATE INDEX idx_issue_date ON goods_issues(issue_date);

CREATE INDEX idx_issue_item_issue ON goods_issue_items(issue_id);
CREATE INDEX idx_issue_item_product ON goods_issue_items(product_id);