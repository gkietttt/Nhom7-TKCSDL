# TASK — NỀN TẢNG KẾT NỐI CỘNG ĐỒNG NHIẾP ẢNH PHIM

**Project:** Nền tảng kết nối cộng đồng nhiếp ảnh phim với dịch vụ phòng tối và phòng chụp  
**Tiếng Anh:** Platform Connecting the Film Photography Community with Darkroom and Studio Services

**Phạm vi:** Phân tích và thiết kế cơ sở dữ liệu (Database Design)  
**Công nghệ:** Microsoft SQL Server  
**Tác giả:** Nhóm 7  
**Ngày:** 2026-08-14

---

## I. CONTEXT — BỐI CẢNH

### 1.1. Tình huống hiện tại

Trong những năm gần đây, nhiếp ảnh phim (film photography) đã trở lại phổ biến, thu hút ngày càng nhiều người yêu thích giá trị nghệ thuật và quy trình analog của chụp ảnh phim.

Kèm theo sự phát triển của cộng đồng, nhu cầu về các không gian sáng tạo như:
- Phòng tối (darkroom)
- Phòng chụp ảnh (photography studio)
- Thiết bị chuyên dụng
- Dịch vụ hỗ trợ

cũng tăng cao theo.

### 1.2. Vấn đề hiện tại

**Tài nguyên bị phân tán:**

Các nhiếp ảnh gia phải dựa vào:
- Nhóm truyền thông xã hội (social media)
- Liên hệ cá nhân
- Các website riêng lẻ

để tìm kiếm phòng tối hoặc studio khả dụng.

**Quy trình không hiệu quả:**

- Đặt chỗ, hỏi về thiết bị, giá cả, xác nhận → **Xử lý bằng tay** qua điện thoại hoặc tin nhắn
- **Không minh bạch** cho cả khách hàng và nhà cung cấp dịch vụ
- **Tốn thời gian, mất hiệu suất**

**Phía nhà cung cấp dịch vụ:**

- Quản lý không gian, thiết bị, vật liệu tiêu hao → sử dụng **spreadsheet hoặc phần mềm rời rạc**
- Không tối ưu hóa sử dụng tài nguyên
- **Xung đột lịch** xảy ra thường xuyên
- **Khó phân tích kết quả kinh doanh**

**Kết luận:**

Hiện không có nền tảng tích hợp dành cho:
- Kết nối nhiếp ảnh gia với nhà cung cấp dịch vụ
- Chia sẻ tài nguyên sáng tạo
- Quản lý đặt chỗ hiệu quả
- Tương tác cộng đồng
- Quản lý hoạt động kinh doanh

→ Hạn chế chia sẻ tài nguyên, giảm hiệu suất, yếu đi hợp tác cộng đồng

---

## II. PROPOSED SOLUTION — GIẢI PHÁP ĐỀ XUẤT

### 2.1. Mô tả nền tảng

**Nền tảng đa chiều (Multi-Sided Platform)**

Kết nối nhiếp ảnh gia với các nhà cung cấp dịch vụ (phòng tối, phòng chụp ảnh, thiết bị, dịch vụ sáng tạo).

**Khác biệt:** Thay vì ứng dụng đặt chỗ truyền thống, nền tảng **tập trung vào quản lý và chia sẻ tài nguyên sáng tạo**.

### 2.2. Chức năng chính (Core Capabilities)

#### A. Quản lý không gian sáng tạo (Creative Space Management)

Nhà cung cấp dịch vụ:
- Xuất bản và quản lý hồ sơ chi tiết cho mỗi không gian sáng tạo
- Mỗi phòng tối/studio chứa thông tin toàn diện:
  - Kích thước không gian
  - Sức chứa tối đa
  - Phong cách nghệ thuật
  - Điều kiện ánh sáng, thông gió, âm thanh
  - Cơ sở vật chất hỗ trợ
  - Giờ hoạt động, chính sách sử dụng
  - Mô hình giá cả
  - Hình ảnh, tiện nghi khả dụng
