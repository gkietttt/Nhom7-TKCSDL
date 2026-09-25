-- ============================================================================
-- TRUY VẤN & PHÂN TÍCH: 5 THỰC THỂ CHÍNH (BẢNG 1 - 5)
-- USER, SERVICE_PROVIDER, CREATIVE_SPACE, RESOURCE, MAINTENANCE
-- Người thực hiện: Hữu Hào - Nhóm 7 TKCSDL
-- CSDL: FilmPhotographyDB (SQL Server 2022, chạy bằng Docker, port 14333)
--
-- Ghi chú chung:
--   * Mỗi truy vấn gồm: MỤC ĐÍCH, CÂU LỆNH, PHÂN TÍCH.
--   * "Kết quả dự kiến" được tính từ công thức sinh dữ liệu trong 05_seed_data.sql
--     (ngày tham chiếu 25/09/2026). Khi chạy thật, đối chiếu với số liệu này.
--   * Tên index được nhắc tới đều lấy từ 03_create_constraints_and_indexes.sql.
-- ============================================================================

USE FilmPhotographyDB;
GO

-- ############################################################################
-- PHẦN 1: BẢNG [USER]
-- ############################################################################

-- ----------------------------------------------------------------------------
-- U1. Phân bố người dùng theo vai trò và trạng thái tài khoản
-- MỤC ĐÍCH: Administrator nắm cơ cấu người dùng của nền tảng.
-- ----------------------------------------------------------------------------
SELECT
    role,
    status,
    COUNT(*) AS so_nguoi_dung,
    CAST(100.0 * COUNT(*) / SUM(COUNT(*)) OVER () AS DECIMAL(5,2)) AS ty_le_phan_tram
FROM dbo.[USER]
GROUP BY role, status
ORDER BY role, status;
-- PHÂN TÍCH:
--   * Kết quả dự kiến: Photographer 6.720 Active / 280 Inactive; Service Provider
--     1.440 / 60; Expert 960 / 40; Administrator 480 / 20 (tổng 10.000).
--   * Photographer chiếm 70%, đúng với vai trò là nhóm người dùng chính (Chương 1).
--   * SUM(COUNT(*)) OVER () là hàm cửa sổ, tính tổng toàn bảng để ra tỷ lệ % mà
--     không cần truy vấn con.
--   * Truy vấn chỉ đọc 2 cột (role, status) nên SQL Server quét index
--     IX_USER_Role_Status thay vì quét cả bảng => ít trang dữ liệu phải đọc hơn.

-- ----------------------------------------------------------------------------
-- U2. Top 10 Photographer có tổng giá trị đặt chỗ đã hoàn thành cao nhất
-- MỤC ĐÍCH: Xác định khách hàng thân thiết để áp dụng Promotion.
-- ----------------------------------------------------------------------------
SELECT TOP (10)
    u.user_id,
    u.full_name,
    u.email,
    COUNT(r.reservation_id) AS so_lan_dat,
    SUM(r.total_amount)     AS tong_gia_tri
FROM dbo.[USER] u
INNER JOIN dbo.RESERVATION r ON r.user_id = u.user_id
WHERE u.role = N'Photographer'
  AND r.status = N'Completed'
GROUP BY u.user_id, u.full_name, u.email
ORDER BY tong_gia_tri DESC, so_lan_dat DESC;
-- PHÂN TÍCH:
--   * JOIN USER - RESERVATION theo quan hệ "Đặt" (1:N) ở Chương 2.
--   * WHERE lọc trước khi nhóm (chỉ lấy Reservation Completed), GROUP BY gom theo
--     từng người dùng, ORDER BY + TOP lấy 10 người cao nhất.
--   * 16.000 Reservation chia cho 7.000 Photographer => mỗi người khoảng 2-3 lần
--     đặt, nên chênh lệch giữa các khách hàng trong dữ liệu mẫu không lớn.
--   * Dùng total_amount của Reservation thay vì PAYMENT vì dữ liệu mẫu chỉ có
--     420 Payment ở trạng thái Success.

-- ----------------------------------------------------------------------------
-- U3. Kiểm tra quy tắc nghiệp vụ: Reservation chỉ do Photographer tạo
-- MỤC ĐÍCH: Đối chiếu quy tắc "Một Reservation được tạo bởi đúng một User có
--           vai trò Photographer" (Chương 1 - Quy tắc về đặt chỗ).
-- ----------------------------------------------------------------------------
SELECT
    u.role,
    COUNT(*) AS so_reservation_vi_pham
