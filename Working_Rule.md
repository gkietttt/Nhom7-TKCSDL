# WORKING RULE — DATABASE DESIGN PROJECT

**Phạm vi:** Phân tích và thiết kế CSDL (Database Design)  
**Công nghệ:** Microsoft SQL Server  
**Không bao gồm:** Phát triển ứng dụng (Application), UI/UX, deployment

---

## PROJECT: NỀN TẢNG KẾT NỐI CỘNG ĐỒNG NHIẾP ẢNH PHIM VỚI DỊCH VỤ PHÒNG TỐI VÀ PHÒNG CHỤP

| Thuộc tính | Giá trị |
|-----------|--------|
| **Tiếng Anh** | Platform Connecting the Film Photography Community with Darkroom and Studio Services |
| **Tiếng Việt** | Nền tảng kết nối cộng đồng nhiếp ảnh phim với các dịch vụ phòng tối và phòng chụp |

---

## 1. PURPOSE — MỤC ĐÍCH

Tài liệu này quy định bộ nguyên tắc làm việc bắt buộc cho project thiết kế cơ sở dữ liệu.

### Nội dung thiết kế bao gồm:

- Phân tích yêu cầu dữ liệu
- Phân tích nghiệp vụ (Business Analysis)
- Xác định Actor / Use Case
- Xác định Entity
- Xác định Attribute
- Xác định Relationship
- Thiết kế ERD (Entity Relationship Diagram)
- Thiết kế EERD (Enhanced Entity Relationship Diagram)
- Phân tích Functional Dependency
- Chuẩn hóa dữ liệu (Normalization): 1NF → 2NF → 3NF
- Xác định Primary Key / Foreign Key
- Xác định Constraint
- Chọn Data Type phù hợp SQL Server
- Thiết kế Index strategy
- Thiết kế Schema
- Tạo SQL scripts (DDL / DML)
- Tạo Seed data khi cần
- Lập tài liệu thiết kế

### Ưu tiên chất lượng:

```
Tính chính xác (Correctness)
        ↓
Toàn vẹn dữ liệu (Data Integrity)
        ↓
Đáp ứng requirement (Requirement)
        ↓
Tính nhất quán (Consistency)
        ↓
Khả năng bảo trì (Maintainability)
        ↓
Khả năng kiểm chứng (Reviewability)
```

**Mục tiêu không phải tạo output nhanh nhất**, mà tạo ra thiết kế:
- ✓ Đúng requirement
- ✓ Có reasoning rõ ràng
- ✓ Nhất quán giữa các mô hình
- ✓ Có thể kiểm tra và xác minh
- ✓ Có thể giải thích từng quyết định
- ✓ Có thể triển khai trên SQL Server
- ✓ Không tạo giả định nghiệp vụ không được xác nhận

---

## 2. CORE PRINCIPLE — NGUYÊN TẮC CỐT LÕI

### Quy trình bắt buộc:

```
Clarify First           (Làm rõ yêu cầu)
      ↓
Confirm Understanding   (Xác nhận hiểu biết)
      ↓
Analyze Deeply          (Phân tích sâu)
      ↓
Plan Before Implementation  (Lập kế hoạch)
      ↓
Human Review & Approval (Xem xét & phê duyệt)
      ↓
Execution               (Thực hiện)
      ↓
Validation              (Kiểm chứng)
      ↓
Documentation           (Tài liệu hóa)
      ↓
Evaluation              (Đánh giá)
```

### Nguyên tắc không được:

❌ Bắt đầu thiết kế Database chỉ vì thấy giải pháp "hợp lý"

❌ Tự suy đoán business rule quan trọng

❌ Bỏ qua clarification vì nghĩ rằng hiểu rồi

### Trước khi thực hiện phải trả lời 5 câu hỏi:

1. **Đang làm gì?** (What)
2. **Làm cho hệ thống nào?** (Which system)
3. **Để giải quyết nghiệp vụ nào?** (Which business)
4. **Dữ liệu nào cần được quản lý?** (Which data)
5. **Kết quả phải phục vụ mục tiêu gì?** (What goal)

**Nếu chưa rõ một trong 5 câu hỏi:**

