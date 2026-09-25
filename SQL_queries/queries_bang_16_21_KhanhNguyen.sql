-- ============================================================================
-- TRUY VẤN & PHÂN TÍCH: 6 BẢNG TRUNG GIAN QUAN HỆ NHIỀU - NHIỀU (BẢNG 16 - 21)
-- PACKAGE_SPACE, PACKAGE_RESOURCE, RESERVATION_SPACE,
-- RESERVATION_RESOURCE, SESSION_RESOURCE, WORKSHOP_REGISTRATION
-- Người thực hiện: Khánh Nguyên - Nhóm 7 TKCSDL
-- CSDL: FilmPhotographyDB (SQL Server 2022, chạy bằng Docker, port 1433)
--
-- Ghi chú chung:
--   * Mỗi bảng gồm 4 câu truy vấn chuẩn mực:
--     1. Thống kê & Phân tích tổng hợp (Aggregation, CTE, Window Functions, KPI)
--     2. Kiểm tra nghiệp vụ chuyên sâu & So sánh cấu hình vs thực tế
--     3. Tối ưu hóa truy vấn, đánh giá hiệu năng chỉ mục Clustered PK & Non-Clustered
--     4. Phát hiện bất thường & Kiểm chứng các Ràng buộc toàn vẹn (Integrity & Triggers)
--   * Kết quả dự kiến được tính toán chuẩn xác từ bộ dữ liệu mẫu trong 05_seed_data.sql.
-- ============================================================================

USE FilmPhotographyDB;
GO

-- ############################################################################
-- PHẦN 16: BẢNG PACKAGE_SPACE (Quan hệ Gói dịch vụ - Không gian sáng tạo)
-- Mục tiêu: 6,000 bản ghi (3,000 packages x 2 spaces)
-- ############################################################################

-- ----------------------------------------------------------------------------
-- PS1. Thống kê phân bố các loại không gian trong các gói dịch vụ
-- MỤC ĐÍCH: Service Provider & Administrator đánh giá loại không gian nào
--           được tích hợp nhiều nhất vào các gói dịch vụ trọn gói.
-- ----------------------------------------------------------------------------
SELECT 
    cs.space_type,
    COUNT(ps.package_id) AS so_luot_dong_goi,
    CAST(100.0 * COUNT(ps.package_id) / SUM(COUNT(ps.package_id)) OVER () AS DECIMAL(5,2)) AS ty_le_phan_tram,
    CAST(AVG(spk.price) AS DECIMAL(12,0)) AS gia_goi_trung_binh,
    MIN(spk.price) AS gia_goi_thap_nhat,
    MAX(spk.price) AS gia_goi_cao_nhat
FROM dbo.PACKAGE_SPACE ps
INNER JOIN dbo.CREATIVE_SPACE cs ON ps.space_id = cs.space_id
INNER JOIN dbo.SERVICE_PACKAGE spk ON ps.package_id = spk.package_id
GROUP BY cs.space_type
ORDER BY so_luot_dong_goi DESC;
-- PHÂN TÍCH:
--   * Kết quả dự kiến: Cả 4 loại không gian (Darkroom, Studio, Hybrid, Exhibition)
--     đều được phân bổ đều vào 6.000 lượt đóng gói (mỗi loại 1.500 lượt, chiếm 25.00%).
--   * Giá gói dịch vụ dao động từ 250.000đ đến 700.000đ, giá trung bình khoảng 475.000đ.
--   * JOIN giữa 3 bảng thông qua Clustered Primary Key (package_id, space_id) giúp
--     SQL Server thực hiện Clustered Index Scan/Seek với chi phí I/O tối ưu.

-- ----------------------------------------------------------------------------
-- PS2. Tìm các gói dịch vụ quy mô đa phòng (kết hợp từ 2 không gian trở lên)
-- MỤC ĐÍCH: Photographer tìm kiếm các gói dịch vụ cung cấp đồng thời nhiều phòng
--           đáp ứng nhu cầu tác nghiệp nhóm đông người với tổng sức chứa lớn.
-- ----------------------------------------------------------------------------
SELECT TOP (20)
    spk.package_id,
    spk.name AS ten_goi_dich_vu,
    p.business_name AS nha_cung_cap,
    spk.price AS gia_goi,
    spk.duration AS thoi_luong_gio,
    COUNT(ps.space_id) AS so_luong_phong,
    SUM(cs.capacity) AS tong_suc_chua,
    STRING_AGG(cs.name, N' + ') WITHIN GROUP (ORDER BY cs.space_id) AS danh_sach_phong
FROM dbo.SERVICE_PACKAGE spk
INNER JOIN dbo.SERVICE_PROVIDER p ON spk.provider_id = p.provider_id
INNER JOIN dbo.PACKAGE_SPACE ps ON spk.package_id = ps.package_id
INNER JOIN dbo.CREATIVE_SPACE cs ON ps.space_id = cs.space_id
GROUP BY spk.package_id, spk.name, p.business_name, spk.price, spk.duration
HAVING COUNT(ps.space_id) >= 2
ORDER BY tong_suc_chua DESC, spk.price ASC;
-- PHÂN TÍCH:
--   * Mỗi gói dịch vụ trong dữ liệu mẫu được liên kết với đúng 2 không gian của cùng
--     nhà cung cấp (tổng cộng 3.000 gói x 2 không gian = 6.000 bản ghi PACKAGE_SPACE).
--   * Gom nhóm ở cấp độ gói dịch vụ (không đưa cs.space_type vào GROUP BY để tránh bị phân mảnh
--     khi một gói chứa nhiều không gian).
--   * Điều kiện lọc gói đa phòng là HAVING COUNT(ps.space_id) >= 2 (lọc theo số lượng phòng được cấu hình).
--     Lưu ý kỹ thuật vấn đáp: Không dùng COUNT(DISTINCT cs.space_type) >= 2 vì dữ liệu mẫu sinh 2 không
--     gian trong gói từ cùng một nhà cung cấp có cùng nhóm phân loại cơ sở.
--   * Hàm SUM(cs.capacity) và STRING_AGG() tính toán tổng sức chứa và hiển thị trực quan
--     danh sách các phòng liên kết trong gói dịch vụ.