FROM dbo.RESERVATION r
INNER JOIN dbo.[USER] u ON u.user_id = r.user_id
WHERE u.role <> N'Photographer'
GROUP BY u.role;
-- PHÂN TÍCH:
--   * Kết quả dự kiến: 0 dòng (dữ liệu mẫu chỉ gán user_id 3001-10000, đều là
--     Photographer) => dữ liệu tuân thủ quy tắc.
--   * Lưu ý: CSDL hiện KHÔNG có trigger/CHECK nào chặn vi phạm này; quy tắc chỉ
--     đúng nhờ dữ liệu mẫu. Nếu muốn đảm bảo ở mức CSDL cần thêm trigger trên
--     RESERVATION tương tự trg_REVIEW_UserReservation.

-- ----------------------------------------------------------------------------
-- U4. Phát hiện dữ liệu bất thường: tài khoản có ngày tạo trong tương lai
--     hoặc được tạo sau lần đặt chỗ của chính nó
-- ----------------------------------------------------------------------------
SELECT
    N'Ngày tạo tài khoản sau thời điểm hiện tại' AS loai_bat_thuong,
    COUNT(*) AS so_ban_ghi,
    MIN(created_at) AS som_nhat,
    MAX(created_at) AS muon_nhat
FROM dbo.[USER]
WHERE created_at > SYSDATETIME()
UNION ALL
SELECT
    N'Tài khoản được tạo sau Reservation của chính nó',
    COUNT(DISTINCT u.user_id),
    MIN(u.created_at),
    MAX(u.created_at)
FROM dbo.[USER] u
INNER JOIN dbo.RESERVATION r ON r.user_id = u.user_id
WHERE r.created_at < u.created_at;
-- PHÂN TÍCH:
--   * Kết quả dự kiến: khoảng 9.846 tài khoản có created_at sau 25/09/2026
--     (muộn nhất năm 2053) => LỖI DỮ LIỆU MẪU.
--   * Nguyên nhân: công thức DATEADD(DAY, -(100 - id), '2026-08-01') cộng thêm
--     ngày khi id > 100, nên id càng lớn ngày tạo càng xa về tương lai.
--   * Hệ quả: Photographer "được tạo" sau cả Reservation của họ (tháng 8/2026),
--     trái logic nghiệp vụ. Đề xuất sửa seed (xem ghi chú cuối file).

-- ############################################################################
-- PHẦN 2: BẢNG SERVICE_PROVIDER
-- ############################################################################

-- ----------------------------------------------------------------------------
-- P1. Tổng quan tài nguyên của từng nhà cung cấp (tổng hợp trước rồi mới JOIN)
-- MỤC ĐÍCH: Service Provider / Administrator xem quy mô từng nhà cung cấp.
-- ----------------------------------------------------------------------------
WITH space_stats AS (
    SELECT provider_id,
           COUNT(*)      AS so_khong_gian,
           SUM(capacity) AS tong_suc_chua
    FROM dbo.CREATIVE_SPACE
    GROUP BY provider_id
),
resource_stats AS (
    SELECT provider_id,
           COUNT(*)      AS so_tai_nguyen,
           SUM(quantity) AS tong_so_luong
    FROM dbo.RESOURCE
    GROUP BY provider_id
)
SELECT TOP (20)
    p.provider_id,
    p.business_name,
    p.status,
    ISNULL(s.so_khong_gian, 0)  AS so_khong_gian,
    ISNULL(s.tong_suc_chua, 0)  AS tong_suc_chua,
    ISNULL(r.so_tai_nguyen, 0)  AS so_tai_nguyen,
    ISNULL(r.tong_so_luong, 0)  AS tong_so_luong_thiet_bi
FROM dbo.SERVICE_PROVIDER p
LEFT JOIN space_stats    s ON s.provider_id = p.provider_id
LEFT JOIN resource_stats r ON r.provider_id = p.provider_id
ORDER BY tong_so_luong_thiet_bi DESC, so_khong_gian DESC;
-- PHÂN TÍCH:
--   * Mỗi provider có đúng 3 Creative Space và 15 Resource (khớp plan_db.md).
--   * Kỹ thuật "tổng hợp trước, JOIN sau": mỗi CTE chỉ trả 1.000 dòng rồi mới
--     nối với SERVICE_PROVIDER.
--   * So sánh với view vw_ProviderOverview (nối cùng lúc SPACE, RESOURCE,
--     PACKAGE, PROMOTION rồi COUNT DISTINCT): mỗi provider sinh khoảng
--     3 x 15 x 3 x 1 = 135 dòng trung gian => khoảng 135.000 dòng cho 1.000
--     provider. Đây là minh họa cho phần "Ước lượng kích thước trung gian"
--     ở Chương 4: JOIN nhiều quan hệ 1:N cùng lúc làm kích thước trung gian
--     tăng theo cấp số nhân.