- Nền tảng theo dõi liên tục khả dụng của mỗi không gian

#### B. Quản lý thiết bị và tài nguyên (Resource & Equipment Management)

Quản lý tất cả tài nguyên tái sử dụng:
- Camera, ống kính
- Kính phóng đại (enlarger)
- Máy quét phim (film scanner)
- Hệ thống chiếu sáng
- Chân đứng, phông nền
- Thiết bị xử lý phòng tối
- Vật liệu tiêu hao (chất hóa học, giấy ảnh)

Mỗi tài nguyên duy trì:
- Trạng thái khả dụng (availability)
- Lịch bảo trì (maintenance schedule)
- Tình trạng hoạt động (operational condition)
- Giá cho thuê
- Tương thích với gói dịch vụ
- Lịch sử sử dụng (utilization history)

#### C. Đặt chỗ và phân bổ tài nguyên (Reservation & Resource Allocation)

Nhiếp ảnh gia:
1. Chọn không gian sáng tạo, khoảng thời gian, thiết bị, dịch vụ bổ sung
2. **Hệ thống tự động kiểm tra** khả dụng của TẤT CẢ tài nguyên cần thiết
3. **Phát hiện tự động** xung đột lịch
4. Khi phê duyệt → **Khóa tất cả tài nguyên liên quan** trong khoảng thời gian đã chọn
5. Cập nhật lịch của mỗi tài nguyên

#### D. Quản lý phiên sử dụng (Service Session Management)

Trong khoảng thời gian đặt chỗ:
- Khách check-in sử dụng thông tin đặt chỗ hoặc mã QR
- Hệ thống ghi nhận:
  - Thời lượng sử dụng thực tế (actual usage duration)
  - Thiết bị được phân bổ (allocated equipment)
  - Dịch vụ bổ sung sử dụng (additional services consumed)
  - Trạng thái thanh toán (checkout status)
- Dữ liệu này dùng cho:
  - Tính toán hóa đơn (billing)
  - Đánh giá dịch vụ (service evaluation)
  - Theo dõi thiết bị (equipment tracking)
  - Xử lý tranh chấp (dispute resolution)

#### E. Quản lý gói dịch vụ (Service Package Management)

Nhà cung cấp dịch vụ kết hợp:
- Không gian sáng tạo
- Thiết bị
- Tài nguyên tiêu hao
- Huấn luyện viên (instructor)
- Dịch vụ hỗ trợ

Thành các **gói dịch vụ linh hoạt** cho các hoạt động như:
- Chụp ảnh chân dung (portrait photography)
- Chụp sản phẩm (product photography)
- Phát triển phim (film developing)
- In ấn phòng tối (darkroom printing)
- Workshop giáo dục (educational workshops)

Nền tảng **tự động xác thực** khả dụng tài nguyên trước khi cho phép khách đặt gói hoàn chỉnh.

### 2.3. Các nhóm đối tượng chính (System Roles)

#### 1. Photographer (Nhiếp ảnh gia / Khách hàng)

**Mô tả:** Những người đặt chỗ không gian sáng tạo và tài nguyên hỗ trợ cho hoạt động nhiếp ảnh.

**Nhiệm vụ chính:**
- Quản lý hồ sơ cá nhân
- Tìm kiếm và so sánh phòng tối/studio
- Xem thông tin chi tiết về không gian sáng tạo
- Đặt chỗ không gian và thiết bị
- Mua hoặc tùy chỉnh gói dịch vụ
- Thanh toán trực tuyến
- Xem lịch sử đặt chỗ
- Quản lý bộ sưu tập ảnh kỹ thuật số
- Đánh giá và xếp hạng (reviews & ratings)
- Tham gia hoạt động cộng đồng và workshop

#### 2. Service Provider (Nhà cung cấp dịch vụ)

**Mô tả:** Cá nhân hoặc tổ chức sở hữu/vận hành phòng tối, phòng chụp, kho thiết bị hoặc cơ sở sáng tạo.

