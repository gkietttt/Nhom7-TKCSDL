-- ============================================================================
-- SCRIPT 05: SEED DATA
-- Project: Platform Connecting Film Photography Community with Darkroom & Studio Services
-- Exactly matching the target record count in plan_db.md
-- ============================================================================

USE FilmPhotographyDB;
GO

SET NOCOUNT ON;

PRINT N'>> Starting data seeding process...';

-- Tắt kiểm tra ràng buộc và triggers tạm thời trong quá trình nạp để tối ưu hiệu năng
EXEC sp_MSforeachtable "ALTER TABLE ? NOCHECK CONSTRAINT ALL";
EXEC sp_MSforeachtable "ALTER TABLE ? DISABLE TRIGGER ALL";
GO

-- Xóa sạch dữ liệu cũ
DELETE FROM dbo.WORKSHOP_REGISTRATION;
DELETE FROM dbo.SESSION_RESOURCE;
DELETE FROM dbo.RESERVATION_RESOURCE;
DELETE FROM dbo.RESERVATION_SPACE;
DELETE FROM dbo.PACKAGE_RESOURCE;
DELETE FROM dbo.PACKAGE_SPACE;
DELETE FROM dbo.COMPLAINT;
DELETE FROM dbo.PHOTO;
DELETE FROM dbo.WORKSHOP;
DELETE FROM dbo.COMMUNITY_CONTENT;
DELETE FROM dbo.REVIEW;
DELETE FROM dbo.SERVICE_SESSION;
DELETE FROM dbo.PAYMENT;
DELETE FROM dbo.RESERVATION;
DELETE FROM dbo.PROMOTION;
DELETE FROM dbo.SERVICE_PACKAGE;
DELETE FROM dbo.MAINTENANCE;
DELETE FROM dbo.RESOURCE;
DELETE FROM dbo.CREATIVE_SPACE;
DELETE FROM dbo.SERVICE_PROVIDER;
DELETE FROM dbo.[USER];
GO

-- Reset IDENTITY
DBCC CHECKIDENT ('dbo.USER', RESEED, 1);
DBCC CHECKIDENT ('dbo.SERVICE_PROVIDER', RESEED, 1);
DBCC CHECKIDENT ('dbo.CREATIVE_SPACE', RESEED, 1);
DBCC CHECKIDENT ('dbo.RESOURCE', RESEED, 1);
DBCC CHECKIDENT ('dbo.MAINTENANCE', RESEED, 1);
DBCC CHECKIDENT ('dbo.SERVICE_PACKAGE', RESEED, 1);
DBCC CHECKIDENT ('dbo.PROMOTION', RESEED, 1);
DBCC CHECKIDENT ('dbo.RESERVATION', RESEED, 1);
DBCC CHECKIDENT ('dbo.PAYMENT', RESEED, 1);
DBCC CHECKIDENT ('dbo.SERVICE_SESSION', RESEED, 1);
DBCC CHECKIDENT ('dbo.REVIEW', RESEED, 1);
DBCC CHECKIDENT ('dbo.COMMUNITY_CONTENT', RESEED, 1);
DBCC CHECKIDENT ('dbo.WORKSHOP', RESEED, 1);
DBCC CHECKIDENT ('dbo.PHOTO', RESEED, 1);
DBCC CHECKIDENT ('dbo.COMPLAINT', RESEED, 1);
GO

-- ============================================================================
-- 1. SEED BẢNG USER (Mục tiêu: 10,000 bản ghi)
-- Gồm: Photographer (7,000), Service Provider (1,500), Expert (1,000), Administrator (500)
-- ============================================================================
PRINT N'>> Seeding [USER] (10,000 records)...';

;WITH Numbers(n) AS (
    SELECT TOP (10000) ROW_NUMBER() OVER (ORDER BY (SELECT NULL))
    FROM sys.all_objects a CROSS JOIN sys.all_objects b
),
Names(id, last_name, first_name) AS (
    SELECT n,
        CASE (n % 10)
            WHEN 0 THEN N'Nguyễn' WHEN 1 THEN N'Trần' WHEN 2 THEN N'Lê' WHEN 3 THEN N'Phạm'
            WHEN 4 THEN N'Hoàng' WHEN 5 THEN N'Huỳnh' WHEN 6 THEN N'Phan' WHEN 7 THEN N'Vũ'
            WHEN 8 THEN N'Võ' ELSE N'Đặng'
        END,
        CASE (n % 10)
            WHEN 0 THEN N'Minh Quân' WHEN 1 THEN N'Hải Đăng' WHEN 2 THEN N'Gia Bảo' WHEN 3 THEN N'Anh Tuấn'
            WHEN 4 THEN N'Phương Nam' WHEN 5 THEN N'Thanh Trúc' WHEN 6 THEN N'Hoàng Yến' WHEN 7 THEN N'Quốc Bảo'
            WHEN 8 THEN N'Thảo Nhi' ELSE N'Khánh Linh'
        END
    FROM Numbers
)
INSERT INTO dbo.[USER] (full_name, email, phone, password, role, status, created_at)
SELECT 
    last_name + N' ' + first_name + N' ' + CAST(id AS NVARCHAR(10)),
    N'user' + CAST(id AS NVARCHAR(10)) + N'@filmphoto.vn',
    N'090' + RIGHT(N'0000000' + CAST(id AS NVARCHAR(10)), 7),
    N'$2a$12$e9.jK63aGqH19QYk4v2.7O/xN7f.V9r4P58E/2.Bw2a1w2.9d6F2O', -- bcrpyt hash giả lập
    CASE 
        WHEN id <= 500 THEN N'Administrator'
        WHEN id <= 1500 THEN N'Expert'
        WHEN id <= 3000 THEN N'Service Provider'
        ELSE N'Photographer'
    END,
    CASE WHEN id % 25 = 0 THEN N'Inactive' ELSE N'Active' END,
    DATEADD(DAY, -(id % 730), '2026-07-01 08:00:00')
FROM Names;
GO

-- ============================================================================
-- 2. SEED BẢNG SERVICE_PROVIDER (Mục tiêu: 1,000 bản ghi)
-- ============================================================================
PRINT N'>> Seeding SERVICE_PROVIDER (1,000 records)...';