> **STOP & ASK** — Không được tự quyết định!

---

## 3. PROJECT SCOPE — PHẠM VI PROJECT

### 3.1. Domain

**Nền tảng kết nối cộng đồng nhiếp ảnh phim với dịch vụ phòng tối và phòng chụp**

#### Nhóm đối tượng chính:
- Photographer (Nhiếp ảnh gia)
- Service Provider (Nhà cung cấp dịch vụ)
- Photography Expert (Chuyên gia nhiếp ảnh)
- Administrator (Quản trị viên)

#### Nhóm nghiệp vụ dữ liệu chính:
- Không gian chụp ảnh / Phòng tối
- Thiết bị (Equipment)
- Tài nguyên (Resource)
- Đặt chỗ (Booking / Reservation)
- Phân bổ tài nguyên (Resource Allocation)
- Gói dịch vụ (Service Package)
- Thanh toán (Payment)
- Sử dụng dịch vụ (Service Session)
- Bảo trì thiết bị (Maintenance)
- Đánh giá (Review / Rating)
- Cộng đồng (Community)
- Workshop / Training

### 3.2. Out of Scope — Không bao gồm

Project **KHÔNG** tập trung triển khai:

- ❌ Flutter, React, Next.js, ASP.NET, Node.js (Front-end / Back-end)
- ❌ REST API
- ❌ Cloud deployment (Azure, AWS, GCP)
- ❌ AI implementation (Machine Learning, NLP)
- ❌ Payment gateway thực tế
- ❌ Application authentication / authorization
- ❌ Application deployment

Các công nghệ trên chỉ được nhắc đến khi cần trả lời:

> **"Ứng dụng tương lai cần dữ liệu gì từ Database này?"**

**Nguyên tắc:** Implementation của application **không được** chi phối Database Design nếu requirement học phần không yêu cầu.

---

## 4. DOCUMENT PRIORITY — THỨ TỰ ƯU TIÊN NGUỒN TÀI LIỆU

Khi có nhiều nguồn thông tin mâu thuẫn, ưu tiên theo thứ tự:

```
1. Requirement chính thức của project
        ↓
2. Project Documentation nội bộ
        ↓
3. Quyết định của Human (đã được xác nhận)
        ↓
4. Microsoft SQL Server Official Documentation
        ↓
5. Tài liệu học thuật / Giáo trình Database
        ↓
6. Web Research
        ↓
7. General Knowledge
```

### Xử lý mâu thuẫn:

Nếu nguồn nội bộ mâu thuẫn với kiến thức bên ngoài:
- ❌ Không tự ý sửa project
- ✓ Giữ requirement / design hiện tại
- ✓ Nêu rõ mâu thuẫn
- ✓ Đề xuất Human xác nhận nếu cần thay đổi

---

## 5. DESIGN WORKFLOW — QUY TRÌNH THIẾT KẾ

### 5.1. Thứ tự bắt buộc:

```
Hiểu đề (Understand requirement)
   ↓
Phân tích nghiệp vụ (Business analysis)
   ↓
Xác định Actor / Use Case (Identify actors & use cases)
   ↓
Xác định Entity (Identify entities)
   ↓
Xác định Attribute (Identify attributes)
   ↓
Xác định Relationship (Identify relationships)
   ↓
Thiết kế ERD / EERD (Design ERD/EERD)
   ↓
Chuyển sang Relational Model (Convert to relational model)
   ↓
Phân tích Functional Dependency (Analyze FD)
   ↓
Chuẩn hóa (Normalization: 1NF→2NF→3NF)
   ↓
Xác định Constraint (Define constraints)
   ↓
Triển khai SQL Server (Implement on SQL Server)
   ↓
Tài liệu hóa (Document)
```

### 5.2. Nguyên tắc:

❌ **Không được:** "Thấy nghiệp vụ → tạo table ngay"

✓ **Mỗi Table phải có lý do rõ ràng:**
- Lý do nghiệp vụ (Business reason)
- hoặc lý do kỹ thuật (Technical reason)

---

## 6. INFORMATION CLASSIFICATION — PHÂN LOẠI THÔNG TIN

AI phải phân biệt rõ 3 trạng thái:

### Confirmed (Xác nhận)

Thông tin đã có từ:
- Requirement chính thức
- Documentation
- Human decision
- Design đã được approve

### Assumption (Giả định)

Thông tin mà AI tự suy luận từ context

### Proposed (Đề xuất)

Giải pháp mà AI đề xuất nhưng chưa được Human xác nhận

### Quy tắc quan trọng:

❌ **KHÔNG được** chuyển `Assumption` → `Confirmed Requirement`

✓ **Nếu business rule chưa rõ:** Hỏi Human, không quyết định một mình

**Ví dụ:**
> "Một Photographer có được đặt nhiều dịch vụ cùng thời điểm không?"

❌ **KHÔNG tự quyết định** nếu requirement chưa xác định  
✓ **HỎI:** Để Human xác nhận business rule này

---

## 7. ENTITY RULES — QUYẾT TẮC ĐỊNH NGHĨA ENTITY

### Tiêu chí Entity hợp lệ:

Một Entity phải thoả mãn TẤT CẢ điều kiện:

1. ✓ Entity tồn tại trong domain / nghiệp vụ
2. ✓ Entity có dữ liệu cần lưu trữ
3. ✓ Entity có identity riêng (có thể nhận diện duy nhất)
4. ✓ Entity có relationship với Entity khác hoặc là root entity
5. ✓ Entity có ý nghĩa độc lập

### Không được tạo Entity nếu:

❌ Muốn schema "đẹp" hoặc "chuẩn"
❌ Muốn có nhiều table
❌ Copy từ mẫu database khác
❌ AI nghĩ rằng "database chuẩn phải có"
❌ Không có requirement rõ ràng

### Kiểm tra Entity:

Với mỗi entity dự định tạo, trả lời:
- "Entity này đại diện khái niệm nào trong đề bài?"
- "Cần lưu trữ dữ liệu gì cho entity này?"
- "Entity này có thể tồn tại độc lập không?"
- "Requirement yêu cầu entity này không?"

---

## 8. ATTRIBUTE RULES — QUYẾT TẮC ĐỊNH NGHĨA ATTRIBUTE

### Mỗi Attribute phải trả lời:

> **"Attribute này mô tả khía cạnh nào của Entity?"**

### Tiêu chí Attribute:

- ✓ **Atomicity** — Giá trị không thể chia nhỏ thêm
- ✓ **Data type phù hợp** — Đúng loại dữ liệu
- ✓ **Optional/Mandatory clear** — Rõ có bắt buộc hay không
- ✓ **Domain value xác định** — Giá trị hợp lệ rõ ràng
- ✓ **Functional dependency phân tích** — Quan hệ phụ thuộc với PK
- ✓ **Không trùng lặp** — Không lặp lại thông tin
- ✓ **Đáp ứng requirement** — Requirement yêu cầu

### Không được tạo column:

❌ Để lưu thông tin không có requirement
❌ Để "dự trữ cho tương lai"
❌ Với data type mập mờ (ví dụ: `VARCHAR(MAX)` cho tất cả)

---

## 9. RELATIONSHIP RULES — QUYẾT TẮC ĐỊNH NGHĨA QUAN HỆ

### Phải phân biệt 3 loại relationship:

#### 1:1 (One-to-One)

Một record A tương ứng tối đa một record B và ngược lại.

```
Photographer
     |
     | 1:1
     |
Profile
```

#### 1:N (One-to-Many)

Một A có nhiều B. Foreign Key nằm ở phía N.

```
Photographer
     |
     | 1:N
     |
Booking
```

#### N:M (Many-to-Many)

Một A có nhiều B và một B có nhiều A.  
**Không biểu diễn trực tiếp N:M trong relational schema.**  
Phải tạo **associative/junction table**.

```
Booking
     |
     | N
     |
Booking_Resource  (Junction table)
     |
     | N
     |
Resource
```

### Phân tích Relationship:

Trước khi xác định relationship, phải xác định **business rule**:

**Ví dụ business rules:**
- "Một Photographer có thể tạo nhiều Booking"
- "Một Booking thuộc về đúng một Photographer"
- "Một Booking có thể sử dụng nhiều Resource"
- "Một Resource có thể được sử dụng trong nhiều Booking"

