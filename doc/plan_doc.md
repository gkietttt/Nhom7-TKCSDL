# PLAN NHÓM -- THIẾT KẾ CƠ SỞ DỮ LIỆU

## Đề tài

**Nền tảng kết nối cộng đồng nhiếp ảnh phim với các dịch vụ phòng tối và
phòng chụp**

**English:** Platform Connecting the Film Photography Community with
Darkroom and Studio Services

------------------------------------------------------------------------

## 1. Mục tiêu của nhóm

Thiết kế một hệ thống cơ sở dữ liệu phục vụ nền tảng kết nối:

-   Người chụp ảnh phim (Photographer)
-   Nhà cung cấp dịch vụ (Service Provider)
-   Chuyên gia nhiếp ảnh (Photography Expert)
-   Quản trị viên (Administrator)

Hệ thống tập trung vào việc quản lý:

-   Không gian chụp ảnh và phòng tối
-   Thiết bị và tài nguyên
-   Đặt chỗ và phân bổ tài nguyên
-   Gói dịch vụ
-   Thanh toán
-   Quá trình sử dụng dịch vụ
-   Bảo trì thiết bị
-   Đánh giá
-   Cộng đồng và workshop

> **Phạm vi của môn:** tập trung vào phân tích và thiết kế cơ sở dữ
> liệu. Không yêu cầu nhóm lập trình ứng dụng thực tế.

------------------------------------------------------------------------

# 2. Nguyên tắc làm bài

Nhóm thực hiện theo thứ tự:

**Hiểu đề → Phân tích nghiệp vụ → Actor/Use Case → Entity → Relationship
→ EER → Mô hình quan hệ → Chuẩn hóa → Ràng buộc → Hoàn thiện tài liệu**

Không thiết kế bảng ngay từ đầu.

Không đi sâu vào: - Flutter - React/Next.js - ASP.NET/Node.js - API -
Cloud - AI implementation - Thanh toán thực tế

Các nội dung trên chỉ được dùng để hiểu **hệ thống tương lai cần dữ liệu
gì**.

------------------------------------------------------------------------

# 3. Giai đoạn 1 -- Hiểu đề và xác định phạm vi

## Mục tiêu

Cả nhóm phải hiểu thống nhất hệ thống trước khi bắt đầu thiết kế.

## Công việc

-   Đọc toàn bộ đề.
-   Xác định vấn đề hệ thống giải quyết.
-   Xác định các đối tượng tham gia.
-   Xác định các nghiệp vụ chính.
-   Xác định dữ liệu mà mỗi nghiệp vụ cần quản lý.

## Kết quả cần có

### Actor

1.  Photographer
2.  Service Provider
3.  Photography Expert
4.  Administrator
5.  AI Assistant (chỉ xem như chức năng hệ thống, không nhất thiết là
    thực thể người dùng)

### Nhóm nghiệp vụ chính

1.  Quản lý người dùng
2.  Quản lý Service Provider
3.  Quản lý Creative Space
4.  Quản lý Equipment
5.  Quản lý Consumable
6.  Quản lý Reservation
7.  Quản lý Resource Allocation
8.  Quản lý Service Session
9.  Quản lý Service Package
10. Quản lý Payment
11. Quản lý Maintenance
12. Quản lý Review
13. Quản lý Community
14. Quản lý Workshop

------------------------------------------------------------------------

# 4. Giai đoạn 2 -- Xác định Use Case

## Mục tiêu

Xác định hệ thống phải cung cấp những chức năng gì cho từng Actor.

## Photographer

-   Đăng ký / đăng nhập
-   Quản lý hồ sơ cá nhân
-   Tìm kiếm Creative Space
-   Xem thông tin Creative Space
-   Tìm kiếm Equipment
-   Xem Service Package
-   Đặt Creative Space
-   Đặt Equipment
-   Đặt Service Package
-   Thanh toán
-   Xem lịch sử Reservation
-   Check-in / Check-out
-   Đánh giá dịch vụ
-   Đăng bài / bình luận
-   Đăng ký Workshop
-   Quản lý bộ sưu tập ảnh