**Nhiệm vụ chính:**
- Quản lý hồ sơ kinh doanh
- Quản lý phòng tối và phòng chụp ảnh
- Cấu hình thông số phòng và khả dụng
- Quản lý thiết bị và tài nguyên tiêu hao
- Tạo và quản lý gói dịch vụ
- Cấu hình chính sách giá cả và chiến dịch khuyến mãi
- Xử lý yêu cầu đặt chỗ
- Phân bổ tài nguyên cho đặt chỗ xác nhận
- Theo dõi tỷ lệ sử dụng không gian và thiết bị
- Lập lịch bảo trì thiết bị
- Phân tích doanh thu và kết quả kinh doanh thông qua dashboard

#### 3. Photography Expert (Chuyên gia nhiếp ảnh)

**Mô tả:** Những chuyên gia đóng góp kiến thức chuyên môn cho nền tảng.

**Nhiệm vụ chính:**
- Xuất bản bài viết giáo dục
- Tổ chức workshop và session huấn luyện
- Đánh giá thiết bị nhiếp ảnh
- Chia sẻ kỹ thuật phòng tối và best practices
- Xây dựng kho kiến thức cộng đồng

#### 4. Administrator (Quản trị viên)

**Mô tả:** Quản lý các hoạt động nền tảng và đảm bảo độ tin cậy hệ thống.

**Nhiệm vụ chính:**
- Quản lý người dùng và nhà cung cấp dịch vụ
- Phê duyệt đăng ký nhà cung cấp
- Quản lý danh mục và nội dung nền tảng
- Theo dõi giao dịch và thanh toán
- Xử lý tranh chấp và khiếu nại (complaints)
- Quản lý dịch vụ AI và cấu hình nền tảng
- Tạo báo cáo toàn hệ thống

#### 5. AI Assistant (Trợ lý AI) — [Out of Scope của project thiết kế CSDL này]

**Mô tả:** Hỗ trợ thông minh cho khách hàng và nhà cung cấp dịch vụ.

**Nhiệm vụ chính:**
- Đề xuất không gian sáng tạo phù hợp
- Gợi ý thiết bị và gói dịch vụ
- Khôi phục và nâng cao hình ảnh kỹ thuật số
- Trả lời câu hỏi liên quan đến nhiếp ảnh
- Hỗ trợ tìm kiếm ngữ nghĩa (semantic search) trong kho kiến thức

---

## III. FUNCTIONAL REQUIREMENTS — YÊU CẦU CHỨC NĂNG

### 3.1. Core Business Flows — Các luồng nghiệp vụ cốt lõi

#### CORE FLOW 1: Quản lý không gian sáng tạo (Creative Space Management)

**Business Rule:**
- Mỗi Service Provider có thể sở hữu và quản lý **một hoặc nhiều** không gian sáng tạo
- Mỗi không gian phải có **thông tin chi tiết đầy đủ**
- Không gian phải có **lịch khả dụng rõ ràng**

**Dữ liệu cần quản lý:**
- Thông tin cơ bản (tên, mô tả, địa chỉ)
- Thông số kỹ thuật (kích thước, sức chứa, phong cách, điều kiện ánh sáng)
- Tiện nghi khả dụng (amenities)
- Giờ hoạt động (operating hours)
- Chính sách sử dụng (usage policies)
- Mô hình giá cả (pricing models)
- Hình ảnh và tài liệu
- Lịch khả dụng real-time

**Khía cạnh CSDL:**
- Entity: `creative_spaces` (không gian sáng tạo)
- Relationship: `Service Provider` 1:N `Creative Space`
- Constraint: Mỗi không gian phải thuộc đúng một nhà cung cấp

---

#### CORE FLOW 2: Quản lý thiết bị và tài nguyên (Resource & Equipment Management)

**Business Rule:**
- Mỗi không gian sáng tạo có thể **sở hữu hoặc cho thuê nhiều thiết bị**
- Mỗi thiết bị có **vòng đời quản lý riêng** (khả dụng, bảo trì, tình trạng)
- Tài nguyên tiêu hao cần **theo dõi hàng tồn kho** (inventory)