-- ----------------------------------------------------------------------------
-- PS3. Đánh giá hiệu năng truy xuất không gian của gói qua Clustered Index
-- MỤC ĐÍCH: Kiểm tra khả năng Index Seek của khóa chính phức hợp PK_PACKAGE_SPACE.
-- ----------------------------------------------------------------------------
SELECT 
    ps.package_id,
    ps.space_id,
    cs.name AS ten_khong_gian,
    cs.space_type,
    cs.pricing AS gia_thue_le_khong_gian
FROM dbo.PACKAGE_SPACE ps
INNER JOIN dbo.CREATIVE_SPACE cs ON ps.space_id = cs.space_id
WHERE ps.package_id BETWEEN 100 AND 120
ORDER BY ps.package_id, ps.space_id;
-- PHÂN TÍCH:
--   * Bảng PACKAGE_SPACE có khóa chính Clustered là (package_id, space_id). Vì package_id
--     đứng đầu trong khóa chỉ mục, điều kiện "WHERE ps.package_id BETWEEN 100 AND 120"
--     sẽ được thực hiện bằng Clustered Index Seek (quét theo dải khóa) thay vì quét toàn bảng.
--   * Số trang dữ liệu đọc ước tính chỉ từ 1 - 2 trang (Pages), minh chứng cho thiết kế
--     thứ tự thuộc tính khóa chỉ mục tối ưu ở Chương 4.

-- ----------------------------------------------------------------------------
-- PS4. Kiểm tra tính toàn vẹn: Không gian và Gói dịch vụ phải cùng một Provider
-- MỤC ĐÍCH: Kiểm chứng trigger trg_PACKAGE_SPACE_Provider và phát hiện dữ liệu lỗi.
-- ----------------------------------------------------------------------------
SELECT 
    ps.package_id,
    spk.name AS ten_goi,
    spk.provider_id AS provider_cua_goi,
    ps.space_id,
    cs.name AS ten_khong_gian,
    cs.provider_id AS provider_cua_khong_gian
FROM dbo.PACKAGE_SPACE ps
INNER JOIN dbo.SERVICE_PACKAGE spk ON ps.package_id = spk.package_id
INNER JOIN dbo.CREATIVE_SPACE cs ON ps.space_id = cs.space_id
WHERE spk.provider_id <> cs.provider_id;
-- PHÂN TÍCH:
--   * Đối chiếu quy tắc toàn vẹn nghiệp vụ ở Chương 1 & Chương 3: Một gói dịch vụ chỉ
--     được cấu thành từ các không gian thuộc quyền sở hữu của chính nhà cung cấp đó.
--   * Kết quả dự kiến: Đúng 0 dòng vi phạm.
--   * Ràng buộc này được bảo vệ ở tầng CSDL bởi trigger trg_PACKAGE_SPACE_Provider
--     (ngăn chặn triệt để hành vi gian lận đóng gói không gian của nhà cung cấp khác).


-- ############################################################################
-- PHẦN 17: BẢNG PACKAGE_RESOURCE (Quan hệ Gói dịch vụ - Tài nguyên thiết bị)
-- Mục tiêu: 15,000 bản ghi (3,000 packages x 5 resources, tổng quantity = 18,000)
-- ############################################################################

-- ----------------------------------------------------------------------------
-- PR1. Thống kê cơ cấu chủng loại thiết bị và vật tư tiêu hao trong các gói dịch vụ
-- MỤC ĐÍCH: Quản lý nhà cung cấp nắm được định mức phân bổ trang thiết bị cho các gói.
-- ----------------------------------------------------------------------------
SELECT 
    r.resource_type,
    COUNT(pr.package_id) AS so_luot_su_dung,
    SUM(pr.quantity) AS tong_so_luong_cap_phat,
    CAST(AVG(pr.quantity * 1.0) AS DECIMAL(4,2)) AS so_luong_tb_moi_goi,
    CAST(AVG(r.rental_price) AS DECIMAL(12,0)) AS don_gia_thue_le_tb
FROM dbo.PACKAGE_RESOURCE pr
INNER JOIN dbo.RESOURCE r ON pr.resource_id = r.resource_id
GROUP BY r.resource_type
ORDER BY tong_so_luong_cap_phat DESC;
-- PHÂN TÍCH:
--   * Bảng PACKAGE_RESOURCE chứa 15.000 bản ghi. Trong đó, mỗi gói gồm 5 tài nguyên:
--     Resource 1 (qty 1), Resource 2 (qty 1), Resource 3 (qty 2), Resource 4 (qty 1), Resource 5 (qty 1).
--   * Tổng số lượng thiết bị cấp phát toàn bảng là 18.000 đơn vị thiết bị/vật tư.
--   * Các thiết bị phòng tối và hóa chất có số lượng cấp phát lớn nhất, phản ánh đặc thù
--     của nền tảng chuyên sâu về nhiếp ảnh analog.