;WITH Numbers(n) AS (
    SELECT TOP (1000) ROW_NUMBER() OVER (ORDER BY (SELECT NULL))
    FROM sys.all_objects a CROSS JOIN sys.all_objects b
)
INSERT INTO dbo.SERVICE_PROVIDER (business_name, description, address, status, created_at)
SELECT 
    CASE (n % 5)
        WHEN 0 THEN N'Darkroom Sài Gòn Studio ' + CAST(n AS NVARCHAR(10))
        WHEN 1 THEN N'Hà Nội Film Lab & Darkroom ' + CAST(n AS NVARCHAR(10))
        WHEN 2 THEN N'Đà Nẵng Vintage Studio ' + CAST(n AS NVARCHAR(10))
        WHEN 3 THEN N'Analog Space Vietnam ' + CAST(n AS NVARCHAR(10))
        ELSE N'Phòng Tối Nghệ Thuật ' + CAST(n AS NVARCHAR(10))
    END,
    N'Không gian nhiếp ảnh phim chuyên nghiệp, cung cấp buồng tối tráng rọi, studio chụp ảnh nghệ thuật và thiết bị analog cao cấp.',
    CASE (n % 4)
        WHEN 0 THEN CAST(n * 12 AS NVARCHAR(10)) + N' Nguyễn Trãi, Quận 1, TP. Hồ Chí Minh'
        WHEN 1 THEN CAST(n * 15 AS NVARCHAR(10)) + N' Hoàng Hoa Thám, Ba Đình, Hà Nội'
        WHEN 2 THEN CAST(n * 8 AS NVARCHAR(10)) + N' Bạch Đằng, Hải Châu, Đà Nẵng'
        ELSE CAST(n * 21 AS NVARCHAR(10)) + N' Phan Đăng Lưu, Phú Nhuận, TP. Hồ Chí Minh'
    END,
    CASE WHEN n % 20 = 0 THEN N'Pending_Approval' ELSE N'Active' END,
    DATEADD(DAY, -(n % 365), '2026-07-01 09:00:00')
FROM Numbers;
GO

-- ============================================================================
-- 3. SEED BẢNG CREATIVE_SPACE (Mục tiêu: 3,000 bản ghi)
-- Trung bình 3 không gian / provider
-- ============================================================================
PRINT N'>> Seeding CREATIVE_SPACE (3,000 records)...';

;WITH Numbers(n) AS (
    SELECT TOP (3000) ROW_NUMBER() OVER (ORDER BY (SELECT NULL))
    FROM sys.all_objects a CROSS JOIN sys.all_objects b
)
INSERT INTO dbo.CREATIVE_SPACE (
    provider_id, name, space_type, description, area, capacity,
    artistic_style, lighting_condition, ventilation, acoustic_characteristics,
    operating_hours, usage_policy, pricing, status
)
SELECT 
    ((n - 1) % 1000) + 1, -- Phân bổ đều cho 1,000 provider (mỗi provider 3 không gian)
    CASE (n % 4)
        WHEN 0 THEN N'Darkroom Classic Room ' + CAST(n AS NVARCHAR(10))
        WHEN 1 THEN N'Studio Ánh Sáng Tự Nhiên ' + CAST(n AS NVARCHAR(10))
        WHEN 2 THEN N'Studio Chụp Chân Dung Vintage ' + CAST(n AS NVARCHAR(10))
        ELSE N'Không Gian Đa Năng Hybrid ' + CAST(n AS NVARCHAR(10))
    END,
    CASE (n % 4)
        WHEN 0 THEN N'Darkroom'
        WHEN 1 THEN N'Studio'
        WHEN 2 THEN N'Studio'
        ELSE N'Hybrid'
    END,
    N'Không gian trang bị đầy đủ hệ thống ánh sáng đỏ chuyên dụng, bồn rửa hóa chất inox, hệ thống hút khí độc tiêu chuẩn.',
    25.00 + (n % 10) * 5.0,
    2 + (n % 6),
    CASE (n % 3)
        WHEN 0 THEN N'Vintage 1980s'
        WHEN 1 THEN N'Minimalist Modern'
        ELSE N'Industrial Noir'
    END,
    CASE (n % 3)
        WHEN 0 THEN N'Đèn Safe-light đỏ & Amber chuyên dụng'
        WHEN 1 THEN N'Ánh sáng tự nhiên cửa kính lớn kèm rèm cản sáng'
        ELSE N'Hệ thống Continuous LED CRI > 95'
    END,
    N'Hệ thống thông gió cưỡng bức 2 chiều kèm màng lọc carbon',
    N'Cách âm tiêu chuẩn 35dB, không vang vọng',
    N'08:00 - 22:00 hàng ngày',
    N'Cấm mang đồ ăn vào buồng tối; bắt buộc mang bao tay bảo hộ khi tiếp xúc hóa chất.',
    120000.00 + (n % 8) * 25000.00,
    CASE WHEN n % 15 = 0 THEN N'Maintenance' ELSE N'Available' END
FROM Numbers;
GO

-- ============================================================================
-- 4. SEED BẢNG RESOURCE (Mục tiêu: 15,000 bản ghi)
-- Thiết bị, vật tư, dụng cụ phân bổ cho 1,000 provider
-- ============================================================================
PRINT N'>> Seeding RESOURCE (15,000 records)...';