Sau đó mới xác định cardinality (1:1, 1:N, N:M).

---

## 10. PRIMARY KEY RULES — QUYẾT TẮC KHÓA CHÍNH

### Mỗi table phải xác định Primary Key:

Phải phân tích:
- **Candidate Key** — Các key có khả năng
- **Natural Key** — Key từ domain (ví dụ: email, username)
- **Surrogate Key** — Key nhân tạo (ví dụ: IDENTITY)
- **Composite Key** — Key ghép từ nhiều column

### Không được:

❌ Mặc định mọi table có `id INT IDENTITY` mà không phân tích

❌ Quên unique constraint nếu natural key tồn tại

### Nếu sử dụng Surrogate Key:

1. Phải kiểm tra natural uniqueness
2. Thêm UNIQUE constraint nếu natural key tồn tại

**Ví dụ:**
```sql
PRIMARY KEY (user_id)            -- Surrogate
UNIQUE (email)                   -- Natural uniqueness
```

---

## 11. FOREIGN KEY RULES — QUYẾT TẮC KHÓA NGOÀI

### Foreign Key phải phản ánh relationship trong ERD:

Kiểm tra từng FK:

1. ✓ FK thuộc table nào? (Referencing table)
2. ✓ Reference table nào? (Referenced table)
3. ✓ Reference column nào?
4. ✓ Cardinality có đúng không?
5. ✓ Optionality có đúng không?
6. ✓ Delete behavior (ON DELETE) có phù hợp không?
7. ✓ Có thể tạo orphan record không?

### Không được:

❌ Tạo FK chỉ vì hai column có tên giống nhau

❌ Quên kiểm tra dependency khi xóa dữ liệu

**Ví dụ ON DELETE options:**
- `ON DELETE CASCADE` — Xóa parent → xóa child
- `ON DELETE SET NULL` — Xóa parent → FK thành NULL
- `ON DELETE RESTRICT` — Không cho xóa nếu có child
- `ON DELETE NO ACTION` — Hành động mặc định (tuỳ DBMS)

---

## 12. NORMALIZATION RULES — QUYẾT TẮC CHUẨN HÓA

### Chuẩn hóa phải dựa trên Functional Dependency (FD):

```
Functional Dependency Analysis
        ↓
1st Normal Form (1NF) — Atomic values
        ↓
2nd Normal Form (2NF) — No partial dependency
        ↓
3rd Normal Form (3NF) — No transitive dependency
```

### 1NF — First Normal Form:

Kiểm tra:
- ✓ Tất cả giá trị atomic (không chia nhỏ được)
- ✓ Không có repeating groups
- ✓ Không lưu nhiều giá trị trong một cell

### 2NF — Second Normal Form:

Kiểm tra:
- ✓ Đã đạt 1NF
- ✓ Không có partial dependency trên phần của composite key

**Partial dependency:** Non-key attribute phụ thuộc vào một phần của composite key.

### 3NF — Third Normal Form:

Kiểm tra:
- ✓ Đã đạt 2NF
- ✓ Không có transitive dependency giữa non-key attributes

**Transitive dependency:** Non-key A phụ thuộc vào non-key B, B phụ thuộc vào PK.

### Quy tắc:

❌ Không nói: "Table này chuẩn hóa vì nhìn gọn"

✓ Phải phân tích FD trước khi kết luận mức chuẩn hóa

❌ Không tự mở rộng thành BCNF/4NF/5NF nếu requirement không yêu cầu

---

## 13. DATA TYPE RULES — KIỂU DỮ LIỆU SQL SERVER

**Database dùng: Microsoft SQL Server**

### Kiểu dữ liệu phổ biến:

| Loại | Kiểu | Ý định |
|------|------|--------|
| Integer | `INT`, `BIGINT` | Số nguyên |
| Decimal | `DECIMAL(p,s)`, `NUMERIC(p,s)` | Số thập phân có độ chính xác |
| Float | `FLOAT`, `REAL` | Số thực (xấp xỉ) |
| Bit | `BIT` | Boolean (0/1) |
| String | `CHAR`, `VARCHAR` | Chuỗi ASCII |
| Unicode | `NCHAR`, `NVARCHAR` | Chuỗi Unicode (tiếng Việt, ...) |
| Date/Time | `DATE`, `TIME`, `DATETIME2` | Ngày/giờ |