**Dữ liệu cần quản lý:**
- Danh mục thiết bị (tên, loại, mô tả)
- Trạng thái khả dụng (available, maintenance, retired)
- Giá cho thuê / giá bán
- Lịch bảo trì
- Tình trạng vật lý
- Tương thích với gói dịch vụ
- Lịch sử sử dụng và maintenance
- Tồn kho vật liệu tiêu hao

**Khía cạnh CSDL:**
- Entity: `equipment`, `resources`, `consumables`
- Relationship: `Creative Space` 1:N `Equipment`
- Constraint: Theo dõi availability status, maintenance schedule

---

#### CORE FLOW 3: Đặt chỗ và phân bổ tài nguyên (Reservation & Resource Allocation)

**Business Rule:**
- Một Photographer có thể **tạo nhiều Booking**
- Một Booking **thuộc về đúng một Photographer**
- Một Booking **lựa chọn đúng một Creative Space**
- Một Booking có thể **sử dụng nhiều Equipment/Resource**
- Một Equipment có thể **được sử dụng trong nhiều Booking** (khác nhau trong thời gian)
- **Hệ thống tự động kiểm tra xung đột lịch** trước khi xác nhận

**Dữ liệu cần quản lý:**
- Thông tin đặt chỗ (ngày, giờ, booking status)
- Không gian được đặt
- Danh sách tài nguyên
- Thông tin khách hàng
- Chi phí tính toán

**Khía cạnh CSDL:**
- Entity: `bookings`, `booking_details`, `booking_resources`
- Relationship: `Photographer` 1:N `Booking`
- Relationship: `Booking` 1:N `Booking_Resource` N:1 `Resource`
- Relationship: `Booking` N:1 `Creative_Space`
- Constraint: Kiểm tra availability trước insert booking

---

#### CORE FLOW 4: Quản lý phiên sử dụng (Service Session Management)

**Business Rule:**
- Mỗi Booking xác nhận → Tạo **một Service Session**
- Khi check-in → Ghi nhận **thời gian bắt đầu, tài nguyên phân bổ**
- Khi check-out → Ghi nhận **thời gian kết thúc, dịch vụ bổ sung đã sử dụng**
- Dữ liệu này dùng cho **hóa đơn, đánh giá, theo dõi**

**Dữ liệu cần quản lý:**
- Thời gian check-in/check-out
- Tài nguyên phân bổ
- Dịch vụ bổ sung
- Trạng thái (pending, in-session, completed)
- Chi phí phát sinh

**Khía cạnh CSDL:**
- Entity: `service_sessions`
- Relationship: `Booking` 1:1 `Service_Session`
- Constraint: Ghi nhận audit trail, không cho phép chỉnh sửa sau khi completed

---

#### CORE FLOW 5: Quản lý gói dịch vụ (Service Package Management)

**Business Rule:**
- Mỗi Service Provider có thể **tạo nhiều Service Package**
- Mỗi Service Package **bao gồm nhiều thành phần:**
  - Không gian sáng tạo
  - Thiết bị
  - Vật liệu tiêu hao
  - Huấn luyện viên / chuyên gia
  - Dịch vụ bổ sung
- Mỗi package có **giá cố định hoặc có thể tùy chỉnh**
- Nền tảng phải **xác thực khả dụng tất cả thành phần** trước khi cho phép đặt gói

**Dữ liệu cần quản lý:**
- Tên gói, mô tả
- Danh sách thành phần (not gian, thiết bị, tài nguyên)
- Giá cơ bản, tùy chỉnh có thể
- Mô tả cho từng loại hoạt động
- Hình ảnh, tài liệu

**Khía cạnh CSDL:**
- Entity: `service_packages`, `package_details`
- Relationship: `Service_Provider` 1:N `Service_Package`
- Relationship: `Service_Package` N:M `Equipment`
- Relationship: `Service_Package` N:M `Creative_Space` (nếu 1 package có nhiều không gian)