-- ----------------------------------------------------------------------------
-- P2. Phân bố nhà cung cấp theo thành phố
-- MỤC ĐÍCH: Biết khu vực nào tập trung nhiều phòng tối / studio.
-- ----------------------------------------------------------------------------
SELECT
    c.thanh_pho,
    COUNT(*) AS so_nha_cung_cap,
    SUM(CASE WHEN p.status = N'Active' THEN 1 ELSE 0 END) AS so_dang_hoat_dong
FROM dbo.SERVICE_PROVIDER p
CROSS APPLY (
    SELECT CASE
        WHEN p.address LIKE N'%Hồ Chí Minh%' THEN N'TP. Hồ Chí Minh'
        WHEN p.address LIKE N'%Hà Nội%'      THEN N'Hà Nội'
        WHEN p.address LIKE N'%Đà Nẵng%'     THEN N'Đà Nẵng'
        ELSE N'Khác'
    END AS thanh_pho
) c
GROUP BY c.thanh_pho
ORDER BY so_nha_cung_cap DESC;
-- PHÂN TÍCH:
--   * Kết quả dự kiến: TP. Hồ Chí Minh 500, Hà Nội 250, Đà Nẵng 250.
--   * Vì address đang lưu cả chuỗi (số nhà, đường, quận, thành phố) trong một
--     cột, phải dùng LIKE N'%...%'. Mẫu có ký tự % ở đầu không tận dụng được
--     index => SQL Server buộc quét toàn bộ bảng.
--   * Đây là bằng chứng thực tế cho ghi chú ở Chương 1 (Kiểm chứng mô hình) và
--     Chương 3 (1NF): nếu tách address thành street_number, street, district,
--     city thì chỉ cần "WHERE city = ..." và có thể đánh index trên city.

-- ----------------------------------------------------------------------------
-- P3. Nhà cung cấp chưa được phê duyệt nhưng đã có không gian đang mở
-- MỤC ĐÍCH: Kiểm tra quy tắc "Administrator phê duyệt Service Provider".
-- ----------------------------------------------------------------------------
SELECT
    p.provider_id,
    p.business_name,
    p.status AS trang_thai_nha_cung_cap,
    COUNT(cs.space_id) AS so_khong_gian_available
FROM dbo.SERVICE_PROVIDER p
INNER JOIN dbo.CREATIVE_SPACE cs ON cs.provider_id = p.provider_id
WHERE p.status = N'Pending_Approval'
  AND cs.status = N'Available'
GROUP BY p.provider_id, p.business_name, p.status
ORDER BY so_khong_gian_available DESC, p.provider_id;
-- PHÂN TÍCH:
--   * Kết quả dự kiến: 50 nhà cung cấp Pending_Approval, tổng 100 không gian
--     đang ở trạng thái Available.
--   * Người dùng không thấy các không gian này khi tìm kiếm vì
--     sp_SearchAvailableSpaces đã lọc sp.status = 'Active'. Tuy nhiên ở mức dữ
--     liệu vẫn cho phép, nên quy tắc phê duyệt hiện được kiểm soát ở tầng truy
--     vấn/ứng dụng chứ chưa phải ràng buộc CSDL.

-- ----------------------------------------------------------------------------
-- P4. Nhà cung cấp có tỷ lệ thiết bị cần bảo trì cao (từ 30% trở lên)
-- MỤC ĐÍCH: Administrator cảnh báo chất lượng tài nguyên của nhà cung cấp.
-- ----------------------------------------------------------------------------
SELECT
    p.provider_id,
    p.business_name,
    COUNT(*) AS tong_tai_nguyen,
    SUM(CASE WHEN r.condition IN (N'Need_Maintenance', N'Damaged') THEN 1 ELSE 0 END) AS so_can_bao_tri,
    CAST(100.0 * SUM(CASE WHEN r.condition IN (N'Need_Maintenance', N'Damaged') THEN 1 ELSE 0 END)
         / COUNT(*) AS DECIMAL(5,2)) AS ty_le_phan_tram
