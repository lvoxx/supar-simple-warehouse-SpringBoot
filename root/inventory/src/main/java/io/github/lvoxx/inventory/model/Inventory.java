package io.github.lvoxx.inventory.model;

import java.math.BigDecimal;
import java.time.LocalDate;

import org.springframework.stereotype.Indexed;

import io.github.lvoxx.r2dbc_starter.model.AbstractWhoChangedOnEntity;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * Inventory entity for Cassandra - Optimized for high write throughput
 * Primary key: warehouse_id + product_id + location_id + batch_number
 */
@Table("inventory")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Inventory extends AbstractWhoChangedOnEntity {

    @PrimaryKey
    private InventoryKey key;

    @Column("sku")
    private String sku;

    @Column("serial_number")
    private String serialNumber;

    @Column("quantity")
    private BigDecimal quantity;

    @Column("available_quantity")
    private BigDecimal availableQuantity;

    @Column("reserved_quantity")
    private BigDecimal reservedQuantity;

    @Column("damaged_quantity")
    private BigDecimal damagedQuantity;

    @Column("unit_of_measure")
    private String unitOfMeasure;

    @Column("unit_cost")
    private BigDecimal unitCost;

    @Column("total_cost")
    private BigDecimal totalCost;

    @Column("currency")
    private String currency;

    @Column("manufacture_date")
    private LocalDate manufactureDate;

    @Column("expiry_date")
    @Indexed
    private LocalDate expiryDate;

    @Column("received_date")
    private LocalDate receivedDate;

    @Column("supplier_id")
    private Long supplierId;

    @Column("purchase_order_number")
    private String purchaseOrderNumber;

    @Column("lot_number")
    private String lotNumber;

    @Column("pallet_id")
    private String palletId;

    @Column("status")
    @Indexed
    private String status; // AVAILABLE, RESERVED, DAMAGED, EXPIRED, QUARANTINE, IN_TRANSIT

    @Column("quality_status")
    private String qualityStatus; // PASSED, FAILED, PENDING_INSPECTION

    @Column("weight")
    private BigDecimal weight;

    @Column("weight_unit")
    private String weightUnit;

    @Column("volume")
    private BigDecimal volume;

    @Column("volume_unit")
    private String volumeUnit;

    @Column("min_stock_level")
    private BigDecimal minStockLevel;

    @Column("max_stock_level")
    private BigDecimal maxStockLevel;

    @Column("reorder_point")
    private BigDecimal reorderPoint;

    @Column("notes")
    private String notes;

}