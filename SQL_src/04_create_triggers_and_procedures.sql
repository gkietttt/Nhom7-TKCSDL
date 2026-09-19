-- ============================================================================
-- SCRIPT 04: CREATE TRIGGERS, PROCEDURES & VIEWS
-- Project: Platform Connecting Film Photography Community with Darkroom & Studio Services
-- Exactly matching functional requirements & BCNF handling in Chapter 3 & 4
-- ============================================================================

USE FilmPhotographyDB;
GO

-- ============================================================================
-- 1. TRIGGERS (TỰ ĐỘNG HÓA VÀ RÀNG BUỘC PHỨC HỢP)
-- ============================================================================

-- Trigger 1: Tự động tính toán actual_usage_duration (phút) trong SERVICE_SESSION
-- (Giải pháp kiểm soát thuộc tính dẫn xuất theo phân tích Chuẩn hóa BCNF - Chương 3)
IF OBJECT_ID('dbo.trg_SERVICE_SESSION_CalculateDuration', 'TR') IS NOT NULL
    DROP TRIGGER dbo.trg_SERVICE_SESSION_CalculateDuration;
GO

CREATE TRIGGER dbo.trg_SERVICE_SESSION_CalculateDuration
ON dbo.SERVICE_SESSION
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    -- Cập nhật actual_usage_duration bằng hiệu số phút giữa check_in và check_out
    IF UPDATE(check_in) OR UPDATE(check_out)
    BEGIN
        UPDATE s
        SET s.actual_usage_duration = CASE 
            WHEN i.check_out IS NOT NULL AND i.check_out >= i.check_in 
                THEN DATEDIFF(MINUTE, i.check_in, i.check_out)
            ELSE s.actual_usage_duration
        END
        FROM dbo.SERVICE_SESSION s

        INNER JOIN inserted i ON s.session_id = i.session_id;
    END
END;
GO

-- Trigger 2: Cập nhật updated_at trong COMMUNITY_CONTENT khi có chỉnh sửa
IF OBJECT_ID('dbo.trg_COMMUNITY_CONTENT_UpdateTimestamp', 'TR') IS NOT NULL
    DROP TRIGGER dbo.trg_COMMUNITY_CONTENT_UpdateTimestamp;
GO

CREATE TRIGGER dbo.trg_COMMUNITY_CONTENT_UpdateTimestamp
ON dbo.COMMUNITY_CONTENT
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE c
    SET c.updated_at = SYSDATETIME()
    FROM dbo.COMMUNITY_CONTENT c
    INNER JOIN inserted i ON c.content_id = i.content_id;
END;
GO

-- Trigger 3: Cập nhật updated_at trong PHOTO khi có chỉnh sửa
IF OBJECT_ID('dbo.trg_PHOTO_UpdateTimestamp', 'TR') IS NOT NULL
    DROP TRIGGER dbo.trg_PHOTO_UpdateTimestamp;
GO

CREATE TRIGGER dbo.trg_PHOTO_UpdateTimestamp
ON dbo.PHOTO
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE p
    SET p.updated_at = SYSDATETIME()
    FROM dbo.PHOTO p
    INNER JOIN inserted i ON p.photo_id = i.photo_id;
END;
GO

-- Trigger 4: Giữ các quan hệ package/resource/space trong cùng provider
IF OBJECT_ID('dbo.trg_PACKAGE_SPACE_Provider', 'TR') IS NOT NULL
    DROP TRIGGER dbo.trg_PACKAGE_SPACE_Provider;
GO

CREATE TRIGGER dbo.trg_PACKAGE_SPACE_Provider
ON dbo.PACKAGE_SPACE
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (
        SELECT 1
        FROM inserted i
        INNER JOIN dbo.SERVICE_PACKAGE p ON p.package_id = i.package_id
        INNER JOIN dbo.CREATIVE_SPACE s ON s.space_id = i.space_id
        WHERE p.provider_id <> s.provider_id
    )
        THROW 51003, N'Package and creative space must belong to the same provider.', 1;