FROM dbo.SERVICE_PROVIDER p
INNER JOIN dbo.RESOURCE r ON r.provider_id = p.provider_id
GROUP BY p.provider_id, p.business_name
HAVING 100.0 * SUM(CASE WHEN r.condition IN (N'Need_Maintenance', N'Damaged') THEN 1 ELSE 0 END)
       / COUNT(*) >= 30
ORDER BY ty_le_phan_tram DESC, p.provider_id;
-- PHÂN TÍCH:
--   * Minh họa khác biệt WHERE và HAVING: điều kiện tỷ lệ chỉ tính được SAU khi
--     GROUP BY nên bắt buộc đặt ở HAVING.
--   * Kết quả dự kiến: 200 nhà cung cấp có tỷ lệ 100%, các nhà cung cấp còn lại
--     0%. Phân bố cực đoan này là do công thức seed (condition và provider_id
--     cùng tính theo n % 5), không phản ánh thực tế; nên ghi chú khi trình bày.

-- ############################################################################
-- PHẦN 3: BẢNG CREATIVE_SPACE
-- ############################################################################

-- ----------------------------------------------------------------------------
-- C1. Tìm phòng tối phù hợp nhu cầu (lọc đa thuộc tính)
-- MỤC ĐÍCH: Photographer tìm Darkroom còn hoạt động, chứa được từ 4 người,
--           giá không quá 200.000đ, của nhà cung cấp đang Active.
-- ----------------------------------------------------------------------------
SELECT TOP (20)
    cs.space_id,
    cs.name,
    cs.capacity,
    cs.pricing,
    cs.area,
    sp.business_name AS nha_cung_cap
FROM dbo.CREATIVE_SPACE cs
INNER JOIN dbo.SERVICE_PROVIDER sp ON sp.provider_id = cs.provider_id
WHERE cs.space_type = N'Darkroom'
  AND cs.status     = N'Available'
  AND cs.capacity  >= 4
  AND cs.pricing   <= 200000
  AND sp.status     = N'Active'
ORDER BY cs.pricing ASC, cs.capacity DESC;
-- PHÂN TÍCH:
--   * Kết quả dự kiến: 200 không gian thỏa điều kiện (TOP 20 hiển thị 20 dòng).
--   * Đây là truy vấn "Rất cao" trong Phân tích workload (Chương 4).
--   * Điều kiện (space_type, status) khớp đúng cột khóa của
--     IX_CREATIVE_SPACE_Type_Status => SQL Server dùng Index Seek.
--     name, pricing, capacity nằm trong INCLUDE nên không cần quay về bảng.
--   * Riêng cột area và provider_id KHÔNG có trong index => phát sinh Key Lookup
--     về Clustered Index. Nếu truy vấn này chạy rất thường xuyên, có thể thêm
--     area, provider_id vào INCLUDE để index "bao phủ" hoàn toàn.

-- ----------------------------------------------------------------------------
-- C2. Thống kê không gian theo loại
-- MỤC ĐÍCH: Nhà quản trị so sánh giá, diện tích, sức chứa giữa các loại.
-- ----------------------------------------------------------------------------
SELECT
    space_type,
    COUNT(*)                          AS so_luong,
    SUM(CASE WHEN status = N'Available' THEN 1 ELSE 0 END) AS dang_hoat_dong,
    CAST(AVG(pricing) AS DECIMAL(12,0)) AS gia_trung_binh,
    MIN(pricing)                      AS gia_thap_nhat,
    MAX(pricing)                      AS gia_cao_nhat,
    CAST(AVG(area) AS DECIMAL(6,1))   AS dien_tich_tb,
    CAST(AVG(1.0 * capacity) AS DECIMAL(4,1)) AS suc_chua_tb
FROM dbo.CREATIVE_SPACE
GROUP BY space_type
ORDER BY so_luong DESC;
-- PHÂN TÍCH:
--   * Kết quả dự kiến:
--       Studio   1.500 | giá TB 207.500 | 145.000 - 270.000 | 47,5 m2 | 4,5 người
--       Darkroom   750 | giá TB 170.000 | 120.000 - 220.000 | 45,0 m2 | 4,0 người
--       Hybrid     750 | giá TB 245.000 | 195.000 - 295.000 | 50,0 m2 | 5,0 người
--   * Darkroom rẻ nhất, Hybrid đắt nhất - hợp lý vì Hybrid kết hợp nhiều chức năng.
--   * CHECK constraint cho phép 4 loại (Darkroom, Studio, Hybrid, Exhibition) nhưng
--     dữ liệu mẫu không có Exhibition. Báo cáo Chương 1-2 chỉ nêu darkroom và
--     photography studio, nên cần bổ sung mô tả 2 loại Hybrid, Exhibition.
--   * AVG(1.0 * capacity): nhân 1.0 để tránh chia nguyên (capacity kiểu INT).