### Quy tắc lựa chọn:

- ✓ Ưu tiên `NVARCHAR` khi cần lưu Unicode (tiếng Việt)
- ❌ Không mặc định tất cả text thành `NVARCHAR(MAX)`
- ❌ Không sử dụng data type của MySQL/PostgreSQL
- ✓ Xác định độ dài hợp lý (ví dụ: `VARCHAR(100)` cho tên)

---

## 14. CONSTRAINT RULES — QUYẾT TẮC TÀI NGUYÊN CÓ HẠN CHẾ

### Toàn vẹn dữ liệu phải được bảo vệ ở Database level:

**Constraint cơ bản:**

```sql
PRIMARY KEY (column)           -- Khóa chính
FOREIGN KEY → REFERENCES       -- Khóa ngoài
NOT NULL                       -- Bắt buộc có giá trị
UNIQUE (column)                -- Giá trị duy nhất
CHECK (condition)              -- Kiểm tra điều kiện
DEFAULT (value)                -- Giá trị mặc định
```

### Ví dụ:

```sql
CONSTRAINT PK_User
PRIMARY KEY (user_id)

CONSTRAINT FK_Booking_Photographer
FOREIGN KEY (photographer_id)
REFERENCES photographers(photographer_id)

CONSTRAINT CK_Booking_Status
CHECK (status IN ('PENDING', 'CONFIRMED', 'CANCELLED'))

CONSTRAINT UQ_Email
UNIQUE (email)

CONSTRAINT DF_CreatedAt
DEFAULT GETDATE()
```

### Nguyên tắc:

❌ Không chỉ dựa vào application để bảo vệ dữ liệu

✓ Database phải có constraint để prevent invalid data

---

## 15. NULLABILITY RULES — QUYẾT TẮC CHO PHÉP NULL

### Không được mặc định:

❌ Mọi column là `NULL`
❌ Mọi column là `NOT NULL`

### Phải dựa trên business rule:

**Câu hỏi quyết định:**

> "Nếu không có giá trị này, record có hợp lệ không?"

- **Không hợp lệ** → `NOT NULL`
- **Hợp lệ** → `NULL`

### Ví dụ:

| Attribute | Quyết định | Lý do |
|-----------|-----------|-------|
| `user_id` | `NOT NULL` | Mỗi booking phải có photographer |
| `notes` | `NULL` | Ghi chú không bắt buộc |
| `email` | `NOT NULL` | Cần liên hệ với user |
| `phone` | `NULL` | User có thể chỉ có email |

---

## 16. INDEX RULES — QUYẾT TẮC CHỈ MỤC

### Index phục vụ query performance:

**Không tạo index cho mọi column.**

### Trước khi tạo Index:

- ✓ Phân tích pattern truy vấn
- ✓ Xem xét WHERE, JOIN, ORDER BY, GROUP BY
- ✓ Kiểm tra cardinality (độ phân biệt)
- ✓ Cân nhắc read vs write workload
- ✓ Không lạp chỉ mục

### Index phải có rationale (lý do):

```
Index: IX_Booking_Photographer

Reason: Photographer frequently query their bookings
Query: SELECT * FROM bookings 
       WHERE photographer_id = ?
```

---

## 17. NAMING CONVENTION — QUYẾT TẮC ĐẶT TÊN

### Nếu project đã có convention:

✓ **Follow convention hiện tại**

### Nếu chưa có convention được xác nhận:

✓ Đề xuất convention nhất quán trước khi áp dụng

### Khuyến nghị:

#### Table

```
snake_case
photographers
service_providers
bookings
booking_resources
creative_spaces
equipment
```

#### Column

```
snake_case
photographer_id
created_at
booking_status
service_provider_id
```

#### Primary Key

```
PK_<table>
PK_photographers
PK_bookings
```

#### Foreign Key

```
FK_<child_table>_<parent_table>
FK_bookings_photographers
FK_booking_resources_resources
```

#### Unique Constraint

