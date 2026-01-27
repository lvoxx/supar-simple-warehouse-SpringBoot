-- Warehouse Management System Database Schema
-- R2DBC Compatible PostgreSQL Script

-- Create warehouses table
CREATE TABLE IF NOT EXISTS warehouses (
    id BIGSERIAL PRIMARY KEY,
    warehouse_code VARCHAR(50) UNIQUE NOT NULL,
    warehouse_name VARCHAR(255) NOT NULL,
    address TEXT,
    city VARCHAR(100),
    province VARCHAR(100),
    country VARCHAR(100),
    postal_code VARCHAR(20),
    phone VARCHAR(50),
    email VARCHAR(255),
    manager_name VARCHAR(255),
    capacity NUMERIC(15, 2),
    capacity_unit VARCHAR(20),
    warehouse_type VARCHAR(50),
    status VARCHAR(50) DEFAULT 'ACTIVE',
    latitude NUMERIC(10, 7),
    longitude NUMERIC(10, 7),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by VARCHAR(100),
    updated_by VARCHAR(100)
);

-- Create warehouse zones table
CREATE TABLE IF NOT EXISTS warehouse_zones (
    id BIGSERIAL PRIMARY KEY,
    warehouse_id BIGINT NOT NULL,
    zone_code VARCHAR(50) NOT NULL,
    zone_name VARCHAR(255) NOT NULL,
    zone_type VARCHAR(50),
    floor_level INTEGER,
    temperature_min NUMERIC(5, 2),
    temperature_max NUMERIC(5, 2),
    humidity_min NUMERIC(5, 2),
    humidity_max NUMERIC(5, 2),
    area NUMERIC(15, 2),
    area_unit VARCHAR(20),
    max_weight_capacity NUMERIC(15, 2),
    weight_unit VARCHAR(20),
    status VARCHAR(50) DEFAULT 'ACTIVE',
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by VARCHAR(100),
    updated_by VARCHAR(100),
    CONSTRAINT fk_zone_warehouse FOREIGN KEY (warehouse_id) REFERENCES warehouses(id),
    CONSTRAINT uk_zone_code UNIQUE (warehouse_id, zone_code)
);

-- Create storage locations table
CREATE TABLE IF NOT EXISTS storage_locations (
    id BIGSERIAL PRIMARY KEY,
    zone_id BIGINT NOT NULL,
    location_code VARCHAR(100) UNIQUE NOT NULL,
    aisle VARCHAR(20),
    rack VARCHAR(20),
    shelf VARCHAR(20),
    bin VARCHAR(20),
    location_type VARCHAR(50),
    max_weight NUMERIC(15, 2),
    max_volume NUMERIC(15, 2),
    volume_unit VARCHAR(20),
    current_weight NUMERIC(15, 2) DEFAULT 0,
    current_volume NUMERIC(15, 2) DEFAULT 0,
    width NUMERIC(10, 2),
    height NUMERIC(10, 2),
    depth NUMERIC(10, 2),
    dimension_unit VARCHAR(20),
    status VARCHAR(50) DEFAULT 'AVAILABLE',
    is_pickable BOOLEAN DEFAULT TRUE,
    is_replenishable BOOLEAN DEFAULT TRUE,
    priority_level INTEGER,
    barcode VARCHAR(255),
    qr_code VARCHAR(255),
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by VARCHAR(100),
    updated_by VARCHAR(100),
    CONSTRAINT fk_location_zone FOREIGN KEY (zone_id) REFERENCES warehouse_zones(id)
);

-- Create indexes for better query performance
CREATE INDEX idx_warehouse_code ON warehouses(warehouse_code);
CREATE INDEX idx_warehouse_status ON warehouses(status);

CREATE INDEX idx_zone_warehouse ON warehouse_zones(warehouse_id);
CREATE INDEX idx_zone_status ON warehouse_zones(status);

CREATE INDEX idx_location_zone ON storage_locations(zone_id);
CREATE INDEX idx_location_code ON storage_locations(location_code);
CREATE INDEX idx_location_status ON storage_locations(status);