## Service Provider

-   Quản lý hồ sơ doanh nghiệp
-   Quản lý Creative Space
-   Quản lý Equipment
-   Quản lý Consumable
-   Quản lý Service Package
-   Quản lý giá
-   Quản lý Reservation
-   Phân bổ Resource
-   Quản lý Maintenance
-   Theo dõi tình trạng Resource
-   Theo dõi lịch sử sử dụng
-   Theo dõi doanh thu

## Photography Expert

-   Quản lý hồ sơ chuyên gia
-   Đăng Article
-   Đăng Tutorial
-   Review Equipment
-   Chia sẻ kỹ thuật
-   Tạo Workshop
-   Quản lý Workshop

## Administrator

-   Quản lý User
-   Quản lý Provider
-   Duyệt Provider
-   Quản lý Category
-   Quản lý Community Content
-   Theo dõi Payment
-   Xử lý Complaint / Dispute
-   Quản lý hệ thống

## Kết quả cần có

-   Use Case Diagram tổng quát
-   Danh sách Use Case
-   Actor -- Use Case mapping
-   Mô tả ngắn các Use Case quan trọng

------------------------------------------------------------------------

# 5. Giai đoạn 3 -- Phân tích nghiệp vụ

## Mục tiêu

Mô tả hệ thống hoạt động như thế nào trong thực tế.

## Core Flow 1 -- Creative Space Management

Provider tạo và quản lý Studio / Darkroom.

Thông tin cần quản lý có thể gồm:

-   Tên
-   Loại không gian
-   Mô tả
-   Diện tích
-   Sức chứa
-   Phong cách
-   Điều kiện ánh sáng
-   Thông gió
-   Âm học
-   Tiện ích
-   Giờ hoạt động
-   Giá
-   Chính sách sử dụng
-   Hình ảnh
-   Trạng thái

## Core Flow 2 -- Resource & Equipment Management

Provider quản lý:

-   Camera
-   Lens
-   Film Scanner
-   Enlarger
-   Lighting
-   Tripod
-   Background
-   Darkroom Equipment
-   Chemical
-   Photographic Paper

Mỗi Resource có thể cần:

-   Tình trạng
-   Trạng thái
-   Giá thuê
-   Lịch bảo trì
-   Lịch sử sử dụng

## Core Flow 3 -- Reservation & Resource Allocation

Photographer:

**Tìm → Chọn → Kiểm tra lịch → Đặt → Thanh toán**

Hệ thống phải kiểm tra:

-   Phòng có trống không?
-   Thiết bị có trống không?
-   Resource có đang bảo trì không?
-   Có bị trùng lịch không?

## Core Flow 4 -- Service Session

**Check-in → Sử dụng → Phát sinh dịch vụ/tài nguyên → Check-out**

Ghi nhận:

-   Thời gian thực tế
-   Equipment được sử dụng
-   Consumable đã sử dụng
-   Dịch vụ phát sinh
-   Trạng thái Check-out

## Core Flow 5 -- Service Package

Provider tạo combo:

**Creative Space + Equipment + Consumable + Service / Instructor**

Ví dụ:

> Darkroom Beginner Package

gồm:

-   Darkroom
-   Enlarger
-   Chemical
-   Photographic Paper
-   Instructor

## Core Flow 6 -- Community

Quản lý:

-   Article
-   Tutorial
-   Equipment Review
-   Discussion
-   Comment
-   Workshop
-   Workshop Registration

------------------------------------------------------------------------

# 6. Giai đoạn 4 -- Xác định Entity

## Mục tiêu

Từ nghiệp vụ, tìm ra các đối tượng cần lưu trữ trong CSDL.

## Entity dự kiến

### Nhóm User