```
UQ_<table>_<column>
UQ_photographers_email
```

#### Check Constraint

```
CK_<table>_<column>
CK_bookings_status
```

#### Default Constraint

```
DF_<table>_<column>
DF_bookings_created_at
```

#### Index

```
IX_<table>_<column>
IX_bookings_photographer_id
```

### Quy tắc:

❌ Không tự đổi naming convention của object đã được Human xác nhận

---

## 18. SQL SCRIPT RULES — QUYẾT TẮC TẠO SQL SCRIPTS

### Dependency order bắt buộc:

```
scripts/
│
├── 01_create_database.sql
├── 02_create_schema.sql
├── 03_create_tables.sql
├── 04_create_constraints.sql
├── 05_create_indexes.sql
└── 06_seed_data.sql
```

**Thứ tự:**
```
Database
   ↓
Schema
   ↓
Tables (Tạo tables trước, sau đó tạo FK)
   ↓
Constraints (PK, FK, CHECK, DEFAULT, UNIQUE)
   ↓
Indexes
   ↓
Seed Data
```

### Không được:

❌ Tạo FK trước table
❌ Tạo Index trước table
❌ Seed data trước khi table được tạo
❌ Tạo destructive operations (.e.g DROP, TRUNCATE) trong scripts khác

---

## 19. SQL SAFETY — AN TOÀN SQL

### Cẩn thận đặc biệt với:

```sql
DROP DATABASE      -- Xóa cơ sở dữ liệu
DROP TABLE         -- Xóa bảng
TRUNCATE TABLE     -- Xóa tất cả hàng
DELETE             -- Xóa có điều kiện
ALTER TABLE        -- Thay đổi cấu trúc
```

### Quy tắc:

❌ **KHÔNG tự ý** thực hiện destructive operation

✓ Nếu task yêu cầu:
1. Xác định object bị ảnh hưởng
2. Xác định dữ liệu bị ảnh hưởng
3. Xác định dependency
4. Nêu risk rõ ràng
5. Chờ Human approval trước khi thực hiện

---

## 20. DATABASE SCHEMA STABILITY — TÍNH ỔN ĐỊNH SCHEMA

### Sau khi ERD/Relational Model/SQL Schema được Human xác nhận:

> ✓ **Được tuân theo**  
> ❌ **KHÔNG được tự ý thay đổi**

### Không được tự ý:

❌ Rename table  
❌ Rename column  
❌ Đổi Primary Key  
❌ Đổi Foreign Key / relationship  
❌ Đổi cardinality  
❌ Đổi Data Type  
❌ Xóa Constraint  
❌ Thêm Entity  
❌ Xóa Entity  

### Chỉ thay đổi khi:

✓ Human yêu cầu rõ ràng
✓ Requirement thay đổi (được xác nhận)
✓ Có lỗi design được chứng minh
✓ Đã phân tích impact đầy đủ
✓ Có implementation plan rõ ràng

---

## 21. DOCUMENTATION CONSISTENCY — TÍNH NHẤT QUÁN TÀI LIỆU

### Tài liệu phải nhất quán:

```
Requirement
    ↕
Use Case / Business Rules
    ↕
ERD / EERD
    ↕
Relational Model
    ↕
Normalization Analysis
    ↕
SQL Schema
    ↕
Documentation / Data Dictionary
```

### Kiểm tra nhất quán:

- Nếu Table tồn tại trong SQL nhưng **không có** trong design documentation
  → **Phải kiểm tra!**

- Nếu Entity tồn tại trong ERD nhưng **không có** trong Relational Model
  → **Phải kiểm tra!**

- Nếu Column trong SQL **khác** documentation
  → **Xác định source of truth trước khi sửa!**

---

## 22. DESIGN TRACEABILITY — KHẢ NĂNG TRUY NGƯỢC THIẾT KẾ

### Mỗi thành phần quan trọng phải truy ngược được:

```
Requirement
    ↓
Business Rule
    ↓
Use Case
    ↓
Entity / Relationship
    ↓
Attribute
    ↓
Table / Column / Constraint
    ↓
SQL Implementation
```

### Ví dụ:

```
Requirement:
"Photographer có thể tạo nhiều Booking"
    ↓
Business Rule:
Photographer 1:N Booking
    ↓
Entity Relationship:
Photographer — (1:N) — Booking
    ↓
Relational Model:
Table: bookings
Column: photographer_id (FK)
    ↓
SQL Constraint:
FK_bookings_photographers
```

### Quy tắc:

❌ Không được biến một table/column/relationship thành "tự nhiên" xuất hiện

✓ **Phải có reasoning:** "Tại sao cần entity/table/column này?"

Nếu **không giải thích được** vì sao tồn tại:
→ **Phải review lại design!**

---

## 23. IMPLEMENTATION PLAN — KẾ HOẠCH TRIỂN KHAI

### Trước khi sửa bất kỳ file quan trọng nào:

**Phải lập implementation plan** với tối thiểu 10 phần:

1. **Objective** — Mục tiêu
2. **Files Impacted** — File ảnh hưởng
3. **Current Design** — Thiết kế hiện tại
4. **Planned Changes** — Thay đổi dự kiến
5. **Business Reason** — Lý do kinh doanh
6. **Technical Reason** — Lý do kỹ thuật
7. **Impact Analysis** — Phân tích tác động
8. **Risk Assessment** — Đánh giá rủi ro
9. **Alternatives** — Phương án thay thế
10. **Validation Plan** — Kế hoạch kiểm chứng
11. **Rollback Plan** — Kế hoạch quay lại

### Template:

```markdown
## Implementation Plan

### Objective
[Mục tiêu làm gì]

### Files Impacted
- docs/erd.md
- docs/relational-model.md
- scripts/03_create_tables.sql

### Current Design
[Thiết kế hiện tại]

### Planned Changes
[Thay đổi dự kiến]

### Reason
- Business: [Lý do kinh doanh]
- Technical: [Lý do kỹ thuật]

### Impact
[Ảnh hưởng đến những gì]

### Risk
[Rủi ro tiềm ẩn]

### Alternatives
[Phương án khác]

### Validation
- [ ] Kiểm tra ERD
- [ ] Kiểm tra FK dependency
- [ ] Kiểm tra normalization
- [ ] Kiểm tra SQL syntax
- [ ] Kiểm tra seed data order

### Approval Required
Human phải xác nhận trước khi implementation
```

---

## 24. STABLE DESIGN PROTECTION — BẢO VỆ THIẾT KẾ ỔN ĐỊNH

### Tuyệt đối KHÔNG tự ý sửa:

❌ ERD stable
❌ EERD stable
❌ Relational Model stable
❌ Normalization đã được xác nhận
❌ SQL schema đã được xác nhận
❌ Documentation stable
❌ SQL scripts stable
❌ Naming Convention stable

### Quy tắc:

**Nếu task hiện tại không liên quan trực tiếp:**
→ **KHÔNG sửa**

**Nếu phát hiện vấn đề ngoài scope:**
→ **Báo cáo, không tự sửa**

---

## 25. VALIDATION RULES — QUYẾT TẮC KIỂM CHỨNG

### Mỗi thay đổi Database Design phải được validation:

#### Requirement Validation
- ✓ Có đáp ứng requirement không?
- ✓ Có thiếu nghiệp vụ không?
- ✓ Có thêm nghiệp vụ chưa được yêu cầu không?

#### ERD Validation
- ✓ Entity có chính xác không?
- ✓ Attribute có đầy đủ không?
- ✓ Relationship có đúng không?
- ✓ Cardinality có chính xác không?
- ✓ PK/FK định nghĩa đúng không?

#### Relational Model Validation
- ✓ Table mapping từ Entity có đúng không?
- ✓ PK mapping chính xác không?
- ✓ FK mapping chính xác không?
- ✓ Junction table cho N:M có đầy đủ không?
- ✓ Attribute mapping có đầy đủ không?

#### Normalization Validation
- ✓ 1NF: Atomic values?
- ✓ 2NF: Partial dependency?
- ✓ 3NF: Transitive dependency?
- ✓ Functional Dependency analysis?

#### SQL Validation
- ✓ SQL Server syntax đúng không?
- ✓ Table dependency order đúng không?
- ✓ Constraint dependency đúng không?
- ✓ Data type phù hợp không?
- ✓ Nullability đúng không?
- ✓ Seed data order có hợp lý không?

