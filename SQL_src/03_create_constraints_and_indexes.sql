-- ============================================================================
-- SCRIPT 03: CREATE CONSTRAINTS & INDEXES
-- Project: Platform Connecting Film Photography Community with Darkroom & Studio Services
-- Exactly matching business rules, domain constraints & indexing strategy in Chapters 1-4
-- ============================================================================

USE FilmPhotographyDB;
GO

-- ============================================================================
-- 1. RÀNG BUỘC CHECK (DOMAIN & BUSINESS CONSTRAINTS)
-- ============================================================================

-- USER
ALTER TABLE dbo.[USER]
    ADD CONSTRAINT CK_USER_ROLE CHECK (role IN (N'Photographer', N'Service Provider', N'Expert', N'Administrator')),
        CONSTRAINT CK_USER_STATUS CHECK (status IN (N'Active', N'Inactive', N'Suspended', N'Pending'));
GO

-- SERVICE_PROVIDER
ALTER TABLE dbo.SERVICE_PROVIDER
    ADD CONSTRAINT CK_PROVIDER_STATUS CHECK (status IN (N'Active', N'Inactive', N'Pending_Approval', N'Suspended'));
GO

-- CREATIVE_SPACE
ALTER TABLE dbo.CREATIVE_SPACE
    ADD CONSTRAINT CK_SPACE_TYPE CHECK (space_type IN (N'Darkroom', N'Studio', N'Hybrid', N'Exhibition')),
        CONSTRAINT CK_SPACE_AREA CHECK (area > 0),
        CONSTRAINT CK_SPACE_CAPACITY CHECK (capacity > 0),
        CONSTRAINT CK_SPACE_PRICING CHECK (pricing >= 0),
        CONSTRAINT CK_SPACE_STATUS CHECK (status IN (N'Available', N'Occupied', N'Maintenance', N'Closed'));
GO

-- RESOURCE
ALTER TABLE dbo.RESOURCE
    ADD CONSTRAINT CK_RESOURCE_TYPE CHECK (resource_type IN (N'Camera', N'Lens', N'Enlarger', N'Film Scanner', N'Lighting', N'Darkroom Equipment', N'Chemicals', N'Photo Paper', N'Tripod & Rig')),
        CONSTRAINT CK_RESOURCE_QUANTITY CHECK (quantity >= 0),
        CONSTRAINT CK_RESOURCE_CONDITION CHECK (condition IN (N'New', N'Good', N'Fair', N'Need_Maintenance', N'Damaged')),
        CONSTRAINT CK_RESOURCE_RENTAL_PRICE CHECK (rental_price >= 0),
        CONSTRAINT CK_RESOURCE_STATUS CHECK (status IN (N'Available', N'In_Use', N'Maintenance', N'Retired'));
GO

-- MAINTENANCE
ALTER TABLE dbo.MAINTENANCE
    ADD CONSTRAINT CK_MAINTENANCE_TYPE CHECK (maintenance_type IN (N'Routine', N'Repair', N'Calibration', N'Cleaning', N'Inspection')),
        CONSTRAINT CK_MAINTENANCE_COST CHECK (cost >= 0),
        CONSTRAINT CK_MAINTENANCE_STATUS CHECK (status IN (N'Scheduled', N'In_Progress', N'Completed', N'Cancelled')),
        CONSTRAINT CK_MAINTENANCE_DATES CHECK (completed_at IS NULL OR completed_at >= scheduled_at);
GO

-- SERVICE_PACKAGE
ALTER TABLE dbo.SERVICE_PACKAGE
    ADD CONSTRAINT CK_PACKAGE_PRICE CHECK (price >= 0),
        CONSTRAINT CK_PACKAGE_DURATION CHECK (duration > 0),
        CONSTRAINT CK_PACKAGE_STATUS CHECK (status IN (N'Active', N'Inactive', N'Discontinued'));
GO

-- PROMOTION
ALTER TABLE dbo.PROMOTION
    ADD CONSTRAINT CK_PROMOTION_DISCOUNT_TYPE CHECK (discount_type IN (N'Percentage', N'Fixed_Amount')),
        CONSTRAINT CK_PROMOTION_DISCOUNT_VALUE CHECK (discount_value > 0),
        CONSTRAINT CK_PROMOTION_STATUS CHECK (status IN (N'Active', N'Expired', N'Disabled')),
        CONSTRAINT CK_PROMOTION_DATES CHECK (end_at >= start_at);
GO

