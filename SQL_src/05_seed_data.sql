-- ============================================================================
-- SCRIPT 05: SEED DATA
-- Project: Platform Connecting Film Photography Community with Darkroom & Studio Services
-- Exactly matching the target record count in plan_db.md
-- ============================================================================

USE FilmPhotographyDB;
GO

SET NOCOUNT ON;

PRINT N'>> Starting data seeding process...';

-- Tắt kiểm tra ràng buộc tạm thời trong quá trình nạp để tối ưu hiệu năng
EXEC sp_MSforeachtable "ALTER TABLE ? NOCHECK CONSTRAINT ALL";
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
DBCC CHECKIDENT ('dbo.USER', RESEED, 0);
DBCC CHECKIDENT ('dbo.SERVICE_PROVIDER', RESEED, 0);
DBCC CHECKIDENT ('dbo.CREATIVE_SPACE', RESEED, 0);
DBCC CHECKIDENT ('dbo.RESOURCE', RESEED, 0);
DBCC CHECKIDENT ('dbo.MAINTENANCE', RESEED, 0);
DBCC CHECKIDENT ('dbo.SERVICE_PACKAGE', RESEED, 0);
DBCC CHECKIDENT ('dbo.PROMOTION', RESEED, 0);
DBCC CHECKIDENT ('dbo.RESERVATION', RESEED, 0);
DBCC CHECKIDENT ('dbo.PAYMENT', RESEED, 0);
DBCC CHECKIDENT ('dbo.SERVICE_SESSION', RESEED, 0);
DBCC CHECKIDENT ('dbo.REVIEW', RESEED, 0);
DBCC CHECKIDENT ('dbo.COMMUNITY_CONTENT', RESEED, 0);
DBCC CHECKIDENT ('dbo.WORKSHOP', RESEED, 0);
DBCC CHECKIDENT ('dbo.PHOTO', RESEED, 0);
DBCC CHECKIDENT ('dbo.COMPLAINT', RESEED, 0);
GO

-- ============================================================================
-- 1. SEED BẢNG USER (Mục tiêu: 100 bản ghi)
-- Gồm: Photographer (70), Service Provider (15), Expert (10), Administrator (5)
-- ============================================================================
PRINT N'>> Seeding [USER] (100 records)...';

;WITH N10(n) AS (
    SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL 
    SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9 UNION ALL SELECT 10
),
Numbers(n) AS (
    SELECT ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) FROM N10 a CROSS JOIN N10 b
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
        WHEN id <= 5 THEN N'Administrator'
        WHEN id <= 15 THEN N'Expert'
        WHEN id <= 30 THEN N'Service Provider'
        ELSE N'Photographer'
    END,
    CASE WHEN id % 25 = 0 THEN N'Inactive' ELSE N'Active' END,
    DATEADD(DAY, -(100 - id), '2026-08-01 08:00:00')
FROM Names;
GO

-- ============================================================================
-- 2. SEED BẢNG SERVICE_PROVIDER (Mục tiêu: 20 bản ghi)
-- ============================================================================
PRINT N'>> Seeding SERVICE_PROVIDER (20 records)...';