---

### 3.2. Secondary Flows — Luồng phụ

#### SECONDARY FLOW 1: Thanh toán (Payment)

**Business Rule:**
- Một Booking có **một Payment record**
- Payment được tính từ:
  - Giá cơ sở của không gian
  - Chi phí thiết bị bổ sung
  - Chi phí dịch vụ bổ sung
  - Khuyến mãi / discount (nếu có)

**Dữ liệu cần quản lý:**
- Số tiền thanh toán
- Phương thức thanh toán
- Trạng thái (pending, completed, failed, refunded)
- Ngày thanh toán
- Chi tiết chi phí

**Khía cạnh CSDL:**
- Entity: `payments`
- Relationship: `Booking` 1:1 `Payment`
- Constraint: Không cho phép đặt chỗ nếu payment không hoàn tất

---

#### SECONDARY FLOW 2: Đánh giá và xếp hạng (Reviews & Ratings)

**Business Rule:**
- Một Photographer sau khi check-out có thể **viết review về:**
  - Creative Space
  - Equipment condition
  - Service quality
- Một review bao gồm:
  - Rating (1-5 sao)
  - Bình luận (comment)
  - Hình ảnh (optional)

**Dữ liệu cần quản lý:**
- Rating value
- Comment text
- Review date
- Reviewer (Photographer)
- Target (Space/Equipment)

**Khía cạnh CSDL:**
- Entity: `reviews`
- Relationship: `Photographer` 1:N `Review`
- Relationship: `Creative_Space` 1:N `Review`
- Relationship: `Equipment` 1:N `Review`

---

#### SECONDARY FLOW 3: Bảo trì thiết bị (Maintenance)

**Business Rule:**
- Mỗi Equipment có **lịch bảo trì định kỳ**
- Khi bảo trì → Equipment **không khả dụng**
- Bảo trì có thể **thường xuyên hoặc khi cần**

**Dữ liệu cần quản lý:**
- Loại bảo trì (routine, repair, overhaul)
- Ngày dự kiến / thực tế
- Trạng thái (scheduled, in-progress, completed)
- Mô tả công việc
- Chi phí

**Khía cạnh CSDL:**
- Entity: `maintenance_schedules`
- Relationship: `Equipment` 1:N `Maintenance_Schedule`
- Constraint: Equipment không được phân bổ khi bảo trì

---

#### SECONDARY FLOW 4: Cộng đồng & Workshop (Community & Workshops)

**Business Rule:**
- Photography Expert có thể **tạo Workshop**
- Mỗi Workshop có **thông tin chi tiết** (ngày, giờ, địa điểm, nội dung, giá)
- Photographer có thể **đăng ký Workshop**

**Dữ liệu cần quản lý:**
- Tiêu đề, mô tả workshop
- Ngày giờ, địa điểm
- Giảng viên / chuyên gia
- Sức chứa tối đa
- Giá
- Danh sách người đăng ký
- Bình luận, hình ảnh

**Khía cạnh CSDL:**
- Entity: `workshops`, `workshop_registrations`
- Relationship: `Photography_Expert` 1:N `Workshop`
- Relationship: `Photographer` N:M `Workshop` (via workshop_registrations)

---

## IV. DATABASE DESIGN REQUIREMENTS — YÊU CẦU THIẾT KẾ CSDL

### 4.1. Thiết kế mô hình dữ liệu

**Phạm vi thiết kế:**

1. ✓ **Phân tích yêu cầu** → Xác định entity chính
2. ✓ **Thiết kế ERD/EERD** → Biểu diễn entity & relationship
3. ✓ **Chuẩn hóa** → Phân tích functional dependency, 1NF→2NF→3NF
4. ✓ **Relational Model** → Mapping từ EERD sang relational
5. ✓ **Thiết kế SQL Schema** → Tạo tables, columns, constraints
6. ✓ **DDL Scripts** → `CREATE TABLE`, `CREATE CONSTRAINT`, `CREATE INDEX`
7. ✓ **Seed Data** → Dữ liệu mẫu minh họa
8. ✓ **Documentation** → Data Dictionary, design rationale