-- RESERVATION
ALTER TABLE dbo.RESERVATION
    ADD CONSTRAINT CK_RESERVATION_DATES CHECK (end_time >= start_time),
        CONSTRAINT CK_RESERVATION_TOTAL_AMOUNT CHECK (total_amount >= 0),
        CONSTRAINT CK_RESERVATION_STATUS CHECK (status IN (N'Pending', N'Confirmed', N'In_Progress', N'Completed', N'Cancelled'));
GO

-- PAYMENT
ALTER TABLE dbo.PAYMENT
    ADD CONSTRAINT CK_PAYMENT_AMOUNT CHECK (amount > 0),
        CONSTRAINT CK_PAYMENT_METHOD CHECK (payment_method IN (N'Credit Card', N'Bank Transfer', N'E-Wallet', N'Cash', N'VNPay', N'Momo')),
        CONSTRAINT CK_PAYMENT_STATUS CHECK (payment_status IN (N'Pending', N'Success', N'Failed', N'Refunded'));
GO

-- SERVICE_SESSION
ALTER TABLE dbo.SERVICE_SESSION
    ADD CONSTRAINT CK_SERVICE_SESSION_DATES CHECK (check_out IS NULL OR check_out >= check_in),
        CONSTRAINT CK_SERVICE_SESSION_STATUS CHECK (status IN (N'Active', N'Completed', N'Overtime', N'Terminated'));
GO

-- REVIEW
ALTER TABLE dbo.REVIEW
    ADD CONSTRAINT CK_REVIEW_RATING CHECK (rating BETWEEN 1 AND 5);
GO

-- COMMUNITY_CONTENT
ALTER TABLE dbo.COMMUNITY_CONTENT
    ADD CONSTRAINT CK_CONTENT_TYPE CHECK (content_type IN (N'Article', N'Tutorial', N'Darkroom Technique', N'Equipment Review', N'Discussion')),
        CONSTRAINT CK_CONTENT_STATUS CHECK (status IN (N'Draft', N'Published', N'Archived', N'Flagged'));
GO

-- WORKSHOP
ALTER TABLE dbo.WORKSHOP
    ADD CONSTRAINT CK_WORKSHOP_DATES CHECK (end_time >= start_time),
        CONSTRAINT CK_WORKSHOP_CAPACITY CHECK (capacity > 0),
        CONSTRAINT CK_WORKSHOP_PRICE CHECK (price >= 0),
        CONSTRAINT CK_WORKSHOP_STATUS CHECK (status IN (N'Upcoming', N'Ongoing', N'Completed', N'Cancelled'));
GO

-- COMPLAINT
ALTER TABLE dbo.COMPLAINT
    ADD CONSTRAINT CK_COMPLAINT_STATUS CHECK (status IN (N'Open', N'In_Investigation', N'Resolved', N'Rejected')),
        CONSTRAINT CK_COMPLAINT_DATES CHECK (resolved_at IS NULL OR resolved_at >= created_at);
GO

-- CÁC QUAN HỆ TRUNG GIAN
ALTER TABLE dbo.PACKAGE_RESOURCE
    ADD CONSTRAINT CK_PACKAGE_RESOURCE_QUANTITY CHECK (quantity > 0);
GO

ALTER TABLE dbo.RESERVATION_RESOURCE
    ADD CONSTRAINT CK_RESERVATION_RESOURCE_QUANTITY CHECK (quantity > 0);
GO

ALTER TABLE dbo.SESSION_RESOURCE
    ADD CONSTRAINT CK_SESSION_RESOURCE_QUANTITY CHECK (quantity > 0);
GO

-- ============================================================================
-- 2. CHỈ MỤC NON-CLUSTERED INDEXES (PERFORMANCE OPTIMIZATION)
-- ============================================================================

-- USER Indexes
CREATE NONCLUSTERED INDEX IX_USER_Role_Status ON dbo.[USER] (role, status)
    INCLUDE (full_name, email);
GO

-- SERVICE_PROVIDER Indexes
CREATE NONCLUSTERED INDEX IX_SERVICE_PROVIDER_Status ON dbo.SERVICE_PROVIDER (status)
    INCLUDE (business_name, address);
GO

-- CREATIVE_SPACE Indexes
CREATE NONCLUSTERED INDEX IX_CREATIVE_SPACE_ProviderId ON dbo.CREATIVE_SPACE (provider_id);
CREATE NONCLUSTERED INDEX IX_CREATIVE_SPACE_Type_Status ON dbo.CREATIVE_SPACE (space_type, status)
    INCLUDE (name, pricing, capacity);
GO