END;
GO

IF OBJECT_ID('dbo.trg_PACKAGE_RESOURCE_Provider', 'TR') IS NOT NULL
    DROP TRIGGER dbo.trg_PACKAGE_RESOURCE_Provider;
GO

CREATE TRIGGER dbo.trg_PACKAGE_RESOURCE_Provider
ON dbo.PACKAGE_RESOURCE
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (
        SELECT 1
        FROM inserted i
        INNER JOIN dbo.SERVICE_PACKAGE p ON p.package_id = i.package_id
        INNER JOIN dbo.RESOURCE r ON r.resource_id = i.resource_id
        WHERE p.provider_id <> r.provider_id
    )
        THROW 51004, N'Package and resource must belong to the same provider.', 1;
END;
GO

-- Reservation không có package có thể chọn trực tiếp; nếu có package thì phải cùng provider.
IF OBJECT_ID('dbo.trg_RESERVATION_SPACE_Provider', 'TR') IS NOT NULL
    DROP TRIGGER dbo.trg_RESERVATION_SPACE_Provider;
GO

CREATE TRIGGER dbo.trg_RESERVATION_SPACE_Provider
ON dbo.RESERVATION_SPACE
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (
        SELECT 1
        FROM inserted i
        INNER JOIN dbo.RESERVATION r ON r.reservation_id = i.reservation_id
        INNER JOIN dbo.SERVICE_PACKAGE p ON p.package_id = r.package_id
        INNER JOIN dbo.CREATIVE_SPACE s ON s.space_id = i.space_id
        WHERE p.provider_id <> s.provider_id
    )
        THROW 51005, N'Reservation space must belong to the package provider.', 1;
END;
GO

IF OBJECT_ID('dbo.trg_RESERVATION_RESOURCE_Provider', 'TR') IS NOT NULL
    DROP TRIGGER dbo.trg_RESERVATION_RESOURCE_Provider;
GO

CREATE TRIGGER dbo.trg_RESERVATION_RESOURCE_Provider
ON dbo.RESERVATION_RESOURCE
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (
        SELECT 1
        FROM inserted i
        INNER JOIN dbo.RESERVATION r ON r.reservation_id = i.reservation_id
        INNER JOIN dbo.SERVICE_PACKAGE p ON p.package_id = r.package_id
        INNER JOIN dbo.RESOURCE res ON res.resource_id = i.resource_id
        WHERE p.provider_id <> res.provider_id
    )
        THROW 51006, N'Reservation resource must belong to the package provider.', 1;
END;
GO

IF OBJECT_ID('dbo.trg_SESSION_RESOURCE_Provider', 'TR') IS NOT NULL
    DROP TRIGGER dbo.trg_SESSION_RESOURCE_Provider;
GO

CREATE TRIGGER dbo.trg_SESSION_RESOURCE_Provider
ON dbo.SESSION_RESOURCE
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (
        SELECT 1
        FROM inserted i
        INNER JOIN dbo.SERVICE_SESSION s ON s.session_id = i.session_id
        INNER JOIN dbo.RESERVATION r ON r.reservation_id = s.reservation_id
        INNER JOIN dbo.SERVICE_PACKAGE p ON p.package_id = r.package_id
        INNER JOIN dbo.RESOURCE res ON res.resource_id = i.resource_id
        WHERE p.provider_id <> res.provider_id
    )
        THROW 51007, N'Session resource must belong to the package provider.', 1;
END;
GO

-- Review chỉ được tạo bởi user đã thực hiện reservation tương ứng.
IF OBJECT_ID('dbo.trg_REVIEW_UserReservation', 'TR') IS NOT NULL
    DROP TRIGGER dbo.trg_REVIEW_UserReservation;
GO