### 4.2. Công nghệ bắt buộc

- **DBMS:** Microsoft SQL Server
- **Naming Convention:** snake_case (tables, columns)
- **Encoding:** Unicode (hỗ trợ tiếng Việt)
- **Constraint:** PK, FK, NOT NULL, UNIQUE, CHECK, DEFAULT
- **Indexing:** Strategy cho query patterns chính

### 4.3. Non-Functional Requirements

| Yêu cầu | Mô tả |
|--------|-------|
| **Tính nhất quán** | Dữ liệu phải nhất quán qua tất cả thao tác |
| **Toàn vẹn dữ liệu** | FK, PK, constraint phải bảo vệ dữ liệu |
| **Scalability** | Schema phải hỗ trợ mở rộng số lượng records |
| **Performance** | Index phù hợp pattern truy vấn chính |
| **Maintainability** | Thiết kế rõ ràng, tài liệu đầy đủ |
| **Security** | Không lưu sensitive data trong plain text |

---

## V. DELIVERABLES — SẢN PHẨM DỰ KIẾN

### 5.1. Tài liệu thiết kế

| # | Tên file | Mô tả | Định dạng |
|---|---------|-------|----------|
| 1 | `Business_Analysis.md` | Phân tích yêu cầu, business rules, use cases | Markdown |
| 2 | `ERD.md` hoặc `ERD.drawio` | Biểu đồ entity-relationship | Markdown/Draw.io |
| 3 | `Relational_Model.md` | Mapping EERD → relational | Markdown |
| 4 | `Normalization_Analysis.md` | Phân tích FD, 1NF→2NF→3NF | Markdown |
| 5 | `SQL_Schema.md` | Thông tin chi tiết mỗi table, column, constraint | Markdown |
| 6 | `Data_Dictionary.md` | Danh sách tất cả tables, columns, data types | Markdown |

### 5.2. SQL Scripts

| # | Tên file | Mô tả |
|---|---------|-------|
| 1 | `01_create_database.sql` | Tạo database |
| 2 | `02_create_schema.sql` | Tạo schema |
| 3 | `03_create_tables.sql` | Tạo tables |
| 4 | `04_create_constraints.sql` | Tạo PRIMARY KEY, FOREIGN KEY, CHECK, etc. |
| 5 | `05_create_indexes.sql` | Tạo indexes |
| 6 | `06_seed_data.sql` | Dữ liệu mẫu (test data) |

### 5.3. Documentation

- **Design Rationale:** Giải thích vì sao mỗi entity/relationship/constraint được tạo
- **Assumptions:** Ghi chú các giả định được xác nhận từ Human
- **Open Issues:** Các vấn đề chưa được giải quyết

---

## VI. ACCEPTANCE CRITERIA — TIÊU CHÍ CHẤP NHẬN

### 6.1. Requirement Coverage

- [ ] Tất cả 5 core flows được biểu diễn trong CSDL
- [ ] Tất cả secondary flows được xử lý
- [ ] Tất cả business rules được thể hiện qua constraint/relationship
- [ ] Không có business rule được giả định mà chưa được xác nhận

### 6.2. Design Quality

- [ ] ERD/EERD logic đúng (không có circular dependency, không có missing entity)
- [ ] Relational model mapping đúng (tất cả entity/attribute được mapping)
- [ ] Normalization phân tích kỹ (FD xác định, chuẩn hóa đến 3NF tối thiểu)
- [ ] PK/FK định nghĩa đúng (không orphan records, không missing relationships)
- [ ] Constraint đầy đủ (NOT NULL, UNIQUE, CHECK, DEFAULT rõ ràng)

### 6.3. SQL Implementation