;WITH Numbers(n) AS (
    SELECT TOP (15000) ROW_NUMBER() OVER (ORDER BY (SELECT NULL))
    FROM sys.all_objects a CROSS JOIN sys.all_objects b
)
INSERT INTO dbo.RESOURCE (
    provider_id, name, resource_type, description, quantity,
    condition, rental_price, compatibility_information, status
)
SELECT 
    ((n - 1) % 1000) + 1,
    CASE (n % 9)
        WHEN 0 THEN N'Máy ảnh Leica M3 Single Stroke ' + CAST(n AS NVARCHAR(10))
        WHEN 1 THEN N'Ống kính Carl Zeiss Planar 50mm f/1.4 ' + CAST(n AS NVARCHAR(10))
        WHEN 2 THEN N'Máy rọi ảnh Beseler 23C II Enlarger ' + CAST(n AS NVARCHAR(10))
        WHEN 3 THEN N'Máy quét phim Plustek OpticFilm 8200i Ai ' + CAST(n AS NVARCHAR(10))
        WHEN 4 THEN N'Bộ đèn Studio Godox QS400II Flash ' + CAST(n AS NVARCHAR(10))
        WHEN 5 THEN N'Bộ khay tráng Paterson Tank & Reels ' + CAST(n AS NVARCHAR(10))
        WHEN 6 THEN N'Hóa chất tráng phim Kodak D-76 (1 Gallon) ' + CAST(n AS NVARCHAR(10))
        WHEN 7 THEN N'Giấy rọi ảnh Ilford Multigrade RC Deluxe ' + CAST(n AS NVARCHAR(10))
        ELSE N'Chân máy Manfrotto 055 Pro ' + CAST(n AS NVARCHAR(10))
    END,
    CASE (n % 9)
        WHEN 0 THEN N'Camera'
        WHEN 1 THEN N'Lens'
        WHEN 2 THEN N'Enlarger'
        WHEN 3 THEN N'Film Scanner'
        WHEN 4 THEN N'Lighting'
        WHEN 5 THEN N'Darkroom Equipment'
        WHEN 6 THEN N'Chemicals'
        WHEN 7 THEN N'Photo Paper'
        ELSE N'Tripod & Rig'
    END,
    N'Tài nguyên chuyên dụng chất lượng cao, được cân chỉnh định kỳ, sẵn sàng phục vụ quy trình nhiếp ảnh analog.',
    CASE WHEN (n % 9) IN (6, 7) THEN 20 + (n % 30) ELSE 1 + (n % 3) END,
    CASE (n % 5)
        WHEN 0 THEN N'New'
        WHEN 1 THEN N'Good'
        WHEN 2 THEN N'Good'
        WHEN 3 THEN N'Fair'
        ELSE N'Need_Maintenance'
    END,
    30000.00 + (n % 10) * 20000.00,
    CASE (n % 4)
        WHEN 0 THEN N'Tương thích phim 35mm và 120 format'
        WHEN 1 THEN N'Ngàm Leica M / LTM'
        WHEN 2 THEN N'Ngàm Bowens tiêu chuẩn'
        ELSE N'Sử dụng chung cho tất cả dòng máy'
    END,
    N'Available'
FROM Numbers;
GO

-- ============================================================================
-- 5. SEED BẢNG MAINTENANCE (Mục tiêu: 18,000 bản ghi)
-- Lịch sử bảo trì tài nguyên
-- ============================================================================
PRINT N'>> Seeding MAINTENANCE (18,000 records)...';

;WITH Numbers(n) AS (
    SELECT TOP (18000) ROW_NUMBER() OVER (ORDER BY (SELECT NULL))
    FROM sys.all_objects a CROSS JOIN sys.all_objects b
)
INSERT INTO dbo.MAINTENANCE (
    resource_id, maintenance_type, description, scheduled_at,
    completed_at, cost, status
)
SELECT 
    CASE 
        WHEN n <= 14400 THEN ((n - 1) % 15000) + 1
        WHEN n <= 17100 THEN 10001 + (n - 14401) -- 2,700 thiết bị đang In_Progress tại kho (không trùng tài nguyên đặt chỗ)
        ELSE ((n - 1) % 15000) + 1
    END,
    CASE (n % 5)
        WHEN 0 THEN N'Routine'
        WHEN 1 THEN N'Repair'
        WHEN 2 THEN N'Calibration'
        WHEN 3 THEN N'Cleaning'
        ELSE N'Inspection'
    END,
    N'Bảo trì định kỳ: lau thấu kính, bôi trơn bánh răng, kiểm tra tốc độ màn trập và độ chính xác ánh sáng đèn.',
    CASE 
        WHEN n <= 17100 THEN DATEADD(DAY, -(120 - (n % 120)), '2026-08-10 10:00:00')
        ELSE DATEADD(DAY, 1 + (n % 30), '2026-08-10 10:00:00') -- Scheduled đặt lịch trong tương lai
    END,
    CASE 
        WHEN n <= 14400 THEN DATEADD(HOUR, 4 + (n % 8), DATEADD(DAY, -(120 - (n % 120)), '2026-08-10 10:00:00'))
        ELSE NULL 
    END,
    150000.00 + (n % 10) * 50000.00,
    CASE 
        WHEN n <= 14400 THEN N'Completed'
        WHEN n <= 17100 THEN N'In_Progress'
        ELSE N'Scheduled'
    END
FROM Numbers;
GO

-- Đồng bộ trạng thái Resource: Các tài nguyên đang bảo trì (In_Progress) chuyển sang trạng thái Maintenance
UPDATE res 
SET res.status = N'Maintenance'
FROM dbo.RESOURCE res
WHERE EXISTS (
    SELECT 1 FROM dbo.MAINTENANCE m
    WHERE m.resource_id = res.resource_id
      AND m.status = N'In_Progress'
);
GO

-- ============================================================================
-- 6. SEED BẢNG SERVICE_PACKAGE (Mục tiêu: 3,000 bản ghi)
-- Khoảng 3 package / provider
-- ============================================================================
PRINT N'>> Seeding SERVICE_PACKAGE (3,000 records)...';

;WITH Numbers(n) AS (
    SELECT TOP (3000) ROW_NUMBER() OVER (ORDER BY (SELECT NULL))
    FROM sys.all_objects a CROSS JOIN sys.all_objects b
)
INSERT INTO dbo.SERVICE_PACKAGE (
    provider_id, name, description, price, duration, status, created_at
)
SELECT 
    ((n - 1) % 1000) + 1,
    CASE (n % 4)
        WHEN 0 THEN N'Gói Tráng Rọi Phòng Tối Tiêu Chuẩn ' + CAST(n AS NVARCHAR(10))
        WHEN 1 THEN N'Gói Studio Chụp Chân Dung Analog ' + CAST(n AS NVARCHAR(10))
        WHEN 2 THEN N'Gói Workshop & Trải Nghiệm Film Master ' + CAST(n AS NVARCHAR(10))
        ELSE N'Gói Thuê Không Gian Tự Do Trọn Gói ' + CAST(n AS NVARCHAR(10))
    END,
    N'Bao gồm quyền sử dụng không gian sáng tạo, thiết bị rọi ảnh chuyên dụng, hóa chất tráng tiêu chuẩn và kỹ thuật viên hỗ trợ.',
    250000.00 + (n % 10) * 50000.00,
    2 + (n % 4), -- 2 đến 5 giờ
    CASE WHEN n % 30 = 0 THEN N'Inactive' ELSE N'Active' END,
    DATEADD(DAY, -(n % 365), '2026-07-01 08:00:00')