-- ----------------------------------------------------------------------------
-- C3. Mức độ sử dụng không gian: top 10 được đặt nhiều nhất và số không gian
--     chưa từng được đặt
-- ----------------------------------------------------------------------------
SELECT TOP (10)
    cs.space_id,
    cs.name,
    cs.space_type,
    COUNT(*) AS so_luot_dat,
    CAST(SUM(DATEDIFF(MINUTE, r.start_time, r.end_time)) / 60.0 AS DECIMAL(8,1)) AS tong_so_gio
FROM dbo.CREATIVE_SPACE cs
INNER JOIN dbo.RESERVATION_SPACE rs ON rs.space_id = cs.space_id
INNER JOIN dbo.RESERVATION r        ON r.reservation_id = rs.reservation_id
WHERE r.status = N'Completed'
GROUP BY cs.space_id, cs.name, cs.space_type
ORDER BY so_luot_dat DESC, tong_so_gio DESC;

SELECT COUNT(*) AS so_khong_gian_chua_tung_duoc_dat
FROM dbo.CREATIVE_SPACE cs
WHERE NOT EXISTS (
    SELECT 1 FROM dbo.RESERVATION_SPACE rs WHERE rs.space_id = cs.space_id
);
-- PHÂN TÍCH:
--   * JOIN qua bảng kết hợp RESERVATION_SPACE vì Creative Space - Reservation là
--     quan hệ N:N (Chương 2). Không có bảng trung gian thì không truy vấn được.
--   * Kết quả dự kiến truy vấn 2: 1.000 không gian (space_id 2001-3000) chưa
--     từng được đặt, vì dữ liệu mẫu chỉ phân bổ Reservation cho space 1-2000.
--   * NOT EXISTS dừng ngay khi tìm thấy 1 dòng khớp và dùng được
--     IX_RESERVATION_SPACE_SpaceId, hiệu quả hơn LEFT JOIN rồi lọc IS NULL
--     trên bảng 25.000 dòng.

-- ----------------------------------------------------------------------------
-- C4. Kiểm tra khả dụng theo khung giờ (nghiệp vụ trung tâm, Chương 1)
-- ----------------------------------------------------------------------------
-- Cách 1: dùng thủ tục có sẵn
EXEC dbo.sp_SearchAvailableSpaces
     @StartTime   = '2026-08-05 09:00:00',
     @EndTime     = '2026-08-05 12:00:00',
     @SpaceType   = N'Darkroom',
     @MinCapacity = 2;

-- Cách 2: viết trực tiếp với điều kiện chồng lấn rút gọn
DECLARE @Start DATETIME2(0) = '2026-08-05 09:00:00',
        @End   DATETIME2(0) = '2026-08-05 12:00:00';

SELECT cs.space_id, cs.name, cs.capacity, cs.pricing
FROM dbo.CREATIVE_SPACE cs
INNER JOIN dbo.SERVICE_PROVIDER sp ON sp.provider_id = cs.provider_id
WHERE cs.space_type = N'Darkroom'
  AND cs.status     = N'Available'
  AND sp.status     = N'Active'
  AND cs.capacity  >= 2
  AND NOT EXISTS (
      SELECT 1
      FROM dbo.RESERVATION_SPACE rs
      INNER JOIN dbo.RESERVATION r ON r.reservation_id = rs.reservation_id
      WHERE rs.space_id = cs.space_id
        AND r.status IN (N'Pending', N'Confirmed', N'In_Progress')
        AND r.start_time < @End      -- bắt đầu trước khi khung giờ mới kết thúc
        AND r.end_time   > @Start    -- và kết thúc sau khi khung giờ mới bắt đầu
  );
-- PHÂN TÍCH:
--   * Thể hiện ràng buộc "một Creative Space không thể xuất hiện trong hai
--     Reservation đang hoạt động cùng lúc" (Chương 1 - Ràng buộc khả dụng).
--   * Hai khoảng [A1, A2) và [B1, B2) chồng lấn khi và chỉ khi A1 < B2 VÀ A2 > B1.
--     Điều kiện 2 vế này tương đương 3 nhánh OR trong sp_SearchAvailableSpaces
--     nhưng ngắn gọn hơn và dễ tận dụng IX_RESERVATION_TimeRange.
--   * Hai cách cho cùng kết quả; khi trình bày nên chụp cả 2 để chứng minh.

