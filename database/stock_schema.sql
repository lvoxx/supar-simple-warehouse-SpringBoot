-- Create stock transfers table
CREATE TABLE IF NOT EXISTS stock_transfers (
    id BIGSERIAL PRIMARY KEY,
    transfer_number VARCHAR(100) UNIQUE NOT NULL,
    from_warehouse_id BIGINT NOT NULL,
    to_warehouse_id BIGINT NOT NULL,
    transfer_date DATE NOT NULL,
    expected_arrival_date DATE,
    actual_arrival_date DATE,
    transfer_type VARCHAR(50),
    status VARCHAR(50) DEFAULT 'DRAFT',
    priority VARCHAR(50) DEFAULT 'NORMAL',
    total_items INTEGER,
    total_quantity NUMERIC(15, 2),
    carrier_name VARCHAR(255),
    tracking_number VARCHAR(100),
    vehicle_number VARCHAR(50),
    requested_by VARCHAR(100),
    approved_by VARCHAR(100),
    approved_at TIMESTAMP,
    shipped_by VARCHAR(100),
    shipped_at TIMESTAMP,
    received_by VARCHAR(100),
    received_at TIMESTAMP,
    reason TEXT,
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by VARCHAR(100),
    updated_by VARCHAR(100),
    CONSTRAINT fk_transfer_from_warehouse FOREIGN KEY (from_warehouse_id) REFERENCES warehouses(id),
    CONSTRAINT fk_transfer_to_warehouse FOREIGN KEY (to_warehouse_id) REFERENCES warehouses(id)
);

-- Create stock transfer items table
CREATE TABLE IF NOT EXISTS stock_transfer_items (
    id BIGSERIAL PRIMARY KEY,
    transfer_id BIGINT NOT NULL,
    line_number INTEGER NOT NULL,
    product_id BIGINT NOT NULL,
    sku VARCHAR(100) NOT NULL,
    batch_number VARCHAR(100),
    serial_number VARCHAR(100),
    from_location_id BIGINT,
    to_location_id BIGINT,
    requested_quantity NUMERIC(15, 2) NOT NULL,
    shipped_quantity NUMERIC(15, 2) DEFAULT 0,
    received_quantity NUMERIC(15, 2) DEFAULT 0,
    unit_of_measure VARCHAR(20),
    lot_number VARCHAR(100),
    status VARCHAR(50),
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by VARCHAR(100),
    updated_by VARCHAR(100),
    CONSTRAINT fk_transfer_item_transfer FOREIGN KEY (transfer_id) REFERENCES stock_transfers(id),
    CONSTRAINT fk_transfer_item_from_location FOREIGN KEY (from_location_id) REFERENCES storage_locations(id),
    CONSTRAINT fk_transfer_item_to_location FOREIGN KEY (to_location_id) REFERENCES storage_locations(id),
    CONSTRAINT uk_transfer_item_line UNIQUE (transfer_id, line_number)
);

CREATE INDEX idx_transfer_from_warehouse ON stock_transfers(from_warehouse_id);
CREATE INDEX idx_transfer_to_warehouse ON stock_transfers(to_warehouse_id);
CREATE INDEX idx_transfer_status ON stock_transfers(status);
CREATE INDEX idx_transfer_date ON stock_transfers(transfer_date);

CREATE INDEX idx_transfer_item_transfer ON stock_transfer_items(transfer_id);
CREATE INDEX idx_transfer_item_product ON stock_transfer_items(product_id);