FROM Numbers;
GO

-- ============================================================================
-- 7. SEED BẢNG PROMOTION (Mục tiêu: 1,000 bản ghi)
-- Khuyến mãi của provider
-- ============================================================================
PRINT N'>> Seeding PROMOTION (1,000 records)...';

;WITH Numbers(n) AS (
    SELECT TOP (1000) ROW_NUMBER() OVER (ORDER BY (SELECT NULL))
    FROM sys.all_objects a CROSS JOIN sys.all_objects b
)
INSERT INTO dbo.PROMOTION (
    provider_id, name, description, discount_type, discount_value,
    start_at, end_at, status
)
SELECT 
    ((n - 1) % 1000) + 1,
    CASE (n % 4)
        WHEN 0 THEN N'Ưu Đãi Mùa Hè Film Lovers ' + CAST(n AS NVARCHAR(10))
        WHEN 1 THEN N'Tri Ân Thành Viên Darkroom ' + CAST(n AS NVARCHAR(10))
        WHEN 2 THEN N'Khuyến Mãi Cuối Tuần Studio ' + CAST(n AS NVARCHAR(10))
        ELSE N'Chào Đón Nhiếp Ảnh Gia Mới ' + CAST(n AS NVARCHAR(10))
    END,
    N'Giảm giá trực tiếp khi đặt phòng tối hoặc gói studio trọn gói qua hệ thống trực tuyến.',
    CASE WHEN n % 2 = 0 THEN N'Percentage' ELSE N'Fixed_Amount' END,
    CASE WHEN n % 2 = 0 THEN 10.00 + (n % 4) * 5.00 ELSE 50000.00 + (n % 5) * 20000.00 END,
    DATEADD(DAY, -(n % 60), '2026-08-01 00:00:00'),
    DATEADD(DAY, 30 + (n % 60), '2026-08-01 23:59:59'),
    CASE WHEN n % 10 = 0 THEN N'Expired' ELSE N'Active' END
FROM Numbers;
GO

-- ============================================================================
-- 8. SEED BẢNG RESERVATION (Mục tiêu: 16,000 bản ghi)
-- ============================================================================
PRINT N'>> Seeding RESERVATION (16,000 records)...';

;WITH Numbers(n) AS (
    SELECT TOP (16000) ROW_NUMBER() OVER (ORDER BY (SELECT NULL))
    FROM sys.all_objects a CROSS JOIN sys.all_objects b
)
INSERT INTO dbo.RESERVATION (
    user_id, package_id, start_time, end_time, status, total_amount, created_at
)
SELECT 
    3001 + ((n - 1) % 7000), -- Người đặt là các Photographer (user_id từ 3001 đến 10000)
    CASE WHEN n % 20 = 0 THEN NULL ELSE ((n - 1) % 3000) + 1 END,
    DATEADD(MINUTE, (n * 137) % 25000, '2026-08-01 08:00:00'),
    DATEADD(HOUR, 2 + (n % 4), DATEADD(MINUTE, (n * 137) % 25000, '2026-08-01 08:00:00')),
    CASE 
        WHEN n <= 15000 THEN N'Completed'
        WHEN n <= 15500 THEN N'Confirmed'
        ELSE N'Cancelled'
    END,
    300000.00 + (n % 15) * 50000.00,
    DATEADD(DAY, -2, DATEADD(MINUTE, (n * 137) % 25000, '2026-08-01 08:00:00'))
FROM Numbers;
GO

-- ============================================================================
-- 9. SEED BẢNG PAYMENT (Mục tiêu: 10,000 bản ghi)
-- Quan hệ 1:1 với RESERVATION (Áp dụng cho 10,000 reservation đã thanh toán)
-- ============================================================================
PRINT N'>> Seeding PAYMENT (10,000 records)...';

;WITH Numbers(n) AS (
    SELECT TOP (10000) ROW_NUMBER() OVER (ORDER BY (SELECT NULL))
    FROM sys.all_objects a CROSS JOIN sys.all_objects b
)
INSERT INTO dbo.PAYMENT (
    reservation_id, amount, payment_method, payment_status, transaction_code, paid_at
)
SELECT 
    n, -- Gán duy nhất cho 10,000 reservation đầu tiên
    300000.00 + (n % 15) * 50000.00,
    CASE (n % 6)
        WHEN 0 THEN N'VNPay'
        WHEN 1 THEN N'Momo'
        WHEN 2 THEN N'Bank Transfer'
        WHEN 3 THEN N'Credit Card'
        WHEN 4 THEN N'E-Wallet'
        ELSE N'Cash'
    END,
    CASE 
        WHEN n <= 9200 THEN N'Success'
        WHEN n <= 9600 THEN N'Pending'
        ELSE N'Refunded'
    END,
    N'TXN2026' + RIGHT(N'000000' + CAST(n AS NVARCHAR(10)), 6) + N'FP',
    DATEADD(MINUTE, 30, DATEADD(DAY, -2, DATEADD(MINUTE, (n * 137) % 25000, '2026-08-01 08:00:00')))
FROM Numbers;
GO

-- ============================================================================
-- 10. SEED BẢNG SERVICE_SESSION (Mục tiêu: 15,000 bản ghi)
-- Quan hệ 1:1 với RESERVATION (Áp dụng cho 15,000 reservation đã thực hiện)
-- ============================================================================
PRINT N'>> Seeding SERVICE_SESSION (15,000 records)...';

;WITH Numbers(n) AS (
    SELECT TOP (15000) ROW_NUMBER() OVER (ORDER BY (SELECT NULL))
    FROM sys.all_objects a CROSS JOIN sys.all_objects b
)
INSERT INTO dbo.SERVICE_SESSION (
    reservation_id, check_in, check_out, actual_usage_duration, status
)
SELECT 
    n, -- Gán duy nhất cho 15,000 reservation đã hoàn tất
    DATEADD(MINUTE, (n * 137) % 25000, '2026-08-01 08:00:00'),
    DATEADD(MINUTE, 120 + (n % 6) * 30, DATEADD(MINUTE, (n * 137) % 25000, '2026-08-01 08:00:00')),
    120 + (n % 6) * 30, -- Tự động khớp hiệu số phút
    CASE 
        WHEN n <= 14000 THEN N'Completed'
        WHEN n <= 14500 THEN N'Active'
        ELSE N'Overtime'
    END