-   User
-   Role
-   UserRole
-   Photographer
-   ServiceProvider
-   PhotographyExpert
-   Administrator

### Nhóm Creative Space

-   CreativeSpace
-   SpaceType
-   SpaceImage
-   Amenity
-   OperatingHour
-   SpacePricing

### Nhóm Resource

-   Equipment
-   EquipmentCategory
-   Consumable
-   Maintenance
-   ResourceUsage

### Nhóm Reservation

-   Reservation
-   ReservationEquipment
-   ReservationConsumable
-   ResourceAllocation
-   ServiceSession

### Nhóm Service Package

-   ServicePackage
-   PackageSpace
-   PackageEquipment
-   PackageConsumable
-   PackageService

### Nhóm Payment

-   Payment
-   PaymentTransaction

### Nhóm Community

-   Article
-   Category
-   Comment
-   Review
-   Workshop
-   WorkshopRegistration

> Danh sách trên là danh sách dự kiến. Không được coi đây là danh sách
> bảng cuối cùng. Nhóm phải kiểm tra lại sau khi phân tích Cardinality
> và chuẩn hóa.

------------------------------------------------------------------------

# 7. Giai đoạn 5 -- Xác định thuộc tính

Với từng Entity, xác định:

-   Tên thuộc tính
-   Kiểu dữ liệu dự kiến
-   Thuộc tính bắt buộc
-   Thuộc tính tùy chọn
-   Thuộc tính đa trị
-   Thuộc tính dẫn xuất
-   Khóa chính
-   Khóa ngoại nếu có

Ví dụ:

## CreativeSpace

-   space_id
-   provider_id
-   space_type_id
-   name
-   description
-   capacity
-   area
-   style
-   lighting_condition
-   ventilation
-   acoustic
-   status

## Reservation

-   reservation_id
-   photographer_id
-   space_id
-   start_time
-   end_time
-   status
-   total_amount
-   created_at

------------------------------------------------------------------------

# 8. Giai đoạn 6 -- Xác định Relationship

## Mục tiêu

Xác định các Entity liên hệ với nhau như thế nào.

Các quan hệ dự kiến:

-   Provider **sở hữu** CreativeSpace
-   Provider **quản lý** Equipment
-   Provider **quản lý** Consumable
-   Equipment **thuộc** EquipmentCategory
-   Equipment **có** Maintenance
-   Photographer **tạo** Reservation
-   Reservation **đặt** CreativeSpace
-   Reservation **sử dụng** Equipment
-   Reservation **sử dụng** Consumable
-   Reservation **có** Payment
-   Reservation **tạo ra** ServiceSession
-   Provider **tạo** ServicePackage
-   ServicePackage **bao gồm** CreativeSpace
-   ServicePackage **bao gồm** Equipment
-   ServicePackage **bao gồm** Consumable
-   Photographer **viết** Review
-   Expert **tạo** Article
-   Expert **tổ chức** Workshop
-   Photographer **đăng ký** Workshop

Sau đó xác định Cardinality:

-   1:1
-   1:N
-   N:M

------------------------------------------------------------------------

# 9. Giai đoạn 7 -- EER Diagram

## Mục tiêu

Xây dựng mô hình EER hoàn chỉnh.

Nhóm cần xem xét:

### Tổng quát hóa / chuyên biệt hóa

Ví dụ có thể xem xét:

``` text
USER
├── Photographer
├── ServiceProvider
├── PhotographyExpert
└── Administrator
```

Hoặc:

``` text
RESOURCE
├── Equipment
└── Consumable
```

Nhưng chỉ sử dụng Generalization / Specialization khi thực sự phù hợp
với nghiệp vụ.

## Kết quả

-   EER Diagram
-   Cardinality
-   Participation
-   Primary Key
-   Các specialization/generalization nếu có

------------------------------------------------------------------------

# 10. Giai đoạn 8 -- Chuyển sang mô hình quan hệ