-- ############################################################################
-- PHẦN 4: BẢNG RESOURCE
-- ############################################################################

-- ----------------------------------------------------------------------------
-- R1. Tìm thiết bị cho thuê: máy ảnh còn tốt, đang sẵn sàng, giá thấp nhất
-- ----------------------------------------------------------------------------
SELECT TOP (20)
    r.resource_id,
    r.name,
    r.condition,
    r.quantity,
    r.rental_price,
    sp.business_name AS nha_cung_cap
FROM dbo.RESOURCE r
INNER JOIN dbo.SERVICE_PROVIDER sp ON sp.provider_id = r.provider_id
WHERE r.resource_type = N'Camera'
  AND r.status        = N'Available'
  AND r.condition IN (N'New', N'Good')
  AND sp.status       = N'Active'
ORDER BY r.rental_price ASC, r.condition;
-- PHÂN TÍCH:
--   * (resource_type, status) khớp khóa của IX_RESOURCE_Type_Status; name,
--     rental_price, quantity, condition nằm trong INCLUDE => Index Seek và đọc
--     được gần như toàn bộ cột cần thiết từ index.
--   * Chỉ riêng provider_id (để JOIN) không có trong index nên cần Key Lookup;
--     với khoảng 1.667 máy ảnh thì chi phí này nhỏ.
--   * Loại bỏ thiết bị Need_Maintenance/Damaged để đảm bảo chất lượng dịch vụ.

-- ----------------------------------------------------------------------------
-- R2. Tồn kho theo loại tài nguyên và tình trạng
-- ----------------------------------------------------------------------------
SELECT
    resource_type,
    COUNT(*)      AS so_ma_tai_nguyen,
    SUM(quantity) AS tong_so_luong,
    SUM(CASE WHEN condition = N'New'              THEN 1 ELSE 0 END) AS moi,
    SUM(CASE WHEN condition = N'Good'             THEN 1 ELSE 0 END) AS tot,
    SUM(CASE WHEN condition = N'Fair'             THEN 1 ELSE 0 END) AS trung_binh,
    SUM(CASE WHEN condition = N'Need_Maintenance' THEN 1 ELSE 0 END) AS can_bao_tri,
    CAST(AVG(rental_price) AS DECIMAL(12,0)) AS gia_thue_tb
FROM dbo.RESOURCE
GROUP BY resource_type
ORDER BY tong_so_luong DESC;
-- PHÂN TÍCH:
--   * Kỹ thuật "tổng hợp có điều kiện" (SUM + CASE) biến dữ liệu dạng dòng thành
--     bảng chéo loại x tình trạng chỉ trong một lần quét.
--   * Chemicals và Photo Paper có tổng số lượng lớn nhất (vật tư tiêu hao,
--     mỗi mã 20-49 đơn vị) trong khi thiết bị như Camera chỉ 1-3 chiếc/mã, đúng
--     với mô tả "Resource gồm thiết bị và vật tư tiêu hao" ở Chương 1.

-- ----------------------------------------------------------------------------
-- R3. Thiết bị được thuê nhiều nhất và số thiết bị chưa từng được thuê
-- ----------------------------------------------------------------------------
SELECT TOP (10)
    res.resource_id,
    res.name,
    res.resource_type,
    COUNT(DISTINCT rr.reservation_id) AS so_lan_thue,
    SUM(rr.quantity)                  AS tong_so_luong_da_thue
FROM dbo.RESOURCE res
INNER JOIN dbo.RESERVATION_RESOURCE rr ON rr.resource_id = res.resource_id
INNER JOIN dbo.RESERVATION r           ON r.reservation_id = rr.reservation_id
WHERE r.status = N'Completed'
GROUP BY res.resource_id, res.name, res.resource_type
ORDER BY tong_so_luong_da_thue DESC, so_lan_thue DESC;

SELECT COUNT(*) AS so_tai_nguyen_chua_tung_duoc_thue
FROM dbo.RESOURCE res
WHERE NOT EXISTS (
    SELECT 1 FROM dbo.RESERVATION_RESOURCE rr WHERE rr.resource_id = res.resource_id
);
-- PHÂN TÍCH:
--   * Dùng bảng kết hợp RESERVATION_RESOURCE (có thuộc tính quantity) vì quan hệ
--     Reservation - Resource là N:N (Chương 2).
--   * Kết quả dự kiến truy vấn 2: 13.000 / 15.000 tài nguyên chưa từng được thuê
--     (dữ liệu mẫu chỉ phân bổ resource 1-2000). Nếu là dữ liệu thật, đây là
--     tín hiệu để nhà cung cấp gom thiết bị ít dùng vào Service Package.