CREATE TRIGGER dbo.trg_REVIEW_UserReservation
ON dbo.REVIEW
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (
        SELECT 1
        FROM inserted i
        INNER JOIN dbo.RESERVATION r ON r.reservation_id = i.reservation_id
        WHERE i.user_id <> r.user_id
    )
        THROW 51008, N'Review user must match the reservation user.', 1;
END;
GO

-- ============================================================================
-- 2. VIEWS (KHUNG NHÌN BÁO CÁO & TRUY VẤN TỔNG HỢP)
-- ============================================================================

-- View 1: Tổng hợp chi tiết đặt chỗ và trạng thái thanh toán, phiên sử dụng
IF OBJECT_ID('dbo.vw_ReservationDetails', 'V') IS NOT NULL
    DROP VIEW dbo.vw_ReservationDetails;
GO

CREATE VIEW dbo.vw_ReservationDetails
AS
SELECT 
    r.reservation_id,
    u.user_id,
    u.full_name AS customer_name,
    u.email AS customer_email,
    u.phone AS customer_phone,
    sp.package_id,
    sp.name AS package_name,
    pvd.provider_id,
    pvd.business_name AS provider_name,
    r.start_time,
    r.end_time,
    r.status AS reservation_status,
    r.total_amount,
    pm.payment_id,
    pm.payment_status,
    pm.payment_method,
    pm.transaction_code,
    pm.paid_at,
    ss.session_id,
    ss.check_in,
    ss.check_out,
    ss.actual_usage_duration,
    ss.status AS session_status,
    rw.rating AS review_rating,
    rw.comment AS review_comment
FROM dbo.RESERVATION r
INNER JOIN dbo.[USER] u ON r.user_id = u.user_id
LEFT JOIN dbo.SERVICE_PACKAGE sp ON r.package_id = sp.package_id
LEFT JOIN dbo.SERVICE_PROVIDER pvd ON sp.provider_id = pvd.provider_id
LEFT JOIN dbo.PAYMENT pm ON r.reservation_id = pm.reservation_id
LEFT JOIN dbo.SERVICE_SESSION ss ON r.reservation_id = ss.reservation_id
LEFT JOIN dbo.REVIEW rw ON r.reservation_id = rw.reservation_id;
GO

-- View 2: Tổng quan tài nguyên và không gian theo nhà cung cấp
IF OBJECT_ID('dbo.vw_ProviderOverview', 'V') IS NOT NULL
    DROP VIEW dbo.vw_ProviderOverview;
GO

CREATE VIEW dbo.vw_ProviderOverview
AS
SELECT 
    p.provider_id,
    p.business_name,
    p.address,
    p.status AS provider_status,
    COUNT(DISTINCT cs.space_id) AS total_spaces,
    COUNT(DISTINCT res.resource_id) AS total_resources,
    COUNT(DISTINCT spk.package_id) AS total_packages,
    COUNT(DISTINCT pro.promotion_id) AS total_promotions
FROM dbo.SERVICE_PROVIDER p
LEFT JOIN dbo.CREATIVE_SPACE cs ON p.provider_id = cs.provider_id
LEFT JOIN dbo.RESOURCE res ON p.provider_id = res.provider_id
LEFT JOIN dbo.SERVICE_PACKAGE spk ON p.provider_id = spk.provider_id
LEFT JOIN dbo.PROMOTION pro ON p.provider_id = pro.provider_id
GROUP BY p.provider_id, p.business_name, p.address, p.status;
GO

-- View 3: Thống kê đăng ký Workshop
IF OBJECT_ID('dbo.vw_WorkshopStatistics', 'V') IS NOT NULL
    DROP VIEW dbo.vw_WorkshopStatistics;
GO

CREATE VIEW dbo.vw_WorkshopStatistics
AS
SELECT 
    w.workshop_id,
    w.title,
    w.topic,
    u.full_name AS organizer_name,
    w.start_time,
    w.end_time,
    w.capacity,
    w.price,
    w.status,
    COUNT(wr.user_id) AS registered_attendees,
    (w.capacity - COUNT(wr.user_id)) AS remaining_seats,
    (COUNT(wr.user_id) * w.price) AS total_revenue