Từ EER chuyển thành các Relation.

Ví dụ:

``` text
USER(
    user_id PK,
    full_name,
    email,
    phone,
    ...
)
```

``` text
CREATIVE_SPACE(
    space_id PK,
    provider_id FK,
    space_type_id FK,
    name,
    capacity,
    ...
)
```

Đối với quan hệ N:M, tạo Relation trung gian.

Ví dụ:

``` text
RESERVATION_EQUIPMENT(
    reservation_id PK, FK,
    equipment_id PK, FK,
    quantity,
    rental_price
)
```

------------------------------------------------------------------------

# 11. Giai đoạn 9 -- Chuẩn hóa

Kiểm tra các Relation theo:

-   1NF
-   2NF
-   3NF

Mục tiêu:

-   Không lặp dữ liệu.
-   Không có phụ thuộc bộ phận.
-   Không có phụ thuộc bắc cầu.
-   Giảm dư thừa dữ liệu.
-   Hạn chế anomaly khi Insert / Update / Delete.

Không chuẩn hóa máy móc. Chỉ ra lý do tại sao Relation đạt chuẩn.

------------------------------------------------------------------------

# 12. Giai đoạn 10 -- Ràng buộc dữ liệu

Xác định:

### Entity Integrity

-   PK không NULL.
-   PK duy nhất.

### Referential Integrity

-   FK phải tham chiếu đến bản ghi hợp lệ.

### Domain Constraint

Ví dụ:

-   rating từ 1 đến 5.
-   capacity \> 0.
-   price \>= 0.
-   start_time \< end_time.

### Business Constraint

Ví dụ:

> Một Equipment không được được phân bổ cho hai Reservation bị trùng
> thời gian.

> Một Creative Space không được có hai Reservation trùng thời gian.

> Equipment ở trạng thái Maintenance không được phân bổ cho Reservation.

Đây là các ràng buộc nghiệp vụ quan trọng của đề.

------------------------------------------------------------------------

# 13. Giai đoạn 11 -- Kiểm tra mô hình

Nhóm dùng các tình huống thực tế để kiểm tra CSDL.

## Case 1

Photographer đặt:

> Darkroom A\
> 14:00--17:00\
> Enlarger 01

→ Hệ thống phải lưu được.

## Case 2

Người khác muốn đặt:

> Darkroom A\
> 15:00--16:00

→ Phải phát hiện trùng lịch.

## Case 3

Photographer đặt:

> Studio A + Camera 01 + Lens 01

→ Phải quản lý được tất cả Resource liên quan.

## Case 4

Camera 01 đang Maintenance.

→ Không được phân bổ cho Reservation.

## Case 5

Provider tạo Package gồm:

> Studio + Camera + Lens + Consumable.

→ Database phải biểu diễn được Package và các thành phần.

## Case 6

Photographer hoàn thành Reservation.

→ Có thể tạo Review.

## Case 7

Expert tạo Workshop.

→ Photographer có thể đăng ký Workshop.

------------------------------------------------------------------------

# 14. Giai đoạn 12 -- Hoàn thiện báo cáo

Cấu trúc báo cáo đề xuất:

## Chương 1 -- Tổng quan đề tài

-   Bối cảnh
-   Vấn đề
-   Mục tiêu
-   Phạm vi
-   Đối tượng sử dụng

## Chương 2 -- Phân tích yêu cầu

-   Actor
-   Use Case
-   Functional Requirements
-   Core Flows
-   Business Rules

## Chương 3 -- Phân tích và thiết kế dữ liệu

-   Xác định Entity
-   Thuộc tính
-   Relationship
-   Cardinality
-   EER Diagram
-   Generalization / Specialization

## Chương 4 -- Thiết kế mô hình quan hệ

-   Danh sách Relation
-   PK
-   FK
-   Constraints
-   Mapping EER → Relational Model

## Chương 5 -- Chuẩn hóa