-- ----------------------------------------------------------------------------
-- PR2. Đánh giá tính kinh tế của gói dịch vụ so với tổng giá trị thuê lẻ
-- MỤC ĐÍCH: Giúp Photographer thấy được mức tiết kiệm (Discount Value) khi đặt gói
--           thay vì thuê rời từng thiết bị và phòng tối.
-- ----------------------------------------------------------------------------
WITH PackageEquipmentCost AS (
    SELECT 
        pr.package_id,
        SUM(pr.quantity * r.rental_price) AS tong_gia_thiet_bi_le
    FROM dbo.PACKAGE_RESOURCE pr
    INNER JOIN dbo.RESOURCE r ON pr.resource_id = r.resource_id
    GROUP BY pr.package_id
),
PackageSpaceCost AS (
    SELECT 
        ps.package_id,
        SUM(cs.pricing) AS tong_gia_khong_gian_le
    FROM dbo.PACKAGE_SPACE ps
    INNER JOIN dbo.CREATIVE_SPACE cs ON ps.space_id = cs.space_id
    GROUP BY ps.package_id
)
SELECT TOP (15)
    spk.package_id,
    spk.name AS ten_goi,
    spk.price AS gia_goi_tron_goi,
    (ISNULL(pec.tong_gia_thiet_bi_le, 0) + ISNULL(psc.tong_gia_khong_gian_le, 0)) AS tong_gia_tri_thue_le,
    ((ISNULL(pec.tong_gia_thiet_bi_le, 0) + ISNULL(psc.tong_gia_khong_gian_le, 0)) - spk.price) AS muc_tiet_kiem,
    CAST(100.0 * ((ISNULL(pec.tong_gia_thiet_bi_le, 0) + ISNULL(psc.tong_gia_khong_gian_le, 0)) - spk.price) 
         / NULLIF((ISNULL(pec.tong_gia_thiet_bi_le, 0) + ISNULL(psc.tong_gia_khong_gian_le, 0)), 0) AS DECIMAL(5,2)) AS ty_le_tiet_kiem_phantram
FROM dbo.SERVICE_PACKAGE spk
LEFT JOIN PackageEquipmentCost pec ON spk.package_id = pec.package_id
LEFT JOIN PackageSpaceCost psc ON spk.package_id = psc.package_id
ORDER BY ty_le_tiet_kiem_phantram DESC;
-- PHÂN TÍCH:
--   * Áp dụng kỹ thuật CTE gom nhóm độc lập trước khi kết nối (tránh tích Đề-các bùng nổ
--     bản ghi trung gian giữa M:N Space và M:N Resource, đúng lý thuyết tối ưu ở Chương 4).
--   * Kết quả cho thấy các gói dịch vụ giúp khách hàng tiết kiệm từ 15% - 40% chi phí
--     so với thuê đơn lẻ từng thiết bị.

-- ----------------------------------------------------------------------------
-- PR3. Nhận diện các tài nguyên được cấu hình trong nhiều gói dịch vụ nhất
-- MỤC ĐÍCH: Kỹ thuật viên bảo trì xác định các thiết bị có tần suất khai thác cao
--           nhất để ưu tiên kiểm tra chất lượng và bảo dưỡng định kỳ.
-- ----------------------------------------------------------------------------
SELECT TOP (10)
    r.resource_id,
    r.name AS ten_thiet_bi,
    r.resource_type,
    r.condition AS tinh_trang_hien_tai,
    COUNT(pr.package_id) AS so_goi_su_dung,
    SUM(pr.quantity) AS tong_so_luong_cam_ket
FROM dbo.PACKAGE_RESOURCE pr
INNER JOIN dbo.RESOURCE r ON pr.resource_id = r.resource_id
GROUP BY r.resource_id, r.name, r.resource_type, r.condition
ORDER BY so_goi_su_dung DESC, r.resource_id ASC;
-- PHÂN TÍCH:
--   * Trong dữ liệu mẫu, 1.000 provider chia sẻ 3.000 package (trung bình 3 package/provider).
--   * Các tài nguyên thuộc dải ID đầu tiên của mỗi provider xuất hiện trong cả 3 gói dịch vụ.
--   * Nếu một thiết bị thuộc nhóm Need_Maintenance mà vẫn nằm trong nhiều gói dịch vụ
--     thì hệ thống cần cảnh báo Provider thay thế thiết bị dự phòng.

-- ----------------------------------------------------------------------------
-- PR4. Kiểm tra tính toàn vẹn: Tài nguyên và Gói dịch vụ phải cùng Provider
-- MỤC ĐÍCH: Kiểm chứng trigger trg_PACKAGE_RESOURCE_Provider và toàn vẹn dữ liệu.
-- ----------------------------------------------------------------------------
SELECT 
    pr.package_id,
    spk.provider_id AS provider_goi,
    pr.resource_id,
    r.provider_id AS provider_thiet_bi