FROM dbo.WORKSHOP w
INNER JOIN dbo.[USER] u ON w.organizer_id = u.user_id
LEFT JOIN dbo.WORKSHOP_REGISTRATION wr ON w.workshop_id = wr.workshop_id
GROUP BY w.workshop_id, w.title, w.topic, u.full_name, w.start_time, w.end_time, w.capacity, w.price, w.status;
GO

-- ============================================================================
-- 3. STORED PROCEDURES (THỦ TỤC XỬ LÝ NGHIỆP VỤ)
-- ============================================================================

-- Procedure 1: Tra cứu không gian sáng tạo khả dụng theo khung giờ
IF OBJECT_ID('dbo.sp_SearchAvailableSpaces', 'P') IS NOT NULL
    DROP PROCEDURE dbo.sp_SearchAvailableSpaces;
GO

CREATE PROCEDURE dbo.sp_SearchAvailableSpaces
    @StartTime DATETIME2(0),
    @EndTime DATETIME2(0),
    @SpaceType NVARCHAR(50) = NULL,
    @MinCapacity INT = 1
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        cs.space_id,
        cs.name,
        cs.space_type,
        cs.area,
        cs.capacity,
        cs.pricing,
        cs.artistic_style,
        sp.business_name AS provider_name,
        sp.address AS provider_address
    FROM dbo.CREATIVE_SPACE cs
    INNER JOIN dbo.SERVICE_PROVIDER sp ON cs.provider_id = sp.provider_id
    WHERE cs.status = N'Available'
      AND sp.status = N'Active'
      AND (@SpaceType IS NULL OR cs.space_type = @SpaceType)
      AND cs.capacity >= @MinCapacity
      AND cs.space_id NOT IN (
          -- Loại trừ các không gian đã được đặt trùng thời gian
          SELECT rs.space_id
          FROM dbo.RESERVATION_SPACE rs
          INNER JOIN dbo.RESERVATION r ON rs.reservation_id = r.reservation_id
          WHERE r.status IN (N'Pending', N'Confirmed', N'In_Progress')
            AND (
                (@StartTime >= r.start_time AND @StartTime < r.end_time) OR
                (@EndTime > r.start_time AND @EndTime <= r.end_time) OR
                (@StartTime <= r.start_time AND @EndTime >= r.end_time)
            )
      );
END;
GO

-- Procedure 2: Thống kê doanh thu theo từng nhà cung cấp trong khoảng thời gian
IF OBJECT_ID('dbo.sp_GetProviderRevenueReport', 'P') IS NOT NULL
    DROP PROCEDURE dbo.sp_GetProviderRevenueReport;
GO

CREATE PROCEDURE dbo.sp_GetProviderRevenueReport
    @FromDate DATETIME2(0) = NULL,
    @ToDate DATETIME2(0) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        sp.provider_id,
        sp.business_name,
        COUNT(DISTINCT r.reservation_id) AS total_reservations,
        COUNT(DISTINCT pm.payment_id) AS successful_payments,
        ISNULL(SUM(pm.amount), 0) AS total_revenue
    FROM dbo.SERVICE_PROVIDER sp
    LEFT JOIN dbo.SERVICE_PACKAGE pkg ON sp.provider_id = pkg.provider_id
    LEFT JOIN dbo.RESERVATION r ON pkg.package_id = r.package_id
    LEFT JOIN dbo.PAYMENT pm ON r.reservation_id = pm.reservation_id AND pm.payment_status = N'Success'
    WHERE (@FromDate IS NULL OR pm.paid_at >= @FromDate)
      AND (@ToDate IS NULL OR pm.paid_at <= @ToDate)
    GROUP BY sp.provider_id, sp.business_name
    ORDER BY total_revenue DESC;
END;
GO

PRINT N'>> Created Triggers, Views, and Stored Procedures successfully.';
GO