-- ----------------------------------------------------------------------------
-- R4. Kiểm tra vi phạm quy tắc: tài nguyên đang bảo trì nhưng vẫn được phân bổ
--     cho Reservation đang hoạt động
-- ----------------------------------------------------------------------------
SELECT
    r.reservation_id,
    r.status        AS trang_thai_reservation,
    r.start_time,
    r.end_time,
    res.resource_id,
    res.name,
    res.status      AS trang_thai_tai_nguyen,
    m.maintenance_id,
    m.status        AS trang_thai_bao_tri,
    m.scheduled_at
FROM dbo.RESERVATION r
INNER JOIN dbo.RESERVATION_RESOURCE rr ON rr.reservation_id = r.reservation_id
INNER JOIN dbo.RESOURCE res            ON res.resource_id = rr.resource_id
LEFT JOIN dbo.MAINTENANCE m
       ON m.resource_id = res.resource_id
      AND m.status = N'In_Progress'
      AND m.scheduled_at < r.end_time
WHERE r.status IN (N'Pending', N'Confirmed', N'In_Progress')
  AND (res.status = N'Maintenance' OR m.maintenance_id IS NOT NULL)
ORDER BY r.start_time;
-- PHÂN TÍCH:
--   * Đối chiếu 2 quy tắc ở Chương 1: "Resource đang bảo trì không được phân bổ
--     cho Reservation" và "Ràng buộc Maintenance: không trùng thời gian phân bổ".
--   * Kết quả dự kiến: khoảng 494 dòng vi phạm (các Reservation Confirmed dùng
--     resource 1-500 đang có lịch bảo trì In_Progress).
--   * Kết luận: CSDL hiện chưa có trigger nào thực thi 2 quy tắc này nên dữ liệu
--     vi phạm vẫn được lưu. Đề xuất bổ sung trigger kiểm tra trên
--     RESERVATION_RESOURCE (khi INSERT/UPDATE) để chặn phân bổ tài nguyên đang
--     bảo trì.

-- ############################################################################
-- PHẦN 5: BẢNG MAINTENANCE
-- ############################################################################

-- ----------------------------------------------------------------------------
-- M1. Thống kê bảo trì theo loại: số lần, chi phí, thời gian xử lý trung bình
-- ----------------------------------------------------------------------------
SELECT
    maintenance_type,
    COUNT(*) AS so_lan,
    SUM(CASE WHEN status = N'Completed' THEN 1 ELSE 0 END) AS da_hoan_thanh,
    SUM(cost) AS tong_chi_phi,
    CAST(AVG(cost) AS DECIMAL(12,0)) AS chi_phi_tb,
    CAST(AVG(CASE WHEN completed_at IS NOT NULL
                  THEN DATEDIFF(MINUTE, scheduled_at, completed_at) / 60.0 END)
         AS DECIMAL(5,1)) AS so_gio_xu_ly_tb
FROM dbo.MAINTENANCE
GROUP BY maintenance_type
ORDER BY tong_chi_phi DESC;
-- PHÂN TÍCH:
--   * Kết quả dự kiến: mỗi loại 3.600 lần; chi phí TB: Inspection 475.000,
--     Cleaning 425.000, Calibration 375.000, Repair 325.000, Routine 275.000;
--     thời gian xử lý TB 7,5 giờ; tổng chi phí toàn bảng 6,75 tỷ đồng.
--   * AVG bỏ qua giá trị NULL, nên CASE trả NULL cho phiếu chưa hoàn thành để
--     chúng không làm sai thời gian trung bình.
--   * Trong dữ liệu mẫu, Inspection (kiểm tra) đắt hơn Repair (sửa chữa) là
--     điểm bất hợp lý của seed, cần lưu ý nếu bị hỏi.

-- ----------------------------------------------------------------------------
-- M2. Xu hướng chi phí bảo trì theo tháng
-- ----------------------------------------------------------------------------
SELECT
    YEAR(scheduled_at)  AS nam,
    MONTH(scheduled_at) AS thang,
    COUNT(*)            AS so_phieu_bao_tri,
    SUM(cost)           AS tong_chi_phi