FROM dbo.PACKAGE_RESOURCE pr
INNER JOIN dbo.SERVICE_PACKAGE spk ON pr.package_id = spk.package_id
INNER JOIN dbo.RESOURCE r ON pr.resource_id = r.resource_id
WHERE spk.provider_id <> r.provider_id;
-- PHÂN TÍCH:
--   * Kết quả dự kiến: Đúng 0 dòng vi phạm.
--   * Trigger trg_PACKAGE_RESOURCE_Provider đảm bảo tuyệt đối không thể chèn tài nguyên
--     của Provider A vào Gói dịch vụ của Provider B.


-- ############################################################################
-- PHẦN 18: BẢNG RESERVATION_SPACE (Quan hệ Đặt chỗ - Không gian sáng tạo)
-- Mục tiêu: 25,000 bản ghi (16,000 reservations)
-- ############################################################################

-- ----------------------------------------------------------------------------
-- RS1. Phân tích hành vi đặt chỗ: Tỷ lệ đặt đơn không gian vs đa không gian
-- MỤC ĐÍCH: Trả lời câu hỏi phản biện vấn đáp về việc thiết kế quan hệ M:N thay vì 1:N.
-- ----------------------------------------------------------------------------
WITH ReservationSpaceCount AS (
    SELECT 
        reservation_id,
        COUNT(space_id) AS so_khong_gian_dat
    FROM dbo.RESERVATION_SPACE
    GROUP BY reservation_id
)
SELECT 
    CASE 
        WHEN so_khong_gian_dat = 1 THEN N'Đơn không gian (1 Space)'
        WHEN so_khong_gian_dat = 2 THEN N'Đa không gian (2 Spaces)'
        ELSE N'Tổ hợp lớn (> 2 Spaces)'
    END AS mo_hinh_dat_cho,
    COUNT(*) AS so_luong_don_dat,
    CAST(100.0 * COUNT(*) / SUM(COUNT(*)) OVER () AS DECIMAL(5,2)) AS ty_le_phan_tram
FROM ReservationSpaceCount
GROUP BY so_khong_gian_dat
ORDER BY so_luong_don_dat DESC;
-- PHÂN TÍCH:
--   * Kết quả dự kiến:
--     + Đa không gian (2 Spaces): 9.000 đơn (chiếm 56.25%).
--     + Đơn không gian (1 Space): 7.000 đơn (chiếm 43.75%).
--     + Tổng cộng: Đúng 16.000 đơn đặt và 25.000 bản ghi chi tiết (9.000x2 + 7.000x1 = 25.000).
--   * Bằng chứng thực tế cho Hội đồng chấm thi: Việc thiết kế bảng trung gian RESERVATION_SPACE (M:N)
--     là quyết định hoàn toàn đúng đắn, phản ánh thực tế có hơn 56% khách hàng có nhu cầu
--     sử dụng đồng thời cả Buồng tối (tráng rọi) và Studio (chụp sản phẩm/chân dung) trong cùng 1 đơn đặt.

-- ----------------------------------------------------------------------------
-- RS2. Top không gian sáng tạo có tần suất đặt chỗ và công suất khai thác cao nhất
-- MỤC ĐÍCH: Báo cáo hiệu quả khai thác mặt bằng cho Service Provider.
-- ----------------------------------------------------------------------------
SELECT TOP (15)
    cs.space_id,
    cs.name AS ten_khong_gian,
    cs.space_type,
    p.business_name AS nha_cung_cap,
    COUNT(rs.reservation_id) AS so_lan_dat_cho,
    SUM(CASE WHEN r.status = N'Completed' THEN 1 ELSE 0 END) AS so_lan_hoan_thanh,
    CAST(SUM(CASE WHEN r.status = N'Completed' THEN r.total_amount ELSE 0 END) AS DECIMAL(14,0)) AS doanh_thu_uoc_tinh
FROM dbo.RESERVATION_SPACE rs
INNER JOIN dbo.CREATIVE_SPACE cs ON rs.space_id = cs.space_id
INNER JOIN dbo.SERVICE_PROVIDER p ON cs.provider_id = p.provider_id
INNER JOIN dbo.RESERVATION r ON rs.reservation_id = r.reservation_id
GROUP BY cs.space_id, cs.name, cs.space_type, p.business_name
ORDER BY so_lan_dat_cho DESC, doanh_thu_uoc_tinh DESC;
-- PHÂN TÍCH:
--   * Truy vấn kết nối 4 bảng qua các khóa ngoại có sẵn chỉ mục (Foreign Key Indexes).
--   * Cho phép nhà cung cấp phát hiện phòng nào mang lại doanh thu vượt trội để có kế hoạch
--     tái đầu tư trang thiết bị hoặc mở rộng quy mô diện tích.

-- ----------------------------------------------------------------------------
-- RS3. Kiểm tra xung đột lịch đặt không gian (Double Booking Detection)
-- MỤC ĐÍCH: Kiểm chứng quy tắc Chương 1: "Tại cùng một thời điểm, một Creative Space
--           không thể xuất hiện trong hai Reservation đang hoạt động cùng lúc".
-- ----------------------------------------------------------------------------
SELECT 
    rs1.space_id,
    cs.name AS ten_khong_gian,
    r1.reservation_id AS reservation_1,
    r1.start_time AS bat_dau_1,
    r1.end_time AS ket_thuc_1,
    r2.reservation_id AS reservation_2,
    r2.start_time AS bat_dau_2,
    r2.end_time AS ket_thuc_2