;WITH Numbers(n) AS (
    SELECT TOP (20) ROW_NUMBER() OVER (ORDER BY (SELECT NULL))
    FROM sys.all_objects
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
    CASE WHEN n = 20 THEN N'Pending_Approval' ELSE N'Active' END,
    DATEADD(DAY, -(50 - n), '2026-08-05 09:00:00')
FROM Numbers;
GO

-- ============================================================================
-- 3. SEED BẢNG CREATIVE_SPACE (Mục tiêu: 60 bản ghi)
-- Trung bình 3 không gian / provider
-- ============================================================================
PRINT N'>> Seeding CREATIVE_SPACE (60 records)...';

;WITH Numbers(n) AS (
    SELECT TOP (60) ROW_NUMBER() OVER (ORDER BY (SELECT NULL))
    FROM sys.all_objects
)
INSERT INTO dbo.CREATIVE_SPACE (
    provider_id, name, space_type, description, area, capacity,
    artistic_style, lighting_condition, ventilation, acoustic_characteristics,
    operating_hours, usage_policy, pricing, status
)
SELECT 
    ((n - 1) % 20) + 1, -- Phân bổ đều cho 20 provider (mỗi provider 3 không gian)
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
-- 4. SEED BẢNG RESOURCE (Mục tiêu: 150 bản ghi)
-- Thiết bị, vật tư, dụng cụ phân bổ cho 20 provider
-- ============================================================================
PRINT N'>> Seeding RESOURCE (150 records)...';

;WITH Numbers(n) AS (
    SELECT TOP (150) ROW_NUMBER() OVER (ORDER BY (SELECT NULL))
    FROM sys.all_objects
)
INSERT INTO dbo.RESOURCE (
    provider_id, name, resource_type, description, quantity,
    condition, rental_price, compatibility_information, status
)
SELECT 
    ((n - 1) % 20) + 1,
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
    CASE WHEN n % 20 = 0 THEN N'Maintenance' ELSE N'Available' END
FROM Numbers;
GO

-- ============================================================================
-- 5. SEED BẢNG MAINTENANCE (Mục tiêu: 100 bản ghi)
-- Lịch sử bảo trì tài nguyên
-- ============================================================================
PRINT N'>> Seeding MAINTENANCE (100 records)...';

;WITH Numbers(n) AS (
    SELECT TOP (100) ROW_NUMBER() OVER (ORDER BY (SELECT NULL))
    FROM sys.all_objects
)
INSERT INTO dbo.MAINTENANCE (
    resource_id, maintenance_type, description, scheduled_at,
    completed_at, cost, status
)
SELECT 
    ((n - 1) % 150) + 1,
    CASE (n % 5)
        WHEN 0 THEN N'Routine'
        WHEN 1 THEN N'Repair'
        WHEN 2 THEN N'Calibration'
        WHEN 3 THEN N'Cleaning'
        ELSE N'Inspection'
    END,
    N'Bảo trì định kỳ: lau thấu kính, bôi trơn bánh răng, kiểm tra tốc độ màn trập và độ chính xác ánh sáng đèn.',
    DATEADD(DAY, -(120 - n), '2026-08-10 10:00:00'),
    CASE 
        WHEN n <= 80 THEN DATEADD(HOUR, 4 + (n % 8), DATEADD(DAY, -(120 - n), '2026-08-10 10:00:00'))
        ELSE NULL 
    END,
    150000.00 + (n % 10) * 50000.00,
    CASE 
        WHEN n <= 80 THEN N'Completed'
        WHEN n <= 95 THEN N'In_Progress'
        ELSE N'Scheduled'
    END
FROM Numbers;
GO

-- ============================================================================
-- 6. SEED BẢNG SERVICE_PACKAGE (Mục tiêu: 60 bản ghi)
-- Khoảng 3 package / provider
-- ============================================================================
PRINT N'>> Seeding SERVICE_PACKAGE (60 records)...';

;WITH Numbers(n) AS (
    SELECT TOP (60) ROW_NUMBER() OVER (ORDER BY (SELECT NULL))
    FROM sys.all_objects
)
INSERT INTO dbo.SERVICE_PACKAGE (
    provider_id, name, description, price, duration, status, created_at
)
SELECT 
    ((n - 1) % 20) + 1,
    CASE (n % 4)
        WHEN 0 THEN N'Gói Tráng Rọi Phòng Tối Tiêu Chuẩn ' + CAST(n AS NVARCHAR(10))
        WHEN 1 THEN N'Gói Studio Chụp Chân Dung Analog ' + CAST(n AS NVARCHAR(10))
        WHEN 2 THEN N'Gói Workshop & Trải Nghiệm Film Master ' + CAST(n AS NVARCHAR(10))
        ELSE N'Gói Thuê Không Gian Tự Do Trọn Gói ' + CAST(n AS NVARCHAR(10))
    END,
    N'Bao gồm quyền sử dụng không gian sáng tạo, thiết bị rọi ảnh chuyên dụng, hóa chất tráng tiêu chuẩn và kỹ thuật viên hỗ trợ.',
    250000.00 + (n % 10) * 50000.00,
    2 + (n % 4), -- 2 đến 5 giờ
    CASE WHEN n = 60 THEN N'Inactive' ELSE N'Active' END,
    DATEADD(DAY, -(60 - n), '2026-08-01 08:00:00')
FROM Numbers;
GO

-- ============================================================================
-- 7. SEED BẢNG PROMOTION (Mục tiêu: 40 bản ghi)
-- Khuyến mãi của provider
-- ============================================================================
PRINT N'>> Seeding PROMOTION (40 records)...';

;WITH Numbers(n) AS (
    SELECT TOP (40) ROW_NUMBER() OVER (ORDER BY (SELECT NULL))
    FROM sys.all_objects
)
INSERT INTO dbo.PROMOTION (
    provider_id, name, description, discount_type, discount_value,
    start_at, end_at, status
)
SELECT 
    ((n - 1) % 20) + 1,
    CASE (n % 4)
        WHEN 0 THEN N'Ưu Đãi Mùa Hè Film Lovers ' + CAST(n AS NVARCHAR(10))
        WHEN 1 THEN N'Tri Ân Thành Viên Darkroom ' + CAST(n AS NVARCHAR(10))
        WHEN 2 THEN N'Khuyến Mãi Cuối Tuần Studio ' + CAST(n AS NVARCHAR(10))
        ELSE N'Chào Đón Nhiếp Ảnh Gia Mới ' + CAST(n AS NVARCHAR(10))
    END,
    N'Giảm giá trực tiếp khi đặt phòng tối hoặc gói studio trọn gói qua hệ thống trực tuyến.',
    CASE WHEN n % 2 = 0 THEN N'Percentage' ELSE N'Fixed_Amount' END,
    CASE WHEN n % 2 = 0 THEN 10.00 + (n % 4) * 5.00 ELSE 50000.00 + (n % 5) * 20000.00 END,
    DATEADD(DAY, -(30 - n), '2026-08-01 00:00:00'),
    DATEADD(DAY, 60 + n, '2026-08-01 23:59:59'),
    CASE WHEN n % 10 = 0 THEN N'Expired' ELSE N'Active' END
FROM Numbers;
GO

-- ============================================================================
-- 8. SEED BẢNG RESERVATION (Mục tiêu: 500 bản ghi)
-- ============================================================================
PRINT N'>> Seeding RESERVATION (500 records)...';

;WITH Numbers(n) AS (
    SELECT TOP (500) ROW_NUMBER() OVER (ORDER BY (SELECT NULL))
    FROM sys.all_objects a CROSS JOIN sys.all_objects b
)
INSERT INTO dbo.RESERVATION (
    user_id, package_id, start_time, end_time, status, total_amount, created_at
)
SELECT 
    31 + ((n - 1) % 70), -- Người đặt là các Photographer (user_id từ 31 đến 100)
    CASE WHEN n % 5 = 0 THEN NULL ELSE ((n - 1) % 60) + 1 END,
    DATEADD(MINUTE, (n * 137) % 25000, '2026-08-01 08:00:00'),
    DATEADD(HOUR, 2 + (n % 4), DATEADD(MINUTE, (n * 137) % 25000, '2026-08-01 08:00:00')),
    CASE 
        WHEN n <= 400 THEN N'Completed'
        WHEN n <= 450 THEN N'Confirmed'
        WHEN n <= 480 THEN N'Pending'
        ELSE N'Cancelled'
    END,
    300000.00 + (n % 15) * 50000.00,
    DATEADD(DAY, -2, DATEADD(MINUTE, (n * 137) % 25000, '2026-08-01 08:00:00'))
FROM Numbers;
GO

-- ============================================================================
-- 9. SEED BẢNG PAYMENT (Mục tiêu: 450 bản ghi)
-- Quan hệ 1:1 với RESERVATION (Áp dụng cho 450 reservation đã thanh toán)
-- ============================================================================
PRINT N'>> Seeding PAYMENT (450 records)...';

;WITH Numbers(n) AS (
    SELECT TOP (450) ROW_NUMBER() OVER (ORDER BY (SELECT NULL))
    FROM sys.all_objects a CROSS JOIN sys.all_objects b
)
INSERT INTO dbo.PAYMENT (
    reservation_id, amount, payment_method, payment_status, transaction_code, paid_at
)
SELECT 
    n, -- Gán chính xác reservation_id từ 1 đến 450 (Đảm bảo UNIQUE 100%)
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
        WHEN n <= 420 THEN N'Success'
        WHEN n <= 440 THEN N'Pending'
        ELSE N'Refunded'
    END,
    N'TXN2026' + RIGHT(N'000000' + CAST(n AS NVARCHAR(10)), 6) + N'FP',
    DATEADD(MINUTE, 30, DATEADD(DAY, -2, DATEADD(MINUTE, (n * 137) % 25000, '2026-08-01 08:00:00')))
FROM Numbers;
GO

-- ============================================================================
-- 10. SEED BẢNG SERVICE_SESSION (Mục tiêu: 400 bản ghi)
-- Quan hệ 1:1 với RESERVATION (Áp dụng cho 400 reservation đã thực hiện)
-- ============================================================================
PRINT N'>> Seeding SERVICE_SESSION (400 records)...';

;WITH Numbers(n) AS (
    SELECT TOP (400) ROW_NUMBER() OVER (ORDER BY (SELECT NULL))
    FROM sys.all_objects a CROSS JOIN sys.all_objects b
)
INSERT INTO dbo.SERVICE_SESSION (
    reservation_id, check_in, check_out, actual_usage_duration, status
)
SELECT 
    n, -- Gán chính xác reservation_id từ 1 đến 400 (Đảm bảo UNIQUE 100%)
    DATEADD(MINUTE, (n * 137) % 25000, '2026-08-01 08:00:00'),
    DATEADD(MINUTE, 120 + (n % 6) * 30, DATEADD(MINUTE, (n * 137) % 25000, '2026-08-01 08:00:00')),
    120 + (n % 6) * 30, -- Tự động khớp hiệu số phút
    CASE 
        WHEN n <= 380 THEN N'Completed'
        WHEN n <= 395 THEN N'Active'
        ELSE N'Overtime'
    END
FROM Numbers;
GO

-- ============================================================================
-- 11. SEED BẢNG REVIEW (Mục tiêu: 300 bản ghi)
-- Quan hệ 1:1 với RESERVATION (300 review từ reservation 1 đến 300)
-- ============================================================================
PRINT N'>> Seeding REVIEW (300 records)...';

;WITH Numbers(n) AS (
    SELECT TOP (300) ROW_NUMBER() OVER (ORDER BY (SELECT NULL))
    FROM sys.all_objects a CROSS JOIN sys.all_objects b
)
INSERT INTO dbo.REVIEW (
    user_id, reservation_id, rating, comment, created_at
)
SELECT 
    31 + ((n - 1) % 70),
    n, -- Gán chính xác reservation_id từ 1 đến 300 (Đảm bảo UNIQUE 100%)
    4 + (n % 2), -- Đánh giá 4 hoặc 5 sao
    CASE (n % 5)
        WHEN 0 THEN N'Phòng tối rất sạch sẽ, máy rọi Beseler hoạt động chuẩn xác, safe-light an toàn!'
        WHEN 1 THEN N'Chất lượng studio analog tuyệt vời, ánh sáng tự nhiên đẹp, chủ studio nhiệt tình hỗ trợ.'
        WHEN 2 THEN N'Hóa chất tráng phim pha mới, tỉ lệ chuẩn xác, phim lên màu rất đẹp và trong trẻo.'
        WHEN 3 THEN N'Không gian rộng rãi, thoáng khí không bị nồng mùi hóa chất. Sẽ tiếp tục quay lại!'
        ELSE N'Trải nghiệm tuyệt vời cho người mới bắt đầu đam mê bộ môn phòng tối film photography.'
    END,
    DATEADD(HOUR, 2, DATEADD(MINUTE, 120 + (n % 6) * 30, DATEADD(MINUTE, (n * 137) % 25000, '2026-08-01 08:00:00')))
FROM Numbers;
GO

-- ============================================================================
-- 12. SEED BẢNG COMMUNITY_CONTENT (Mục tiêu: 300 bản ghi)
-- ============================================================================
PRINT N'>> Seeding COMMUNITY_CONTENT (300 records)...';

;WITH Numbers(n) AS (
    SELECT TOP (300) ROW_NUMBER() OVER (ORDER BY (SELECT NULL))
    FROM sys.all_objects a CROSS JOIN sys.all_objects b
)
INSERT INTO dbo.COMMUNITY_CONTENT (
    user_id, title, content, content_type, status, created_at, updated_at
)
SELECT 
    1 + ((n - 1) % 100),
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
-- 13. SEED BẢNG WORKSHOP (Mục tiêu: 50 bản ghi)
-- Tổ chức bởi các Expert / Provider (user_id từ 6 đến 15)
-- ============================================================================
PRINT N'>> Seeding WORKSHOP (50 records)...';

;WITH Numbers(n) AS (
    SELECT TOP (50) ROW_NUMBER() OVER (ORDER BY (SELECT NULL))
    FROM sys.all_objects
)
INSERT INTO dbo.WORKSHOP (
    organizer_id, title, description, topic, start_time, end_time,
    capacity, location, price, status, created_at
)
SELECT 
    6 + ((n - 1) % 10), -- Experts (user_id 6 đến 15)
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
-- 14. SEED BẢNG PHOTO (Mục tiêu: 500 bản ghi)
-- Ảnh của người dùng đăng tải
-- ============================================================================
PRINT N'>> Seeding PHOTO (500 records)...';

;WITH Numbers(n) AS (
    SELECT TOP (500) ROW_NUMBER() OVER (ORDER BY (SELECT NULL))
    FROM sys.all_objects a CROSS JOIN sys.all_objects b
)
INSERT INTO dbo.PHOTO (
    user_id, title, file_url, description, created_at, updated_at
)
SELECT 
    1 + ((n - 1) % 100),
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
-- 15. SEED BẢNG COMPLAINT (Mục tiêu: 50 bản ghi)
-- Khiếu nại và xử lý khiếu nại
-- ============================================================================
PRINT N'>> Seeding COMPLAINT (50 records)...';

;WITH Numbers(n) AS (
    SELECT TOP (50) ROW_NUMBER() OVER (ORDER BY (SELECT NULL))
    FROM sys.all_objects
)
INSERT INTO dbo.COMPLAINT (
    user_id, subject, description, status, created_at, resolved_at, resolution
)
SELECT 
    31 + ((n - 1) % 70),
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
-- 16. SEED BẢNG PACKAGE_SPACE (Mục tiêu: 120 bản ghi)
-- 60 packages x 2 spaces mỗi package = 120 bản ghi
-- ============================================================================
PRINT N'>> Seeding PACKAGE_SPACE (120 records)...';

;WITH PkgSpace(package_id, space_id) AS (
    -- Space thứ nhất của package
    SELECT package_id, ((package_id - 1) % 60) + 1 FROM dbo.SERVICE_PACKAGE
    UNION ALL
    -- Space thứ hai của package (đảm bảo khác space thứ nhất)
    SELECT package_id, (((package_id - 1) + 1) % 60) + 1 FROM dbo.SERVICE_PACKAGE
)
INSERT INTO dbo.PACKAGE_SPACE (package_id, space_id)
SELECT package_id, space_id FROM PkgSpace;
GO

-- ============================================================================
-- 17. SEED BẢNG PACKAGE_RESOURCE (Mục tiêu: 180 bản ghi)
-- 60 packages x 3 resources mỗi package = 180 bản ghi
-- ============================================================================
PRINT N'>> Seeding PACKAGE_RESOURCE (180 records)...';

;WITH PkgRes(package_id, resource_id, quantity) AS (
    SELECT package_id, ((package_id * 2 - 2) % 150) + 1, 1 FROM dbo.SERVICE_PACKAGE
    UNION ALL
    SELECT package_id, ((package_id * 2 - 1) % 150) + 1, 1 FROM dbo.SERVICE_PACKAGE
    UNION ALL
    SELECT package_id, ((package_id * 2) % 150) + 1, 2 FROM dbo.SERVICE_PACKAGE
)
INSERT INTO dbo.PACKAGE_RESOURCE (package_id, resource_id, quantity)
SELECT package_id, resource_id, quantity FROM PkgRes;
GO

-- ============================================================================
-- 18. SEED BẢNG RESERVATION_SPACE (Mục tiêu: 600 bản ghi)
-- 500 reservations: 100 reservation đầu x 2 spaces + 400 reservation sau x 1 space = 600 bản ghi
-- ============================================================================
PRINT N'>> Seeding RESERVATION_SPACE (600 records)...';

;WITH ResSpace(reservation_id, space_id) AS (
    -- Mỗi reservation trong 500 reservation có ít nhất 1 space = 500 bản ghi
    SELECT reservation_id, ((reservation_id - 1) % 60) + 1 FROM dbo.RESERVATION
    UNION ALL
    -- 100 reservation đầu tiên chọn thêm 1 space thứ hai = 100 bản ghi -> Tổng 600
    SELECT reservation_id, (((reservation_id - 1) + 5) % 60) + 1 FROM dbo.RESERVATION WHERE reservation_id <= 100
)
INSERT INTO dbo.RESERVATION_SPACE (reservation_id, space_id)
SELECT reservation_id, space_id FROM ResSpace;
GO

-- ============================================================================
-- 19. SEED BẢNG RESERVATION_RESOURCE (Mục tiêu: 800 bản ghi)
-- 500 reservations: 300 reservation đầu x 2 resources + 200 reservation sau x 1 resource = 800 bản ghi
-- ============================================================================
PRINT N'>> Seeding RESERVATION_RESOURCE (800 records)...';

;WITH ResResource(reservation_id, resource_id, quantity) AS (
    -- 500 reservation có resource 1
    SELECT reservation_id, ((reservation_id - 1) % 150) + 1, 1 FROM dbo.RESERVATION
    UNION ALL
    -- 300 reservation đầu tiên có thêm resource 2 -> Tổng 800 bản ghi
    SELECT reservation_id, (((reservation_id - 1) + 10) % 150) + 1, 1 + (reservation_id % 2) FROM dbo.RESERVATION WHERE reservation_id <= 300
)
INSERT INTO dbo.RESERVATION_RESOURCE (reservation_id, resource_id, quantity)
SELECT reservation_id, resource_id, quantity FROM ResResource;
GO

-- ============================================================================
-- 20. SEED BẢNG SESSION_RESOURCE (Mục tiêu: 600 bản ghi)
-- 400 sessions: 200 session đầu x 2 resources + 200 session sau x 1 resource = 600 bản ghi
-- ============================================================================
PRINT N'>> Seeding SESSION_RESOURCE (600 records)...';

;WITH SessResource(session_id, resource_id, quantity) AS (
    -- 400 session có resource 1
    SELECT session_id, ((session_id - 1) % 150) + 1, 1 FROM dbo.SERVICE_SESSION
    UNION ALL
    -- 200 session đầu có thêm resource 2 -> Tổng 600 bản ghi
    SELECT session_id, (((session_id - 1) + 20) % 150) + 1, 1 FROM dbo.SERVICE_SESSION WHERE session_id <= 200
)
INSERT INTO dbo.SESSION_RESOURCE (session_id, resource_id, quantity)
SELECT session_id, resource_id, quantity FROM SessResource;
GO

-- ============================================================================
-- 21. SEED BẢNG WORKSHOP_REGISTRATION (Mục tiêu: 300 bản ghi)
-- 50 workshops x 6 users = 300 bản ghi
-- ============================================================================
PRINT N'>> Seeding WORKSHOP_REGISTRATION (300 records)...';

;WITH Reg(user_id, workshop_id, registered_at) AS (
    SELECT 31 + ((w.workshop_id * 6 + u.n) % 70), w.workshop_id, DATEADD(DAY, -5, w.created_at)
    FROM dbo.WORKSHOP w
    CROSS JOIN (
        SELECT 0 AS n UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL 
        SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5
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
        WHEN 'USER' THEN 100
        WHEN 'SERVICE_PROVIDER' THEN 20
        WHEN 'CREATIVE_SPACE' THEN 60
        WHEN 'RESOURCE' THEN 150
        WHEN 'MAINTENANCE' THEN 100
        WHEN 'SERVICE_PACKAGE' THEN 60
        WHEN 'PROMOTION' THEN 40
        WHEN 'RESERVATION' THEN 500
        WHEN 'PAYMENT' THEN 450
        WHEN 'SERVICE_SESSION' THEN 400
        WHEN 'REVIEW' THEN 300
        WHEN 'COMMUNITY_CONTENT' THEN 300
        WHEN 'WORKSHOP' THEN 50
        WHEN 'PHOTO' THEN 500
        WHEN 'COMPLAINT' THEN 50
        WHEN 'PACKAGE_SPACE' THEN 120
        WHEN 'PACKAGE_RESOURCE' THEN 180
        WHEN 'RESERVATION_SPACE' THEN 600
        WHEN 'RESERVATION_RESOURCE' THEN 800
        WHEN 'SESSION_RESOURCE' THEN 600
        WHEN 'WORKSHOP_REGISTRATION' THEN 300
    END AS [Mục tiêu plan_db.md],
    CASE 
        WHEN p.rows = CASE t.name
            WHEN 'USER' THEN 100
            WHEN 'SERVICE_PROVIDER' THEN 20
            WHEN 'CREATIVE_SPACE' THEN 60
            WHEN 'RESOURCE' THEN 150
            WHEN 'MAINTENANCE' THEN 100
            WHEN 'SERVICE_PACKAGE' THEN 60
            WHEN 'PROMOTION' THEN 40
            WHEN 'RESERVATION' THEN 500
            WHEN 'PAYMENT' THEN 450
            WHEN 'SERVICE_SESSION' THEN 400
            WHEN 'REVIEW' THEN 300
            WHEN 'COMMUNITY_CONTENT' THEN 300
            WHEN 'WORKSHOP' THEN 50
            WHEN 'PHOTO' THEN 500
            WHEN 'COMPLAINT' THEN 50
            WHEN 'PACKAGE_SPACE' THEN 120
            WHEN 'PACKAGE_RESOURCE' THEN 180
            WHEN 'RESERVATION_SPACE' THEN 600
            WHEN 'RESERVATION_RESOURCE' THEN 800
            WHEN 'SESSION_RESOURCE' THEN 600
            WHEN 'WORKSHOP_REGISTRATION' THEN 300
        END THEN N'✓ Khớp 100%'
        ELSE N'✗ Chưa khớp'
    END AS [Trạng thái đối chiếu]
FROM sys.tables t
INNER JOIN sys.partitions p ON t.object_id = p.object_id AND p.index_id IN (0, 1)
ORDER BY [Mục tiêu plan_db.md] ASC, t.name ASC;
GO

PRINT N'>> Data seeding and verification completed successfully!';
GO