-- RESOURCE Indexes
CREATE NONCLUSTERED INDEX IX_RESOURCE_ProviderId ON dbo.RESOURCE (provider_id);
CREATE NONCLUSTERED INDEX IX_RESOURCE_Type_Status ON dbo.RESOURCE (resource_type, status)
    INCLUDE (name, rental_price, quantity, condition);
GO

-- MAINTENANCE Indexes
CREATE NONCLUSTERED INDEX IX_MAINTENANCE_ResourceId ON dbo.MAINTENANCE (resource_id);
CREATE NONCLUSTERED INDEX IX_MAINTENANCE_Scheduled_Status ON dbo.MAINTENANCE (scheduled_at, status);
GO

-- SERVICE_PACKAGE Indexes
CREATE NONCLUSTERED INDEX IX_SERVICE_PACKAGE_ProviderId ON dbo.SERVICE_PACKAGE (provider_id);
CREATE NONCLUSTERED INDEX IX_SERVICE_PACKAGE_Status ON dbo.SERVICE_PACKAGE (status)
    INCLUDE (name, price, duration);
GO

-- PROMOTION Indexes
CREATE NONCLUSTERED INDEX IX_PROMOTION_ProviderId ON dbo.PROMOTION (provider_id);
CREATE NONCLUSTERED INDEX IX_PROMOTION_DateRange ON dbo.PROMOTION (start_at, end_at, status);
GO

-- RESERVATION Indexes
CREATE NONCLUSTERED INDEX IX_RESERVATION_UserId ON dbo.RESERVATION (user_id);
CREATE NONCLUSTERED INDEX IX_RESERVATION_PackageId ON dbo.RESERVATION (package_id);
CREATE NONCLUSTERED INDEX IX_RESERVATION_TimeRange ON dbo.RESERVATION (start_time, end_time, status);
GO

-- PAYMENT Indexes
CREATE NONCLUSTERED INDEX IX_PAYMENT_Status ON dbo.PAYMENT (payment_status, paid_at)
    INCLUDE (reservation_id, amount, payment_method);
GO

-- SERVICE_SESSION Indexes
CREATE NONCLUSTERED INDEX IX_SERVICE_SESSION_CheckIn ON dbo.SERVICE_SESSION (check_in, status);
GO

-- REVIEW Indexes
CREATE NONCLUSTERED INDEX IX_REVIEW_UserId ON dbo.REVIEW (user_id);
CREATE NONCLUSTERED INDEX IX_REVIEW_Rating ON dbo.REVIEW (rating);
GO

-- COMMUNITY_CONTENT Indexes
CREATE NONCLUSTERED INDEX IX_COMMUNITY_CONTENT_UserId ON dbo.COMMUNITY_CONTENT (user_id);
CREATE NONCLUSTERED INDEX IX_COMMUNITY_CONTENT_Type_Status ON dbo.COMMUNITY_CONTENT (content_type, status, created_at);
GO

-- WORKSHOP Indexes
CREATE NONCLUSTERED INDEX IX_WORKSHOP_OrganizerId ON dbo.WORKSHOP (organizer_id);
CREATE NONCLUSTERED INDEX IX_WORKSHOP_Time_Status ON dbo.WORKSHOP (start_time, end_time, status);
GO

-- PHOTO Indexes
CREATE NONCLUSTERED INDEX IX_PHOTO_UserId ON dbo.PHOTO (user_id, created_at);
GO

-- COMPLAINT Indexes
CREATE NONCLUSTERED INDEX IX_COMPLAINT_UserId_Status ON dbo.COMPLAINT (user_id, status);
GO

-- INTERMEDIATE RELATION INDEXES
CREATE NONCLUSTERED INDEX IX_PACKAGE_SPACE_SpaceId ON dbo.PACKAGE_SPACE (space_id);
CREATE NONCLUSTERED INDEX IX_PACKAGE_RESOURCE_ResourceId ON dbo.PACKAGE_RESOURCE (resource_id);
CREATE NONCLUSTERED INDEX IX_RESERVATION_SPACE_SpaceId ON dbo.RESERVATION_SPACE (space_id);
CREATE NONCLUSTERED INDEX IX_RESERVATION_RESOURCE_ResourceId ON dbo.RESERVATION_RESOURCE (resource_id);
CREATE NONCLUSTERED INDEX IX_SESSION_RESOURCE_ResourceId ON dbo.SESSION_RESOURCE (resource_id);
CREATE NONCLUSTERED INDEX IX_WORKSHOP_REG_WorkshopId ON dbo.WORKSHOP_REGISTRATION (workshop_id);
GO

PRINT N'>> Created all domain CHECK constraints and Non-Clustered Indexes successfully.';
GO