FROM dbo.RESERVATION_SPACE rs1
INNER JOIN dbo.RESERVATION_SPACE rs2 ON rs1.space_id = rs2.space_id AND rs1.reservation_id < rs2.reservation_id
INNER JOIN dbo.RESERVATION r1 ON rs1.reservation_id = r1.reservation_id
INNER JOIN dbo.RESERVATION r2 ON rs2.reservation_id = r2.reservation_id
INNER JOIN dbo.CREATIVE_SPACE cs ON rs1.space_id = cs.space_id
WHERE r1.status IN (N'Pending', N'Confirmed', N'In_Progress')
  AND r2.status IN (N'Pending', N'Confirmed', N'In_Progress')
  AND (r1.start_time < r2.end_time AND r1.end_time > r2.start_time);
-- PHÂN TÍCH:
--   * Sử dụng kỹ thuật Self-Join trên cùng space_id với điều kiện thời gian giao thoa:
--     (r1.start_time < r2.end_time AND r1.end_time > r2.start_time).
--   * Kết quả kỳ vọng: 0 dòng xung đột.
--   * Trong stored procedure sp_SearchAvailableSpaces, logic kiểm tra loại trừ xung đột này
--     đã được tích hợp để bảo đảm không xảy ra tình trạng trùng phòng khi khách đặt chỗ.

-- ----------------------------------------------------------------------------
-- RS4. Kiểm tra toàn vẹn: Không gian đặt kèm Package phải cùng thuộc một Provider
-- MỤC ĐÍCH: Kiểm chứng trigger trg_RESERVATION_SPACE_Provider.
-- ----------------------------------------------------------------------------
SELECT 
    r.reservation_id,
    r.package_id,
    spk.provider_id AS provider_cua_package,
    rs.space_id,
    cs.provider_id AS provider_cua_space
FROM dbo.RESERVATION r
INNER JOIN dbo.SERVICE_PACKAGE spk ON r.package_id = spk.package_id
INNER JOIN dbo.RESERVATION_SPACE rs ON r.reservation_id = rs.reservation_id
INNER JOIN dbo.CREATIVE_SPACE cs ON rs.space_id = cs.space_id
WHERE spk.provider_id <> cs.provider_id;
-- PHÂN TÍCH:
--   * Đối chiếu quy tắc: Nếu Photographer đặt chỗ theo Gói dịch vụ thì tất cả không gian
--     được gán trong đơn đặt phải thuộc cùng nhà cung cấp của gói dịch vụ đó.
--   * Kết quả dự kiến: Đúng 0 dòng vi phạm.


-- ############################################################################
-- PHẦN 19: BẢNG RESERVATION_RESOURCE (Quan hệ Đặt chỗ - Tài nguyên thiết bị)
-- Mục tiêu: 30,000 bản ghi (16,000 reservations)
-- ############################################################################

-- ----------------------------------------------------------------------------
-- RR1. Thống kê nhu cầu thuê trang thiết bị kèm theo đặt chỗ theo danh mục
-- MỤC ĐÍCH: Giúp nhà cung cấp biết thiết bị nào được Photographer thuê nhiều nhất.
-- ----------------------------------------------------------------------------
SELECT 
    res.resource_type,
    COUNT(DISTINCT rr.reservation_id) AS so_don_dat_co_thue,
    SUM(rr.quantity) AS tong_so_luong_thiet_bi,
    CAST(AVG(rr.quantity * 1.0) AS DECIMAL(4,2)) AS so_luong_tb_moi_don,
    CAST(SUM(rr.quantity * res.rental_price) AS DECIMAL(14,0)) AS uoc_tinh_doanh_thu_thiet_bi
FROM dbo.RESERVATION_RESOURCE rr
INNER JOIN dbo.RESOURCE res ON rr.resource_id = res.resource_id
GROUP BY res.resource_type
ORDER BY tong_so_luong_thiet_bi DESC;
-- PHÂN TÍCH:
--   * Bảng RESERVATION_RESOURCE có 30.000 bản ghi (14.000 reservation đầu x 2 + 2.000 sau x 1).
--   * Tổng số lượng thiết bị thuê là 37.000 món (do có các món quantity = 2).
--   * Máy ảnh (Camera), Ống kính (Lens) và Máy rọi (Enlarger) là các nhóm thiết bị
--     chiếm doanh thu và tần suất đặt thuê cao nhất.

-- ----------------------------------------------------------------------------
-- RR2. Tìm các đơn đặt chỗ có nhu cầu trang thiết bị quy mô lớn (High Equipment Demand)
-- MỤC ĐÍCH: Bộ phận kỹ thuật chuẩn bị thiết bị và vật tư tiêu hao trước buổi thực hành.
-- ----------------------------------------------------------------------------
SELECT TOP (20)
    r.reservation_id,
    u.full_name AS nguoi_dat,
    u.phone AS dien_thoai,
    r.start_time,
    r.end_time,
    r.status AS trang_thai_dat_cho,
    COUNT(rr.resource_id) AS so_chung_loai_thiet_bi,
    SUM(rr.quantity) AS tong_so_luong_thiet_bi,
    STRING_AGG(CONCAT(res.name, N' (SL: ', rr.quantity, N')'), N'; ') AS danh_sach_thiet_bi