FROM Numbers;
GO

-- ============================================================================
-- 11. SEED BẢNG REVIEW (Mục tiêu: 10,000 bản ghi)
-- Quan hệ 1:1 với RESERVATION (10,000 review từ reservation 1 đến 10,000)
-- ============================================================================
PRINT N'>> Seeding REVIEW (10,000 records)...';

;WITH Numbers(n) AS (
    SELECT TOP (10000) ROW_NUMBER() OVER (ORDER BY (SELECT NULL))
    FROM sys.all_objects a CROSS JOIN sys.all_objects b
)
INSERT INTO dbo.REVIEW (
    user_id, reservation_id, rating, comment, created_at
)
SELECT 
    r.user_id,
    n, -- Gán duy nhất cho 10,000 reservation đã hoàn tất
    4 + (n % 2), -- Đánh giá 4 hoặc 5 sao
    CASE (n % 5)
        WHEN 0 THEN N'Phòng tối rất sạch sẽ, máy rọi Beseler hoạt động chuẩn xác, safe-light an toàn!'
        WHEN 1 THEN N'Chất lượng studio analog tuyệt vời, ánh sáng tự nhiên đẹp, chủ studio nhiệt tình hỗ trợ.'
        WHEN 2 THEN N'Hóa chất tráng phim pha mới, tỉ lệ chuẩn xác, phim lên màu rất đẹp và trong trẻo.'
        WHEN 3 THEN N'Không gian rộng rãi, thoáng khí không bị nồng mùi hóa chất. Sẽ tiếp tục quay lại!'
        ELSE N'Trải nghiệm tuyệt vời cho người mới bắt đầu đam mê bộ môn phòng tối film photography.'
    END,
    DATEADD(HOUR, 2, DATEADD(MINUTE, 120 + (n % 6) * 30, DATEADD(MINUTE, (n * 137) % 25000, '2026-08-01 08:00:00')))
FROM Numbers n
INNER JOIN dbo.RESERVATION r ON r.reservation_id = n.n;
GO

-- ============================================================================
-- 12. SEED BẢNG COMMUNITY_CONTENT (Mục tiêu: 5,000 bản ghi)
-- ============================================================================
PRINT N'>> Seeding COMMUNITY_CONTENT (5,000 records)...';

;WITH Numbers(n) AS (
    SELECT TOP (5000) ROW_NUMBER() OVER (ORDER BY (SELECT NULL))
    FROM sys.all_objects a CROSS JOIN sys.all_objects b
)
INSERT INTO dbo.COMMUNITY_CONTENT (
    user_id, title, content, content_type, status, created_at, updated_at
)
SELECT 
    1 + ((n - 1) % 10000),
    CASE (n % 5)
        WHEN 0 THEN N'Hướng dẫn kỹ thuật push/pull phim B&W với thuốc Rodinal ' + CAST(n AS NVARCHAR(10))
        WHEN 1 THEN N'Kinh nghiệm chọn máy rọi phim khổ 35mm và 120 cho phòng tối tại gia ' + CAST(n AS NVARCHAR(10))
        WHEN 2 THEN N'Đánh giá chi tiết cuộn phim Kodak Tri-X 400 chụp chân dung ' + CAST(n AS NVARCHAR(10))
        WHEN 3 THEN N'Kỹ thuật Dodging và Burning nâng cao khi rọi ảnh giấy Ilford ' + CAST(n AS NVARCHAR(10))
        ELSE N'Thảo luận: Cách bảo quản hóa chất C-41 để dùng được lâu nhất ' + CAST(n AS NVARCHAR(10))
    END,
    N'Bài viết chia sẻ kinh nghiệm thực tế về kỹ thuật phòng tối analog, phân tích các lưu ý quan trọng khi kiểm soát nhiệt độ, thời gian ngâm thuốc và cách bảo quản film scan.',
    CASE (n % 5)
        WHEN 0 THEN N'Tutorial'
        WHEN 1 THEN N'Equipment Review'
        WHEN 2 THEN N'Article'
        WHEN 3 THEN N'Darkroom Technique'
        ELSE N'Discussion'
    END,
    CASE WHEN n % 20 = 0 THEN N'Draft' ELSE N'Published' END,
    DATEADD(DAY, -(150 - (n % 150)), '2026-08-20 14:00:00'),
    DATEADD(DAY, -(150 - (n % 150)), '2026-08-20 14:00:00')
FROM Numbers;
GO

-- ============================================================================
-- 13. SEED BẢNG WORKSHOP (Mục tiêu: 500 bản ghi)
-- Tổ chức bởi các Expert (user_id từ 501 đến 1500)
-- ============================================================================
PRINT N'>> Seeding WORKSHOP (500 records)...';

;WITH Numbers(n) AS (
    SELECT TOP (500) ROW_NUMBER() OVER (ORDER BY (SELECT NULL))
    FROM sys.all_objects a CROSS JOIN sys.all_objects b
)
INSERT INTO dbo.WORKSHOP (
    organizer_id, title, description, topic, start_time, end_time,
    capacity, location, price, status, created_at
)
SELECT 
    501 + ((n - 1) % 1000), -- Experts (user_id 501 đến 1500)
    CASE (n % 5)
        WHEN 0 THEN N'Masterclass: Kỹ Thuật Tráng Phim Đen Trắng Cổ Điển ' + CAST(n AS NVARCHAR(10))
        WHEN 1 THEN N'Workshop: Nghệ Thuật Rọi Ảnh Bằng Máy Phóng Beseler ' + CAST(n AS NVARCHAR(10))
        WHEN 2 THEN N'Khoá Học: Chụp Ảnh Chân Dung Studio Với Máy Medium Format ' + CAST(n AS NVARCHAR(10))
        WHEN 3 THEN N'Workshop: Phục Chế Và Scan Phim Âm Bản Độ Phân Giải Cao ' + CAST(n AS NVARCHAR(10))
        ELSE N'Tọa Đàm: Văn Hóa Và Xu Hướng Nhiếp Ảnh Analog Đương Đại ' + CAST(n AS NVARCHAR(10))
    END,
    N'Chương trình đào tạo thực hành chuyên sâu dành cho những ai đam mê nhiếp ảnh phim, cung cấp toàn bộ hóa chất và thiết bị thực hành.',
    CASE (n % 4)
        WHEN 0 THEN N'Darkroom Printing'
        WHEN 1 THEN N'Film Developing'
        WHEN 2 THEN N'Analog Studio Lighting'
        ELSE N'Fine Art Photography'
    END,
    DATEADD(DAY, (n * 3), '2026-08-15 09:00:00'),
    DATEADD(HOUR, 4, DATEADD(DAY, (n * 3), '2026-08-15 09:00:00')),
    10 + (n % 15),
    CASE (n % 3)
        WHEN 0 THEN N'Studio Darkroom Sài Gòn, 12 Nguyễn Trãi, Q1, TP.HCM'
        WHEN 1 THEN N'Hà Nội Film Lab, 45 Hoàng Hoa Thám, Ba Đình, Hà Nội'
        ELSE N'Đà Nẵng Art Hub, 88 Bạch Đằng, Hải Châu, Đà Nẵng'
    END,
    350000.00 + (n % 6) * 100000.00,
    CASE 
        WHEN n <= 25 THEN N'Completed'
        WHEN n <= 45 THEN N'Upcoming'
        ELSE N'Ongoing'
    END,
    DATEADD(DAY, -15, DATEADD(DAY, (n * 3), '2026-08-15 09:00:00'))
