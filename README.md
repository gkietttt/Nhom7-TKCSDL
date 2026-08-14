# NỀN TẢNG KẾT NỐI CỘNG ĐỒNG NHIẾP ẢNH PHIM

**Thiết kế Cơ sở Dữ liệu (Database Design)**  
**Platform Connecting the Film Photography Community with Darkroom and Studio Services**

---

## 📋 Mục lục

- [Mô tả Project](#mô-tả-project)
- [Cấu trúc Thư mục](#cấu-trúc-thư-mục)
- [Clone Repository](#clone-repository)
- [Tài liệu Dự án](#tài-liệu-dự-án)
- [Hướng dẫn làm việc](#hướng-dẫn-làm-việc)

---

## 📖 Mô tả Project

Đây là project **thiết kế cơ sở dữ liệu (Database Design - CSDL)** cho nền tảng:
- **Photographers** (Nhiếp ảnh gia) tìm kiếm dịch vụ phòng tối, phòng chụp
- **Service Providers** (Nhà cung cấp dịch vụ) quản lý tài nguyên, thiết bị
- **Community Features** (Tính năng cộng đồng) - các dịch vụ hỗ trợ khác

### Phạm vi & Công nghệ

| Thành phần | Chi tiết |
|-----------|---------|
| **DBMS** | Microsoft SQL Server |
| **Cấp độ thiết kế** | CSDL (Conceptual Database Design) |
| **Bao gồm** | Requirement Analysis, ER Diagram, Relational Model, Normalization, SQL Scripts |
| **Không bao gồm** | Application UI/UX, REST API, Deployment |

---

## 📁 Cấu trúc Thư mục

```
Nhom7-TKCSDL/
│
├── README.md                    # Tài liệu này
├── Working_Rule.md              # Quy tắc thiết kế bắt buộc (29 nguyên tắc)
│
└── doc/                         # Tài liệu thiết kế
    ├── Task.md                  # Yêu cầu project (English)
    ├── plan_doc.md              # Kế hoạch công việc
```

---

## 🚀 Clone Repository

### Bước 1: Clone Repository

```bash
# Dùng HTTPS
git clone https://github.com/gkietttt/Nhom7-TKCSDL.git

# Hoặc dùng SSH
git git@github.com:gkietttt/Nhom7-TKCSDL.git
```

### Bước 2: Tạo Branch làm việc

```bash
# Tạo branch mới cho công việc của bạn
git checkout -b feature/your-task-name

# Ví dụ:
git checkout -b feature/erd-design
git checkout -b feature/normalization
```

### Bước 3: Cập nhật từ Remote

```bash
# Lấy cập nhật từ remote
git fetch origin

# Merge vào branch hiện tại
git merge origin/main
```

---

## 📚 Tài liệu Dự án

| File | Mô tả |
|------|-------|
| **Working_Rule.md** | 29 nguyên tắc thiết kế bắt buộc cho toàn bộ team |
| **doc/Task.md** | Yêu cầu chi tiết project (Entity, Relationship, Business Rules) |
| **doc/plan_doc.md** | Kế hoạch công việc & Timeline |

### Cách đọc tài liệu

1. **Bắt đầu với:** `Working_Rule.md` — Hiểu quy tắc làm việc
2. **Sau đó:** `doc/Task.md` — Hiểu yêu cầu project & business flows
3. **Cuối cùng:** `doc/plan_doc.md` — Xem kế hoạch công việc

---

## 🔧 Hướng dẫn làm việc

### Quy trình Design

**Sequence (Bắt buộc):**
```
1. Requirement Analysis  (Phân tích yêu cầu)
2. Actor & UseCase       (Nhân vật & Kịch bản)
3. Entity & Attribute    (Thực thể & Thuộc tính)
4. Relationship          (Mối quan hệ)
5. ER Diagram (EERD)     (Sơ đồ ER)
6. Relational Model      (Mô hình quan hệ)
7. Normalization (1NF→2NF→3NF)
8. SQL Scripts           (Mã SQL)
9. Data Dictionary       (Danh sách chi tiết)
10. Documentation        (Tài liệu)
```

**Tham khảo:** Working_Rule.md - Section "Design Workflow"

### Chuẩn đặt tên (Naming Convention)

- **Tables:** `photographer`, `creative_space`, `booking` (snake_case)
- **Columns:** `photographer_id`, `created_at` (snake_case)
- **Constraints:** `PK_photographer`, `FK_booking_photographer` (UPPERCASE_prefix)
- **Indexes:** `idx_booking_status`, `idx_photographer_email`

**Tham khảo:** Working_Rule.md - Section "Naming Convention"

### Chuẩn Hoá Dữ liệu (Normalization)

- **1NF:** Loại bỏ Repeating Groups
- **2NF:** Loại bỏ Partial Dependencies
- **3NF:** Loại bỏ Transitive Dependencies

**Tham khảo:** Working_Rule.md - Section "Normalization Rules"

### Kiểu Dữ liệu & Constraint

| Kiểu | Mô tả | Ví dụ |
|-----|-------|-------|
| **INT** | Integer | photographer_id |
| **NVARCHAR(n)** | Unicode text | photographer_name |
| **DECIMAL(10,2)** | Decimal | price |
| **DATETIME2** | Timestamp | created_at |
| **BIT** | Boolean | is_active |

**Constraints:** PK (Primary Key), FK (Foreign Key), NOT NULL, UNIQUE, DEFAULT, CHECK

### Commit & Push

```bash
# Thêm file
git add <file_or_folder>

# Commit
git commit -m "feat: add ERD for photographer entity"

# Push
git push origin feature/erd-design
```

---

## ✅ Danh sách Kiểm tra (Checklist)

**Trước khi bắt đầu:**
- [ ] Clone repository
- [ ] Đọc Working_Rule.md
- [ ] Đọc doc/Task.md
- [ ] Kiểm tra doc/plan_doc.md để biết deadline

**Khi làm việc:**
- [ ] Tuân theo Design Workflow (10 bước)
- [ ] Tuân theo Naming Convention
- [ ] Áp dụng Normalization Rules
- [ ] Thêm Comments trong SQL scripts
- [ ] Kiểm tra Constraint & Data Types

**Trước khi commit:**
- [ ] Kiểm tra lại yêu cầu (Task.md)
- [ ] Kiểm tra lại quy tắc (Working_Rule.md)
- [ ] Viết commit message rõ ràng
- [ ] Push lên remote