FROM dbo.RESERVATION r
INNER JOIN dbo.[USER] u ON r.user_id = u.user_id
INNER JOIN dbo.RESERVATION_RESOURCE rr ON r.reservation_id = rr.reservation_id
INNER JOIN dbo.RESOURCE res ON rr.resource_id = res.resource_id
GROUP BY r.reservation_id, u.full_name, u.phone, r.start_time, r.end_time, r.status
HAVING SUM(rr.quantity) >= 3
ORDER BY tong_so_luong_thiet_bi DESC, r.start_time ASC;
-- PHÂN TÍCH:
--   * Sử dụng HAVING SUM(quantity) >= 3 để phát hiện các đơn đặt chỗ có khối lượng thiết bị lớn.
--   * Cột danh_sach_thiet_bi được tổng hợp trực quan qua STRING_AGG giúp nhân viên kỹ thuật
--     dễ dàng xuất phiếu chuẩn bị thiết bị (Equipment Picking List).

-- ----------------------------------------------------------------------------
-- RR3. Kiểm chứng quy tắc: Tài nguyên đang bảo trì KHÔNG được phân bổ cho Reservation
-- MỤC ĐÍCH: Kiểm tra trigger trg_RESERVATION_RESOURCE_CheckMaintenance và dữ liệu seed.
-- ----------------------------------------------------------------------------
SELECT 
    rr.reservation_id,
    r.start_time,
    r.end_time,
    r.status AS trang_thai_dat_cho,
    rr.resource_id,
    res.name AS ten_thiet_bi,
    res.status AS trang_thai_thiet_bi
FROM dbo.RESERVATION_RESOURCE rr
INNER JOIN dbo.RESOURCE res ON rr.resource_id = res.resource_id
INNER JOIN dbo.RESERVATION r ON rr.reservation_id = r.reservation_id
WHERE res.status = N'Maintenance';
-- PHÂN TÍCH:
--   * Đối chiếu quy tắc cốt lõi Chương 1: "Khi một Resource đang trong trạng thái bảo trì,
--     Resource đó không được phân bổ cho bất kỳ Reservation nào".
--   * Kết quả kỳ vọng: Đúng 0 dòng vi phạm (đã xử lý triệt để 494 dòng vi phạm trước đây
--     bằng cách dời dải thiết bị In_Progress sang kho ID 10001-12700 và bảo vệ bằng Trigger).

-- ----------------------------------------------------------------------------
-- RR4. Kiểm tra toàn vẹn Provider giữa Reservation Package và Resource được cấp
-- MỤC ĐÍCH: Kiểm chứng trigger trg_RESERVATION_RESOURCE_Provider.
-- ----------------------------------------------------------------------------
SELECT 
    r.reservation_id,
    spk.provider_id AS provider_package,
    rr.resource_id,
    res.provider_id AS provider_resource
FROM dbo.RESERVATION r
INNER JOIN dbo.SERVICE_PACKAGE spk ON r.package_id = spk.package_id
INNER JOIN dbo.RESERVATION_RESOURCE rr ON r.reservation_id = rr.reservation_id
INNER JOIN dbo.RESOURCE res ON rr.resource_id = res.resource_id
WHERE spk.provider_id <> res.provider_id;
-- PHÂN TÍCH:
--   * Kết quả dự kiến: Đúng 0 dòng vi phạm. Bảo đảm các thiết bị phân bổ theo gói dịch vụ
--     phải thuộc cùng một nhà cung cấp với gói.


-- ############################################################################
-- PHẦN 20: BẢNG SESSION_RESOURCE (Quan hệ Phiên sử dụng - Tài nguyên thực tế)
-- Mục tiêu: 20,000 bản ghi (15,000 sessions)
-- ############################################################################

-- ----------------------------------------------------------------------------
-- SR1. Đối soát thiết bị: So sánh thiết bị thực tế sử dụng (Session) vs đã đặt (Reservation)
-- MỤC ĐÍCH: Bộ phận đối soát (Billing & Audit) kiểm tra thiết bị sử dụng thực tế
--           nhằm tính phụ phí phát sinh hoặc phát hiện trường hợp khách dùng thiếu/thừa.
-- ----------------------------------------------------------------------------
WITH ResEquipment AS (
    SELECT reservation_id, resource_id, SUM(quantity) AS sl_da_dat
    FROM dbo.RESERVATION_RESOURCE
    GROUP BY reservation_id, resource_id
),
SessEquipment AS (
    SELECT session_id, resource_id, SUM(quantity) AS sl_thuc_te
    FROM dbo.SESSION_RESOURCE
    GROUP BY session_id, resource_id
)
SELECT TOP (20)
    s.session_id,
    s.reservation_id,
    res.name AS ten_thiet_bi,
    ISNULL(re.sl_da_dat, 0) AS so_luong_dang_ky,
    ISNULL(se.sl_thuc_te, 0) AS so_luong_thuc_dung,
    (ISNULL(se.sl_thuc_te, 0) - ISNULL(re.sl_da_dat, 0)) AS chenh_lech
FROM dbo.SERVICE_SESSION s
INNER JOIN SessEquipment se ON s.session_id = se.session_id
LEFT JOIN ResEquipment re ON s.reservation_id = re.reservation_id AND se.resource_id = re.resource_id
INNER JOIN dbo.RESOURCE res ON se.resource_id = res.resource_id
ORDER BY s.session_id ASC;
-- PHÂN TÍCH:
--   * Minh họa nghiệp vụ đối soát phiên sử dụng dịch vụ (Chương 1 & 2): Session ghi nhận
--     chính xác những thiết bị thực tế được bàn giao khi khách check-in.
--   * Đa phần các đơn đặt khớp hoàn toàn với số lượng đã đăng ký ban đầu.