FROM dbo.MAINTENANCE
GROUP BY YEAR(scheduled_at), MONTH(scheduled_at)
ORDER BY nam, thang;
-- PHÂN TÍCH:
--   * Dữ liệu mẫu trải từ 04/2026 đến 08/2026.
--   * GROUP BY theo biểu thức YEAR()/MONTH() nên không dùng được thứ tự của
--     IX_MAINTENANCE_Scheduled_Status để nhóm, nhưng index vẫn giúp nếu thêm
--     điều kiện WHERE scheduled_at BETWEEN ... (lọc theo khoảng thời gian).
--   * Đây cũng là truy vấn hưởng lợi nếu áp dụng phân vùng theo thời gian
--     như đã trình bày ở phần Phân vùng dữ liệu (Chương 4).

-- ----------------------------------------------------------------------------
-- M3. Thiết bị bảo trì nhiều lần (từ 2 lần trở lên)
-- ----------------------------------------------------------------------------
SELECT TOP (20)
    res.resource_id,
    res.name,
    res.resource_type,
    res.condition,
    COUNT(m.maintenance_id) AS so_lan_bao_tri,
    SUM(m.cost)             AS tong_chi_phi_bao_tri,
    MAX(m.scheduled_at)     AS lan_bao_tri_gan_nhat
FROM dbo.RESOURCE res
INNER JOIN dbo.MAINTENANCE m ON m.resource_id = res.resource_id
GROUP BY res.resource_id, res.name, res.resource_type, res.condition
HAVING COUNT(m.maintenance_id) >= 2
ORDER BY tong_chi_phi_bao_tri DESC;
-- PHÂN TÍCH:
--   * Minh họa quan hệ Resource - Maintenance (1:N, Chương 2): một tài nguyên có
--     nhiều lịch sử bảo trì trong vòng đời.
--   * Kết quả dự kiến: 3.000 tài nguyên có 2 lần bảo trì (18.000 phiếu chia cho
--     15.000 tài nguyên), 12.000 tài nguyên có 1 lần.
--   * JOIN dùng IX_MAINTENANCE_ResourceId nên không phải quét toàn bảng
--     MAINTENANCE cho mỗi tài nguyên.

-- ----------------------------------------------------------------------------
-- M4. Phát hiện dữ liệu bảo trì không nhất quán
-- ----------------------------------------------------------------------------
SELECT
    N'Phiếu Scheduled nhưng ngày dự kiến đã qua' AS loai_bat_thuong,
    COUNT(*) AS so_ban_ghi
FROM dbo.MAINTENANCE
WHERE status = N'Scheduled'
  AND scheduled_at < SYSDATETIME()
UNION ALL
SELECT
    N'Đang bảo trì (In_Progress) nhưng tài nguyên vẫn Available',
    COUNT(DISTINCT m.resource_id)
FROM dbo.MAINTENANCE m
INNER JOIN dbo.RESOURCE res ON res.resource_id = m.resource_id
WHERE m.status = N'In_Progress'
  AND res.status = N'Available';
-- PHÂN TÍCH:
--   * Kết quả dự kiến: 900 phiếu Scheduled có ngày dự kiến trong quá khứ và
--     2.565 tài nguyên đang bảo trì nhưng vẫn ghi Available.
--   * Trạng thái của RESOURCE và MAINTENANCE đang được cập nhật độc lập nên dễ
--     lệch nhau. Đây cũng là nguyên nhân gốc của các vi phạm ở truy vấn R4.

-- ============================================================================
-- GHI CHÚ: ĐỀ XUẤT SỬA DỮ LIỆU MẪU (05_seed_data.sql) - CẦN THỐNG NHẤT VỚI NHÓM
-- ============================================================================
-- 1. USER.created_at:
--      thay  DATEADD(DAY, -(100 - id), '2026-08-01 08:00:00')
--      bằng  DATEADD(DAY, -(id % 730), '2026-07-01 08:00:00')
-- 2. SERVICE_PROVIDER.created_at:
--      thay  DATEADD(DAY, -(50 - n), '2026-08-05 09:00:00')
--      bằng  DATEADD(DAY, -(n % 365), '2026-07-01 09:00:00')
-- 3. Đồng bộ trạng thái Resource sau khi seed MAINTENANCE:
--      UPDATE res SET res.status = N'Maintenance'
--      FROM dbo.RESOURCE res
--      WHERE EXISTS (SELECT 1 FROM dbo.MAINTENANCE m
--                    WHERE m.resource_id = res.resource_id
--                      AND m.status = N'In_Progress');
-- Sau khi sửa, chạy lại U4, M4 để xác nhận còn 0 dòng bất thường.
-- ============================================================================