FROM Numbers;
GO

-- ============================================================================
-- 14. SEED BẢNG PHOTO (Mục tiêu: 20,000 bản ghi)
-- Ảnh của người dùng đăng tải
-- ============================================================================
PRINT N'>> Seeding PHOTO (20,000 records)...';

;WITH Numbers(n) AS (
    SELECT TOP (20000) ROW_NUMBER() OVER (ORDER BY (SELECT NULL))
    FROM sys.all_objects a CROSS JOIN sys.all_objects b
)
INSERT INTO dbo.PHOTO (
    user_id, title, file_url, description, created_at, updated_at
)
SELECT 
    1 + ((n - 1) % 10000),
    CASE (n % 6)
        WHEN 0 THEN N'Bình minh trên cầu Long Biên (Film Tri-X 400) #' + CAST(n AS NVARCHAR(10))
        WHEN 1 THEN N'Chân dung phố cổ Hội An (Kodak Portra 400) #' + CAST(n AS NVARCHAR(10))
        WHEN 2 THEN N'Góc phố Sài Gòn chiều mưa (Fujicolor C200) #' + CAST(n AS NVARCHAR(10))
        WHEN 3 THEN N'Nét tĩnh lặng trong buồng tối (Ilford HP5 Plus) #' + CAST(n AS NVARCHAR(10))
        WHEN 4 THEN N'Kiến trúc cổ điển Hà Nội (Cinestill 800T) #' + CAST(n AS NVARCHAR(10))
        ELSE N'Khoảnh khắc đời thường Analog #' + CAST(n AS NVARCHAR(10))
    END,
    N'https://cdn.filmphoto.vn/gallery/2026/photo_' + RIGHT(N'0000' + CAST(n AS NVARCHAR(10)), 4) + N'.jpg',
    N'Tác phẩm chụp bằng máy ảnh film cơ khí, tự tráng rọi trong phòng tối tiêu chuẩn, quét phim độ phân giải cao.',
    DATEADD(DAY, -(250 - (n % 250)), '2026-08-25 15:30:00'),
    DATEADD(DAY, -(250 - (n % 250)), '2026-08-25 15:30:00')
FROM Numbers;
GO

-- ============================================================================
-- 15. SEED BẢNG COMPLAINT (Mục tiêu: 1,000 bản ghi)
-- Khiếu nại và xử lý khiếu nại
-- ============================================================================
PRINT N'>> Seeding COMPLAINT (1,000 records)...';

;WITH Numbers(n) AS (
    SELECT TOP (1000) ROW_NUMBER() OVER (ORDER BY (SELECT NULL))
    FROM sys.all_objects a CROSS JOIN sys.all_objects b
)
INSERT INTO dbo.COMPLAINT (
    user_id, subject, description, status, created_at, resolved_at, resolution
)
SELECT 
    3001 + ((n - 1) % 7000),
    CASE (n % 4)
        WHEN 0 THEN N'Hóa chất tráng phim bị yếu hoạt tính #' + CAST(n AS NVARCHAR(10))
        WHEN 1 THEN N'Thiết bị máy rọi bị lỏng ốc chỉnh nét #' + CAST(n AS NVARCHAR(10))
        WHEN 2 THEN N'Phòng studio bị trùng lịch đặt trước 15 phút #' + CAST(n AS NVARCHAR(10))
        ELSE N'Thắc mắc về đối soát giao dịch thanh toán #' + CAST(n AS NVARCHAR(10))
    END,
    N'Người dùng ghi nhận sự cố trong quá trình sử dụng không gian/thiết bị và đề nghị ban quản trị cùng nhà cung cấp kiểm tra xử lý.',
    CASE 
        WHEN n <= 35 THEN N'Resolved'
        WHEN n <= 45 THEN N'In_Investigation'
        ELSE N'Open'
    END,
    DATEADD(DAY, -(60 - n), '2026-08-10 11:00:00'),
    CASE 
        WHEN n <= 35 THEN DATEADD(DAY, 1, DATEADD(DAY, -(60 - n), '2026-08-10 11:00:00'))
        ELSE NULL 
    END,
    CASE 
        WHEN n <= 35 THEN N'Đã hoàn tiền 100% hoặc đổi buổi bù miễn phí cho khách hàng, đồng thời bảo trì thay thế hóa chất mới.'
        ELSE NULL 
    END
FROM Numbers;
GO

-- ============================================================================
-- 16. SEED BẢNG PACKAGE_SPACE (Mục tiêu: 6,000 bản ghi)
-- 3,000 packages x 2 spaces mỗi package = 6,000 bản ghi
-- ============================================================================
PRINT N'>> Seeding PACKAGE_SPACE (6,000 records)...';

;WITH PkgSpace(package_id, space_id) AS (
    -- Hai space thuộc cùng provider với package
    SELECT package_id, provider_id FROM dbo.SERVICE_PACKAGE
    UNION ALL
    SELECT package_id, provider_id + 1000 FROM dbo.SERVICE_PACKAGE
)
INSERT INTO dbo.PACKAGE_SPACE (package_id, space_id)
SELECT package_id, space_id FROM PkgSpace;
GO