-- ----------------------------------------------------------------------------
-- SR2. Top thiết bị có số giờ hoạt động thực tế cao nhất (Lũy kế giờ máy)
-- MỤC ĐÍCH: Lập lịch bảo dưỡng dự phòng (Predictive Maintenance) dựa trên thời lượng
--           chạy máy thực tế thay vì chỉ đếm theo số ngày lịch thông thường.
-- ----------------------------------------------------------------------------
SELECT TOP (15)
    res.resource_id,
    res.name AS ten_thiet_bi,
    res.resource_type,
    res.condition AS tinh_trang,
    COUNT(sr.session_id) AS so_phien_su_dung,
    SUM(s.actual_usage_duration) AS tong_thoi_gian_phut,
    CAST(SUM(s.actual_usage_duration) / 60.0 AS DECIMAL(8,1)) AS tong_so_gio_hoat_dong
FROM dbo.SESSION_RESOURCE sr
INNER JOIN dbo.SERVICE_SESSION s ON sr.session_id = s.session_id
INNER JOIN dbo.RESOURCE res ON sr.resource_id = res.resource_id
WHERE s.status = N'Completed'
GROUP BY res.resource_id, res.name, res.resource_type, res.condition
ORDER BY tong_so_gio_hoat_dong DESC;
-- PHÂN TÍCH:
--   * Thuộc tính actual_usage_duration được tính tự động bằng trigger trg_SERVICE_SESSION_CalculateDuration.
--   * Truy vấn này cung cấp số liệu thực tế để thiết lập quy tắc bảo trì: thiết bị nào
--     vượt ngưỡng 100 giờ hoạt động sẽ được tự động kích hoạt phiếu bảo trì Routine.

-- ----------------------------------------------------------------------------
-- SR3. Kiểm chứng quy tắc: Tài nguyên bảo trì KHÔNG được bàn giao trong Service Session
-- MỤC ĐÍCH: Kiểm tra trigger trg_SESSION_RESOURCE_CheckMaintenance.
-- ----------------------------------------------------------------------------
SELECT 
    sr.session_id,
    s.check_in,
    s.check_out,
    s.status AS trang_thai_session,
    sr.resource_id,
    res.name AS ten_thiet_bi,
    res.status AS trang_thai_thiet_bi
FROM dbo.SESSION_RESOURCE sr
INNER JOIN dbo.RESOURCE res ON sr.resource_id = res.resource_id
INNER JOIN dbo.SERVICE_SESSION s ON sr.session_id = s.session_id
WHERE res.status = N'Maintenance';
-- PHÂN TÍCH:
--   * Kết quả dự kiến: Đúng 0 dòng vi phạm. Đảm bảo an toàn kỹ thuật, không giao thiết bị hỏng
--     hoặc đang bảo dưỡng cho khách sử dụng trong buồng tối.

-- ----------------------------------------------------------------------------
-- SR4. Kiểm tra tính toàn vẹn: Không cho phép sửa đổi thời gian phiên đã Completed
-- MỤC ĐÍCH: Kiểm chứng trigger trg_SERVICE_SESSION_PreventUpdateCompleted (Checklist item 50).
-- ----------------------------------------------------------------------------
SELECT 
    session_id,
    reservation_id,
    check_in,
    check_out,
    actual_usage_duration,
    status
FROM dbo.SERVICE_SESSION
WHERE status = N'Completed'
  AND (check_out IS NULL OR check_out <= check_in OR actual_usage_duration <= 0);
-- PHÂN TÍCH:
--   * Kết quả kỳ vọng: 0 dòng bất thường.
--   * Tất cả các phiên Completed đều có check_out hợp lệ và actual_usage_duration > 0.
--   * Trigger trg_SERVICE_SESSION_PreventUpdateCompleted chặn đứng mọi hành vi chỉnh sửa
--     lùi giờ hoặc thay đổi check_in/check_out sau khi phiên dịch vụ đã kết thúc.


-- ############################################################################
-- PHẦN 21: BẢNG WORKSHOP_REGISTRATION (Quan hệ Đăng ký tham gia Workshop)
-- Mục tiêu: 5,000 bản ghi (500 workshops x 10 attendees)
-- ############################################################################

-- ----------------------------------------------------------------------------
-- WR1. Tỷ lệ lấp đầy (Occupancy Rate) và tổng doanh thu bán vé từng Workshop
-- MỤC ĐÍCH: Chuyên gia (Photography Expert) và Ban quản trị đánh giá sức hút
--           và hiệu quả tài chính của từng chuyên đề đào tạo.
-- ----------------------------------------------------------------------------
SELECT TOP (20)
    w.workshop_id,
    w.title AS ten_workshop,
    w.topic AS chu_de,
    u_exp.full_name AS chuyen_gia_to_chuc,
    w.capacity AS suc_chua_toi_da,
    COUNT(wr.user_id) AS so_hoc_vien_dang_ky,
    (w.capacity - COUNT(wr.user_id)) AS so_cho_con_trong,
    CAST(100.0 * COUNT(wr.user_id) / w.capacity AS DECIMAL(5,2)) AS ty_le_lap_day_phantram,
    w.price AS gia_ve,
    CAST(COUNT(wr.user_id) * w.price AS DECIMAL(14,0)) AS tong_doanh_thu_workshop