---

## 26. SECURITY RULES — QUYẾT TẮC AN NINH

### KHÔNG được đưa vào Git:

❌ SQL Server password
❌ Database credentials
❌ Connection secrets
❌ API keys
❌ Sensitive personal data

### Sử dụng `.env` file:

```env
DB_SERVER=localhost
DB_PORT=1433
DB_NAME=FilmPhotographyDB
DB_USER=sa
DB_PASSWORD=your_password
```

### Bắt buộc có:

```
.env              → Local only (KHÔNG commit)
.env.example      → Template (CÓ commit)
.gitignore        → Exclude files
```

### Quy tắc:

❌ Không hardcode credential thật trong SQL script
❌ Không hardcode credential trong documentation
✓ Sử dụng environment variable hoặc config file

---

## 27. RESEARCH RULES — QUYẾT TẮC NGHIÊN CỨU

### Ưu tiên nguồn:

```
Project Documentation
        ↓
Microsoft SQL Server Official Docs
        ↓
Academic Database Sources
        ↓
Trusted Technical Sources
        ↓
Web Search
```

### Quy tắc:

❌ Research lan man
✓ Research phục vụ **trực tiếp** cho task

❌ Chọn "best practice" chỉ vì nó được đề cập nhiều
✓ Giải thích: "Best practice này phù hợp với project hiện tại không?"

Nếu tìm thấy nhiều giải pháp:
1. So sánh
2. Nêu trade-off
3. Chọn phương án phù hợp requirement

---

## 28. COMMUNICATION RULES — QUYẾT TẮC GIAO TIẾP

### Ngôn ngữ chính:

**Tiếng Việt**

### Technical terms giữ nguyên English:

```
Entity, Attribute, Relationship
Primary Key, Foreign Key, Candidate Key
Functional Dependency
Normalization (1NF, 2NF, 3NF)
Constraint, Index, Schema, Table, View
ERD, EERD
Relational Model
DDL (Data Definition Language)
DML (Data Manipulation Language)
SQL Server
```

### Giao tiếp hiệu quả:

❌ Không dùng lời mở đầu sáo rỗng:
- "Great question"
- "Sure"
- "Of course"
- "Happy to help"

✓ **Đi thẳng vào nội dung**

❌ Không giải thích dài hơn yêu cầu nếu Human chỉ cần câu trả lời ngắn

✓ Khi được hỏi "Tại sao?":
→ **Trả lời chi tiết, có reasoning**

---

## 29. FINAL CHECKLIST — DANH SÁCH KIỂM TRA CUỐI CÙNG

Trước khi submit bất kỳ deliverable nào:

### Requirement Check
- [ ] Tất cả requirement đã được address?
- [ ] Không có assumption chưa xác nhận?
- [ ] Business rule rõ ràng?

### Design Check
- [ ] ERD/EERD logic đúng?
- [ ] Relational model mapping đúng?
- [ ] Normalization phân tích kỹ?
- [ ] PK/FK định nghĩa đúng?
- [ ] Constraint đầy đủ?

### SQL Check
- [ ] Syntax đúng SQL Server?
- [ ] Dependency order hợp lý?
- [ ] Nullability logic đúng?
- [ ] Data type phù hợp?
- [ ] Seed data consistent?

### Documentation Check
- [ ] Tài liệu nhất quán với implementation?
- [ ] Có reasoning cho mỗi quyết định quan trọng?
- [ ] Traceability từ requirement đến SQL?
- [ ] Naming convention nhất quán?

### Review Ready
- [ ] Sẵn sàng để Human review?
- [ ] Tất cả file được commit đúng?
- [ ] Changelog/notes được cập nhật?

---

## REFERENCES — THAM KHẢO

- **Microsoft SQL Server Documentation**: https://docs.microsoft.com/en-us/sql/
- **Database Design Fundamentals**: [Textbook References]
- **Normalization Theory**: [Academic Sources]
- **Project Requirements**: [Project Documentation]

---

**Document Version:** 1.0  
**Last Updated:** 2026-08-14  
**Status:** Active