-- ============================================================================
-- 17. SEED BẢNG PACKAGE_RESOURCE (Mục tiêu: 15,000 bản ghi)
-- 3,000 packages x 5 resources mỗi package = 15,000 bản ghi
-- ============================================================================
PRINT N'>> Seeding PACKAGE_RESOURCE (15,000 records)...';

;WITH PkgRes(package_id, resource_id, quantity) AS (
    SELECT package_id, provider_id, 1 FROM dbo.SERVICE_PACKAGE
    UNION ALL
    SELECT package_id, provider_id + 1000, 1 FROM dbo.SERVICE_PACKAGE
    UNION ALL
    SELECT package_id, provider_id + 2000, 2 FROM dbo.SERVICE_PACKAGE
    UNION ALL
    SELECT package_id, provider_id + 3000, 1 FROM dbo.SERVICE_PACKAGE
    UNION ALL
    SELECT package_id, provider_id + 4000, 1 FROM dbo.SERVICE_PACKAGE
)
INSERT INTO dbo.PACKAGE_RESOURCE (package_id, resource_id, quantity)
SELECT package_id, resource_id, quantity FROM PkgRes;
GO

-- ============================================================================
-- 18. SEED BẢNG RESERVATION_SPACE (Mục tiêu: 25,000 bản ghi)
-- 16,000 reservations: 9,000 reservation đầu x 2 spaces + 7,000 reservation sau x 1 space
-- ============================================================================
PRINT N'>> Seeding RESERVATION_SPACE (25,000 records)...';
INSERT INTO dbo.RESERVATION_SPACE (reservation_id, space_id)
SELECT r.reservation_id,
      CASE WHEN r.package_id IS NOT NULL
            THEN p.provider_id
            ELSE 1 + ((r.reservation_id - 1) % 1000)
      END
FROM dbo.RESERVATION r
LEFT JOIN dbo.SERVICE_PACKAGE p ON p.package_id = r.package_id
UNION ALL
SELECT r.reservation_id,
      CASE WHEN r.package_id IS NOT NULL
            THEN p.provider_id + 1000
            ELSE 1001 + ((r.reservation_id - 1) % 1000)
      END
FROM dbo.RESERVATION r
LEFT JOIN dbo.SERVICE_PACKAGE p ON p.package_id = r.package_id
WHERE r.reservation_id <= 9000;
GO

-- ============================================================================
-- 19. SEED BẢNG RESERVATION_RESOURCE (Mục tiêu: 30,000 bản ghi)
-- 16,000 reservations: 14,000 reservation đầu x 2 resources + 2,000 reservation sau x 1 resource
-- ============================================================================
PRINT N'>> Seeding RESERVATION_RESOURCE (30,000 records)...';

;WITH ResResource(reservation_id, resource_id, quantity) AS (
    SELECT r.reservation_id,
           CASE WHEN r.package_id IS NOT NULL
                    THEN p.provider_id
                    ELSE 1 + ((r.reservation_id - 1) % 1000)
           END,
           1
    FROM dbo.RESERVATION r
    LEFT JOIN dbo.SERVICE_PACKAGE p ON p.package_id = r.package_id
    UNION ALL
    SELECT r.reservation_id,
           CASE WHEN r.package_id IS NOT NULL
                    THEN p.provider_id + 1000
                    ELSE 1001 + ((r.reservation_id - 1) % 1000)
           END,
           1 + (r.reservation_id % 2)
    FROM dbo.RESERVATION r
    LEFT JOIN dbo.SERVICE_PACKAGE p ON p.package_id = r.package_id
    WHERE r.reservation_id <= 14000
)
INSERT INTO dbo.RESERVATION_RESOURCE (reservation_id, resource_id, quantity)
SELECT reservation_id, resource_id, quantity FROM ResResource;
GO

-- ============================================================================
-- 20. SEED BẢNG SESSION_RESOURCE (Mục tiêu: 20,000 bản ghi)
-- 15,000 sessions: 5,000 session đầu x 2 resources + 10,000 session sau x 1 resource = 20,000 bản ghi
-- ============================================================================
PRINT N'>> Seeding SESSION_RESOURCE (20,000 records)...';

;WITH SessResource(session_id, resource_id, quantity) AS (
    -- Resource thuộc cùng provider với package của reservation (nếu có)
    SELECT s.session_id,
           CASE WHEN r.package_id IS NOT NULL
                THEN p.provider_id
                ELSE 1 + ((r.reservation_id - 1) % 1000)
           END,
           1
    FROM dbo.SERVICE_SESSION s
    INNER JOIN dbo.RESERVATION r ON r.reservation_id = s.reservation_id
    LEFT JOIN dbo.SERVICE_PACKAGE p ON p.package_id = r.package_id
    UNION ALL
    -- 5,000 session đầu có thêm resource 2 -> Tổng 20,000
    SELECT s.session_id,
           CASE WHEN r.package_id IS NOT NULL
                THEN p.provider_id + 1000
                ELSE 1001 + ((r.reservation_id - 1) % 1000)
           END,
           1
    FROM dbo.SERVICE_SESSION s
    INNER JOIN dbo.RESERVATION r ON r.reservation_id = s.reservation_id
    LEFT JOIN dbo.SERVICE_PACKAGE p ON p.package_id = r.package_id
    WHERE s.session_id <= 5000
)
INSERT INTO dbo.SESSION_RESOURCE (session_id, resource_id, quantity)
SELECT session_id, resource_id, quantity FROM SessResource;
GO

-- ============================================================================
-- 21. SEED BẢNG WORKSHOP_REGISTRATION (Mục tiêu: 5,000 bản ghi)
-- 500 workshops x 10 users = 5,000 bản ghi
-- ============================================================================
PRINT N'>> Seeding WORKSHOP_REGISTRATION (5,000 records)...';

;WITH Reg(user_id, workshop_id, registered_at) AS (
    SELECT 3001 + ((w.workshop_id * 10 + u.n) % 7000), w.workshop_id, DATEADD(DAY, -5, w.created_at)
    FROM dbo.WORKSHOP w
    CROSS JOIN (
        SELECT 0 AS n UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL
        SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9
    ) u
)
INSERT INTO dbo.WORKSHOP_REGISTRATION (user_id, workshop_id, registered_at)
SELECT user_id, workshop_id, registered_at FROM Reg;
GO

-- Bật lại kiểm tra ràng buộc toàn vẹn
EXEC sp_MSforeachtable "ALTER TABLE ? WITH CHECK CHECK CONSTRAINT ALL";
GO