- [ ] SQL Server syntax đúng (xác minh bằng cách chạy script)
- [ ] Dependency order hợp lý (tạo database → schema → tables → constraints → indexes)
- [ ] Data type phù hợp (VARCHAR vs NVARCHAR, INT vs BIGINT, etc.)
- [ ] Nullability logic đúng (dựa trên business rule)
- [ ] Seed data consistent (không vi phạm constraint, không orphan)

### 6.4. Documentation Quality

- [ ] Tài liệu nhất quán với implementation (không mâu thuẫn)
- [ ] Mỗi entity/table/column có giải thích (what & why)
- [ ] Traceability rõ ràng (requirement → business rule → entity → table)
- [ ] Assumptions, open issues ghi chú đầy đủ
- [ ] Naming convention nhất quán

### 6.5. Reviewability

- [ ] Sẵn sàng để Human review (tài liệu đầy đủ)
- [ ] Không có vùng tối (unclear design decision)
- [ ] Có plan rõ ràng cho các thay đổi tương lai

---

## VII. ASSUMPTIONS & CONSTRAINTS — GIẢ ĐỊNH & HẠNG CHẾ

### 7.1. Assumptions (Giả định được xác nhận)

- ✓ Platform dùng SQL Server (không MySQL, PostgreSQL)
- ✓ Scope chỉ là Database Design (không triển khai application)
- ✓ Photographer & Service Provider là 2 nhóm riêng (không overlap)
- ✓ Một đặt chỗ sử dụng đúng một không gian sáng tạo
- ✓ Hệ thống kiểm tra xung đột tài nguyên trước xác nhận
- ✓ Payment là bắt buộc trước khi xác nhận booking

### 7.2. Constraints (Hạn chế)

- ❌ Không triển khai AI (recommendation, image restoration)
- ❌ Không triển khai REST API
- ❌ Không triển khai UI/UX
- ❌ Không triển khai payment gateway thực tế
- ❌ Không triển khai authentication/authorization ở application level
- ✓ Database chỉ cần credential cơ bản (username, password lưu riêng)

---

## VIII. SUCCESS METRICS — TIÊU CHÍ THÀNH CÔNG

### 8.1. Functional Success

- ✓ CSDL có thể lưu trữ tất cả dữ liệu cần thiết
- ✓ Tất cả constraints bảo vệ toàn vẹn dữ liệu
- ✓ Queries chính được hỗ trợ hiệu quả bằng indexes
- ✓ Không có redundant data (chuẩn hóa 3NF)

### 8.2. Documentation Success

- ✓ Human có thể hiểu design từ tài liệu
- ✓ Các quyết định được giải thích rõ (không "why?")
- ✓ Future developer có thể mở rộng schema với dễ dàng

### 8.3. Process Success

- ✓ Tất cả quyết định được xác nhận từ Human
- ✓ Không có "hidden assumptions"
- ✓ Không có vùng tối trong thiết kế

---

## IX. COMMUNICATION & APPROVAL PLAN

### 9.1. Checkpoint chính

| Phase | Milestone | Approval |
|-------|-----------|----------|
| 1 | Business Analysis + Actor/Use Case | Human review |
| 2 | ERD/EERD initial | Human approval |
| 3 | Relational Model + Normalization | Human approval |
| 4 | SQL Schema draft | Human review |
| 5 | SQL Scripts + Seed Data | Human approval |
| 6 | Final Documentation | Human sign-off |

### 9.2. Review questions

Tại mỗi checkpoint, xác nhận:
1. "Thiết kế này đáp ứng requirement chưa?"
2. "Có business rule nào bị quên không?"
3. "Có vấn đề gì cần sửa không?"
4. "Có câu hỏi hoặc thắc mắc không?"

---

## REFERENCES — THAM KHẢO

- **Microsoft SQL Server Documentation:** https://docs.microsoft.com/en-us/sql/
- **Normalization Theory:** [Academic textbook]
- **Database Design Best Practices:** [Industry standards]
- **Project Domain Knowledge:** Film Photography community context

---

**Version:** 1.0  
**Status:** Active  
**Last Updated:** 2026-08-14  
**Created By:** Team 7