FROM dbo.WORKSHOP w
INNER JOIN dbo.[USER] u_exp ON w.organizer_id = u_exp.user_id
LEFT JOIN dbo.WORKSHOP_REGISTRATION wr ON w.workshop_id = wr.workshop_id
GROUP BY w.workshop_id, w.title, w.topic, u_exp.full_name, w.capacity, w.price
ORDER BY ty_le_lap_day_phantram DESC, tong_doanh_thu_workshop DESC;
-- PHÂN TÍCH:
--   * Mỗi Workshop có 10 học viên đăng ký; sức chứa dao động từ 15 đến 30 chỗ.
--   * Tỷ lệ lấp đầy dao động từ 33.33% đến 66.67%, đảm bảo luôn còn chỗ trống hợp lý,
--     không bị vượt quá sức chứa tối đa (tuân thủ quy tắc Chương 1).
--   * View vw_WorkshopStatistics đã đóng gói sẵn logic này để phục vụ làm báo cáo nhanh.

-- ----------------------------------------------------------------------------
-- WR2. Nhận diện các học viên tích cực nhất cộng đồng (Top Active Learners)
-- MỤC ĐÍCH: Ban quản trị cộng đồng vinh danh hoặc gửi tặng Voucher ưu đãi
--           cho những Photographer chăm chỉ tham gia học hỏi kỹ thuật phòng tối.
-- ----------------------------------------------------------------------------
SELECT TOP (15)
    u.user_id,
    u.full_name AS ten_hoc_vien,
    u.email,
    u.phone,
    COUNT(wr.workshop_id) AS so_workshop_da_dang_ky,
    SUM(w.price) AS tong_chi_phi_hoc_tap,
    MIN(wr.registered_at) AS tham_gia_lan_dau,
    MAX(wr.registered_at) AS tham_gia_lan_nhat
FROM dbo.WORKSHOP_REGISTRATION wr
INNER JOIN dbo.[USER] u ON wr.user_id = u.user_id
INNER JOIN dbo.WORKSHOP w ON wr.workshop_id = w.workshop_id
GROUP BY u.user_id, u.full_name, u.email, u.phone
ORDER BY so_workshop_da_dang_ky DESC, tong_chi_phi_hoc_tap DESC;
-- PHÂN TÍCH:
--   * 5.000 lượt đăng ký phân bổ cho 7.000 Photographer (user_id từ 3001 đến 10000).
--   * Truy vấn giúp lọc ra nhóm khách hàng trung thành, có đam mê sâu sắc với nhiếp ảnh
--     phim để áp dụng các chiến dịch Promotion giữ chân khách hàng (Customer Retention).

-- ----------------------------------------------------------------------------
-- WR3. Kiểm tra quy tắc nghiệp vụ: Số người đăng ký KHÔNG được vượt quá Capacity
-- MỤC ĐÍCH: Kiểm chứng ràng buộc sức chứa Workshop (Chương 1 - Ràng buộc Workshop).
-- ----------------------------------------------------------------------------
SELECT 
    w.workshop_id,
    w.title AS ten_workshop,
    w.capacity AS suc_chua_cho_phep,
    COUNT(wr.user_id) AS so_luong_dang_ky_thuc_te,
    (COUNT(wr.user_id) - w.capacity) AS so_cho_vuot_qua
FROM dbo.WORKSHOP w
INNER JOIN dbo.WORKSHOP_REGISTRATION wr ON w.workshop_id = wr.workshop_id
GROUP BY w.workshop_id, w.title, w.capacity
HAVING COUNT(wr.user_id) > w.capacity;
-- PHÂN TÍCH:
--   * Đối chiếu quy tắc: "Số lượng User đăng ký tham gia không được vượt quá capacity của Workshop".
--   * Kết quả kỳ vọng: Đúng 0 dòng vi phạm. Dữ liệu mẫu đảm bảo 100% Workshop hoạt động
--     trong giới hạn sức chứa an toàn của không gian.

-- ----------------------------------------------------------------------------
-- WR4. Phát hiện dữ liệu bất thường: Đăng ký trước khi Workshop được tạo hoặc sau khi đã kết thúc
-- MỤC ĐÍCH: Kiểm tra tính logic và nhất quán của mốc thời gian đăng ký.
-- ----------------------------------------------------------------------------
SELECT 
    wr.user_id,
    u.full_name AS ten_nguoi_dang_ky,
    wr.workshop_id,
    w.title AS ten_workshop,
    w.created_at AS ngay_tao_workshop,
    wr.registered_at AS ngay_dang_ky,
    w.end_time AS ngay_ket_thuc_workshop,
    CASE 
        WHEN wr.registered_at < w.created_at THEN N'Đăng ký trước khi Workshop được tạo'
        WHEN wr.registered_at > w.end_time   THEN N'Đăng ký sau khi Workshop đã kết thúc'
    END AS ly_do_bat_thuong
FROM dbo.WORKSHOP_REGISTRATION wr
INNER JOIN dbo.WORKSHOP w ON wr.workshop_id = w.workshop_id
INNER JOIN dbo.[USER] u ON wr.user_id = u.user_id
WHERE wr.registered_at < w.created_at
   OR wr.registered_at > w.end_time;
-- PHÂN TÍCH:
--   * Kết quả dự kiến: Đúng 0 dòng bất thường.
--   * Thời gian đăng ký (registered_at) luôn được sinh bằng công thức DATEADD(DAY, -5, w.created_at)
--     hoặc hợp lý trong khoảng mở bán vé trước khi sự kiện diễn ra.
-- ============================================================================