-- ============================================================================
-- KIỂM TRA VÀ XÁC NHẬN SỐ LƯỢNG BẢN GHI (VERIFICATION)
-- ============================================================================
PRINT N'============================================================================';
PRINT N'                    BẢNG TỔNG HỢP KIỂM TRA SỐ LƯỢNG BẢN GHI                 ';
PRINT N'============================================================================';

SELECT 
    t.name AS [Tên bảng / Quan hệ],
    p.rows AS [Số bản ghi thực tế],
    CASE t.name
        WHEN 'USER' THEN 10000
        WHEN 'SERVICE_PROVIDER' THEN 1000
        WHEN 'CREATIVE_SPACE' THEN 3000
        WHEN 'RESOURCE' THEN 15000
        WHEN 'MAINTENANCE' THEN 18000
        WHEN 'SERVICE_PACKAGE' THEN 3000
        WHEN 'PROMOTION' THEN 1000
        WHEN 'RESERVATION' THEN 16000
        WHEN 'PAYMENT' THEN 10000
        WHEN 'SERVICE_SESSION' THEN 15000
        WHEN 'REVIEW' THEN 10000
        WHEN 'COMMUNITY_CONTENT' THEN 5000
        WHEN 'WORKSHOP' THEN 500
        WHEN 'PHOTO' THEN 20000
        WHEN 'COMPLAINT' THEN 1000
        WHEN 'PACKAGE_SPACE' THEN 6000
        WHEN 'PACKAGE_RESOURCE' THEN 15000
        WHEN 'RESERVATION_SPACE' THEN 25000
        WHEN 'RESERVATION_RESOURCE' THEN 30000
        WHEN 'SESSION_RESOURCE' THEN 20000
        WHEN 'WORKSHOP_REGISTRATION' THEN 5000
    END AS [Mục tiêu plan_db.md],
    CASE 
        WHEN p.rows = CASE t.name
            WHEN 'USER' THEN 10000
            WHEN 'SERVICE_PROVIDER' THEN 1000
            WHEN 'CREATIVE_SPACE' THEN 3000
            WHEN 'RESOURCE' THEN 15000
            WHEN 'MAINTENANCE' THEN 18000
            WHEN 'SERVICE_PACKAGE' THEN 3000
            WHEN 'PROMOTION' THEN 1000
            WHEN 'RESERVATION' THEN 16000
            WHEN 'PAYMENT' THEN 10000
            WHEN 'SERVICE_SESSION' THEN 15000
            WHEN 'REVIEW' THEN 10000
            WHEN 'COMMUNITY_CONTENT' THEN 5000
            WHEN 'WORKSHOP' THEN 500
            WHEN 'PHOTO' THEN 20000
            WHEN 'COMPLAINT' THEN 1000
            WHEN 'PACKAGE_SPACE' THEN 6000
            WHEN 'PACKAGE_RESOURCE' THEN 15000
            WHEN 'RESERVATION_SPACE' THEN 25000
            WHEN 'RESERVATION_RESOURCE' THEN 30000
            WHEN 'SESSION_RESOURCE' THEN 20000
            WHEN 'WORKSHOP_REGISTRATION' THEN 5000
        END THEN N'✓ Khớp 100%'
        ELSE N'✗ Chưa khớp'
    END AS [Trạng thái đối chiếu]
FROM sys.tables t
INNER JOIN sys.partitions p ON t.object_id = p.object_id AND p.index_id IN (0, 1)
ORDER BY [Mục tiêu plan_db.md] ASC, t.name ASC;
GO

-- Không cho phép hoàn tất im lặng nếu số lượng hoặc quan hệ nghiệp vụ bị lệch.
DECLARE @ExpectedCounts TABLE (
    table_name SYSNAME PRIMARY KEY,
    expected_count INT NOT NULL
);

INSERT INTO @ExpectedCounts (table_name, expected_count)
VALUES
    (N'USER', 10000),
    (N'SERVICE_PROVIDER', 1000),
    (N'CREATIVE_SPACE', 3000),
    (N'RESOURCE', 15000),
    (N'MAINTENANCE', 18000),
    (N'SERVICE_PACKAGE', 3000),
    (N'PROMOTION', 1000),
    (N'RESERVATION', 16000),
    (N'PAYMENT', 10000),
    (N'SERVICE_SESSION', 15000),
    (N'REVIEW', 10000),
    (N'COMMUNITY_CONTENT', 5000),
    (N'WORKSHOP', 500),
    (N'PHOTO', 20000),
    (N'COMPLAINT', 1000),
    (N'PACKAGE_SPACE', 6000),
    (N'PACKAGE_RESOURCE', 15000),
    (N'RESERVATION_SPACE', 25000),
    (N'RESERVATION_RESOURCE', 30000),
    (N'SESSION_RESOURCE', 20000),
    (N'WORKSHOP_REGISTRATION', 5000);

IF EXISTS (
    SELECT 1
    FROM @ExpectedCounts e
    LEFT JOIN (
        SELECT t.name AS table_name, p.rows AS actual_count
        FROM sys.tables t
        INNER JOIN sys.partitions p ON t.object_id = p.object_id AND p.index_id IN (0, 1)
    ) a ON a.table_name = e.table_name
    WHERE ISNULL(a.actual_count, -1) <> e.expected_count
)
BEGIN
    THROW 51000, N'Seed verification failed: one or more table counts do not match plan_db.md.', 1;
END;

IF EXISTS (
    SELECT 1
    FROM dbo.REVIEW r
    INNER JOIN dbo.RESERVATION res ON res.reservation_id = r.reservation_id
    WHERE r.user_id <> res.user_id
)
BEGIN
    THROW 51001, N'Seed verification failed: review users do not match reservation users.', 1;
END;

IF EXISTS (
    SELECT 1
    FROM dbo.SERVICE_SESSION s
    WHERE s.check_out IS NOT NULL
      AND s.actual_usage_duration <> DATEDIFF(MINUTE, s.check_in, s.check_out)
)
BEGIN
    THROW 51002, N'Seed verification failed: service session durations are inconsistent.', 1;
END;

-- Bật lại các Trigger
EXEC sp_MSforeachtable "ALTER TABLE ? ENABLE TRIGGER ALL";

PRINT N'>> Data seeding and verification completed successfully!';
GO