-   1NF
-   2NF
-   3NF
-   Giải thích kết quả

## Chương 6 -- Đánh giá

-   Kiểm tra các nghiệp vụ
-   Kiểm tra tính toàn vẹn
-   Khả năng mở rộng
-   Hạn chế của mô hình

------------------------------------------------------------------------

# 15. Phân công nhóm đề xuất

  Thành viên     Phụ trách
  -------------- ---------------------------------------------------------
  Thành viên 1   Phân tích yêu cầu + Actor + Use Case
  Thành viên 2   Phân tích User + Provider + Creative Space
  Thành viên 3   Phân tích Equipment + Consumable + Maintenance
  Thành viên 4   Phân tích Reservation + Resource Allocation + Payment
  Thành viên 5   Phân tích Package + Community + Workshop + Review
  Cả nhóm        EER, mô hình quan hệ, chuẩn hóa, kiểm tra và hoàn thiện

Nếu nhóm ít/người nhiều hơn thì chia lại theo từng module.

------------------------------------------------------------------------

# 16. Tiến độ đề xuất

## Phase 1 -- Hiểu đề

**Mục tiêu:** thống nhất phạm vi và nghiệp vụ.

Deliverable: - Actor - Core Flow - Danh sách nghiệp vụ

## Phase 2 -- Use Case

**Mục tiêu:** xác định chức năng hệ thống.

Deliverable: - Use Case Diagram - Use Case list

## Phase 3 -- Entity

**Mục tiêu:** xác định dữ liệu cần lưu.

Deliverable: - Entity list - Attribute list

## Phase 4 -- Relationship

**Mục tiêu:** xác định mối quan hệ.

Deliverable: - Relationship - Cardinality - Participation

## Phase 5 -- EER

**Mục tiêu:** hoàn thành mô hình khái niệm.

Deliverable: - EER Diagram

## Phase 6 -- Relational Model

**Mục tiêu:** chuyển sang mô hình quan hệ.

Deliverable: - Relation schemas - PK/FK

## Phase 7 -- Normalization

**Mục tiêu:** kiểm tra và chuẩn hóa.

Deliverable: - 1NF - 2NF - 3NF

## Phase 8 -- Final Review

**Mục tiêu:** kiểm tra toàn bộ hệ thống.

Deliverable: - ER/EER hoàn chỉnh - Relational Schema hoàn chỉnh -
Business Constraints - Báo cáo hoàn chỉnh

------------------------------------------------------------------------

# 17. Checklist cuối cùng

-   [ ] Hiểu rõ đề tài
-   [ ] Xác định Actor
-   [ ] Xác định Use Case
-   [ ] Xác định Core Flow
-   [ ] Xác định Business Rules
-   [ ] Xác định Entity
-   [ ] Xác định Attribute
-   [ ] Xác định PK
-   [ ] Xác định Relationship
-   [ ] Xác định Cardinality
-   [ ] Xem xét Generalization / Specialization
-   [ ] Hoàn thành EER Diagram
-   [ ] Chuyển sang Relational Model
-   [ ] Xác định FK
-   [ ] Chuẩn hóa đến 3NF
-   [ ] Xác định Constraint
-   [ ] Kiểm tra các Case nghiệp vụ
-   [ ] Hoàn thiện báo cáo

------------------------------------------------------------------------

# 18. Thứ tự nhóm nên làm ngay bây giờ

**Không làm tất cả cùng lúc.**

Thứ tự nên là:

``` text
1. Hiểu đề
      ↓
2. Actor
      ↓
3. Use Case
      ↓
4. Mô tả nghiệp vụ
      ↓
5. Entity
      ↓
6. Attribute
      ↓
7. Relationship + Cardinality
      ↓
8. EER
      ↓
9. Relational Model
      ↓
10. Normalization
      ↓
11. Constraint
      ↓
12. Kiểm tra + Báo cáo
```

