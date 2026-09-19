# HƯỚNG DẪN CẤU HÌNH VÀ VẬN HÀNH DOCKER SQL SERVER 2022

**Dự án:** Nền tảng kết nối cộng đồng nhiếp ảnh phim với dịch vụ phòng tối và phòng chụp  
**Hệ quản trị CSDL:** Microsoft SQL Server 2022 Developer Edition  
**Nhóm thực hiện:** Nhóm 7 — Môn Thiết kế cơ sở dữ liệu  

---

## I. TỔNG QUAN HỆ THỐNG VÀ KIẾN TRÚC DOCKER

Hệ thống cơ sở dữ liệu được triển khai dưới dạng Docker Container sử dụng image chính thức từ Microsoft: `mcr.microsoft.com/mssql/server:2022-latest`.

### 1.1. Kiến trúc tổng thể

```
+-------------------------------------------------------------------------+
|                               HOST MACHINE                              |
|                                                                         |
|   +-------------------+                     +-----------------------+   |
|   | .env              |                     |  SQL_src/             |   |
|   | docker-compose.yml|                     |  - 01_database.sql    |   |
|   +-------------------+                     |  - 02_tables.sql      |   |
|            |                                |  - 03_constraints.sql |   |
|            v                                |  - 04_triggers.sql    |   |
|   +---------------------------------------+ |  - 05_seed.sql        |   |
|   |           DOCKER COMPOSE              | +-----------------------+   |
|   +---------------------------------------+             |               |
|            |                                            | (Mount Volume)|
|            v                                            v               |
|   +-----------------------------------------------------------------+   |
|   | Container: sqlserver_filmphoto (Port: 1433)                     |   |
|   | - Image: mcr.microsoft.com/mssql/server:2022-latest             |   |
|   | - Volume data: mssql_data -> /var/opt/mssql/data               |   |
|   | - Script dir: ./SQL_src -> /usr/src/app/sql                     |   |
|   | - Healthcheck: sqlcmd -Q "SELECT 1"                             |   |
|   +-----------------------------------------------------------------+   |
|                                                                         |
+-------------------------------------------------------------------------+
```

---

## II. THÔNG SỐ CẤU HÌNH CHI TIẾT

### 2.1. Tệp biến môi trường `.env`

Tệp `.env` lưu trữ các thông số bảo mật và cấu hình môi trường:

| Tên biến | Giá trị mặc định | Ý nghĩa |
| :--- | :--- | :--- |
| `ACCEPT_EULA` | `Y` | Đồng ý điều khoản sử dụng của Microsoft SQL Server |
| `SA_PASSWORD` | `FilmPhoto2026!DB` | Mật khẩu tài khoản quản trị `sa` (đáp ứng tiêu chuẩn chữ hoa, thường, số, ký tự đặc biệt) |
| `MSSQL_PID` | `Developer` | Phiên bản bản quyền miễn phí đầy đủ tính năng |
| `DB_PORT` | `14333` | Cổng kết nối TCP/IP ánh xạ ra máy host |
| `DB_NAME` | `FilmPhotographyDB` | Tên cơ sở dữ liệu chính của dự án |
| `CONTAINER_NAME` | `sqlserver_filmphoto` | Tên của Docker Container |

### 2.2. Tệp `docker-compose.yml`

Tệp `docker-compose.yml` định nghĩa 2 services:
1. **`sqlserver`**: Chạy SQL Server 2022, ánh xạ cổng `1433`, gắn volume lưu trữ bền vững `mssql_data` và mount thư mục `SQL_src`.
2. **`sqlserver-init`**: Tự động đợi `sqlserver` chuyển sang trạng thái **healthy** và thực thi nạp toàn bộ cấu trúc CSDL + dữ liệu mẫu một chạm.

---

## III. HƯỚNG DẪN KHỞI CHẠY VÀ VẬN HÀNH

### 3.1. Khởi động Container (Tự động nạp CSDL & Dữ liệu)

Mở terminal tại thư mục gốc của dự án (`Nhom7-TKCSDL`), chạy lệnh:

```bash
# Khởi động dịch vụ ở chế độ chạy nền
docker compose up -d
```

Quá trình này sẽ:
1. Kéo image `mssql/server:2022-latest` (nếu chưa có).
2. Khởi động container `sqlserver_filmphoto`.
3. Kiểm tra tính sẵn sàng qua healthcheck.
4. Container `sqlserver-init` tự động chạy chuỗi script trong `SQL_src/` để tạo 21 bảng và 229.500 bản ghi mẫu.

### 3.2. Kiểm tra trạng thái và Logs

```bash
# Xem trạng thái các container đang chạy
docker compose ps

# Xem nhật ký khởi tạo của database
docker compose logs -f sqlserver

# Xem log quá trình nạp dữ liệu mẫu
docker compose logs sqlserver-init
```

### 3.3. Dừng và Quản lý Container

```bash
# Dừng container (dữ liệu CSDL trong volume mssql_data vẫn được giữ nguyên)
docker compose down

# Dừng và XÓA TOÀN BỘ dữ liệu để làm lại từ đầu
docker compose down -v
```

---

## IV. HƯỚNG DẪN KẾT NỐI CƠ SỞ DỮ LIỆU

### 4.1. Thông tin kết nối tổng quát

- **Server / Host:** `localhost` hoặc `127.0.0.1` (Cổng: `14333`)
- **Authentication:** `SQL Server Authentication`
- **Username:** `sa`
- **Password:** `FilmPhoto2026!DB` (hoặc giá trị trong tệp `.env`)
- **Database:** `FilmPhotographyDB`
- **Trust Server Certificate:** `True` (bắt buộc khi kết nối với SQL Server 2022)

---

### 4.2. Kết nối bằng các công cụ phổ biến

#### A. SQL Server Management Studio (SSMS)
1. **Server type:** `Database Engine`
2. **Server name:** `localhost,14333`
3. **Authentication:** `SQL Server Authentication`
4. **Login:** `sa`
5. **Password:** `FilmPhoto2026!DB`
6. Nhấn vào **Options >>** -> Chọn tab **Connection Properties** -> Tích chọn **Trust server certificate**.
7. Nhấn **Connect**.

#### B. Visual Studio Code (Extension: `mssql` / `SQLTools`)
1. Cài extension **SQL Server (mssql)** của Microsoft.
2. Thêm Connection Profile mới:
  - `Server name`: `localhost`
  - `Port`: `14333`
   - `Database name`: `FilmPhotographyDB`
   - `Authentication Type`: `SQL Login`
   - `User name`: `sa`
  - `Password`: `FilmPhoto2026!DB`
   - `Trust server certificate`: `Yes`

#### C. DBeaver / DataGrip / Azure Data Studio
- Driver: **Microsoft Driver**
- Host: `localhost` | Port: `1433`
- Database: `FilmPhotographyDB`
- User: `sa` | Password: `FilmPhoto2026!DB`
- Driver properties: `trustServerCertificate = true`

#### D. Truy cập trực tiếp qua dòng lệnh `sqlcmd` trong Docker Container

```bash
# Mở phiên sqlcmd tương tác trực tiếp bên trong container
docker exec -it sqlserver_filmphoto /opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P "FilmPhoto2026!DB" -C -d FilmPhotographyDB
```

---

### 4.3. Chuỗi kết nối mẫu cho ứng dụng (Connection Strings)

- **C# / .NET (Entity Framework / ADO.NET):**
  ```text
  Server=localhost,14333;Database=FilmPhotographyDB;User Id=sa;Password=FilmPhoto2026!DB;TrustServerCertificate=True;
  ```
- **Node.js (tedious / mssql / Prisma):**
  ```text
  sqlserver://localhost:14333;database=FilmPhotographyDB;user=sa;password=FilmPhoto2026!DB;encrypt=true;trustServerCertificate=true;
  ```
- **Python (pyodbc / SQLAlchemy):**
  ```text
  mssql+pyodbc://sa:FilmPhoto%402026%21DB@localhost:1433/FilmPhotographyDB?driver=ODBC+Driver+18+for+SQL+Server&TrustServerCertificate=yes
  ```

---

## V. CẤU TRÚC BỘ MÃ NGUỒN `SQL_src/`

Mã nguồn cơ sở dữ liệu được chia nhỏ theo từng bước chuẩn kỹ thuật:

```
SQL_src/
├── 01_create_database.sql             # Tạo Database & thiết lập Collation Vietnamese_100_CI_AS
├── 02_create_tables.sql               # Tạo 21 bảng (15 thực thể + 6 quan hệ M:N)
├── 03_create_constraints_and_indexes.sql # Tạo ràng buộc CHECK, UNIQUE và Non-Clustered Indexes
├── 04_create_triggers_and_procedures.sql # Triggers tính duration, Views báo cáo, Stored Procedures
├── 05_seed_data.sql                   # Nạp dữ liệu mẫu chính xác theo plan_db.md
├── init_db.sql                        # Script tổng hợp sqlcmd (:r)
├── init.sh                            # Script bash thực thi tự động trên Linux/Docker
└── init.ps1                           # Script PowerShell thực thi trên Windows
```

---

## VI. ĐỐI CHIẾU SỐ LƯỢNG BẢN GHI (PLAN_DB.MD & CHAPTERS 1-3)

Sau khi nạp dữ liệu mẫu từ `05_seed_data.sql`, toàn bộ 21 quan hệ có số lượng bản ghi đạt chuẩn 100% như bảng sau:

| STT | Tên Quan hệ (Bảng) | Số bản ghi thực tế | Mục tiêu `plan_db.md` | Ý nghĩa nghiệp vụ | Trạng thái |
| --: | :--- | --: | --: | :--- | :---: |
| 1 | `USER` | **100** | 100 | Photographer (70), Provider (15), Expert (10), Admin (5) | ✓ Khớp 100% |
| 2 | `SERVICE_PROVIDER` | **20** | 20 | Nhà cung cấp phòng tối, lab tráng rọi, studio | ✓ Khớp 100% |
| 3 | `CREATIVE_SPACE` | **60** | 60 | Buồng tối, studio tự nhiên, studio chân dung, hybrid | ✓ Khớp 100% |
| 4 | `RESOURCE` | **150** | 150 | Máy ảnh film, lens, enlarger, scanner, đèn, hóa chất | ✓ Khớp 100% |
| 5 | `MAINTENANCE` | **100** | 100 | Lịch bảo dưỡng, căn chỉnh quang học, vệ sinh thiết bị | ✓ Khớp 100% |
| 6 | `SERVICE_PACKAGE` | **60** | 60 | Gói tráng rọi, gói thuê studio, gói masterclass | ✓ Khớp 100% |
| 7 | `PROMOTION` | **40** | 40 | Khuyến mãi theo tỷ lệ % hoặc số tiền cố định | ✓ Khớp 100% |
| 8 | `RESERVATION` | **500** | 500 | Giao dịch đặt chỗ không gian và dịch vụ | ✓ Khớp 100% |
| 9 | `PAYMENT` | **450** | 450 | Giao dịch thanh toán qua VNPay, Momo, Chuyển khoản | ✓ Khớp 100% |
| 10 | `SERVICE_SESSION` | **400** | 400 | Phiên sử dụng thực tế (check-in, check-out, duration) | ✓ Khớp 100% |
| 11 | `REVIEW` | **300** | 300 | Đánh giá sao (1..5) và nhận xét của nhiếp ảnh gia | ✓ Khớp 100% |
| 12 | `COMMUNITY_CONTENT` | **300** | 300 | Bài viết chia sẻ kỹ thuật, hướng dẫn, đánh giá film | ✓ Khớp 100% |
| 13 | `WORKSHOP` | **50** | 50 | Workshop đào tạo tráng rọi, scan phim do Expert tổ chức | ✓ Khớp 100% |
| 14 | `PHOTO` | **500** | 500 | Ảnh tác phẩm analog do thành viên đăng tải | ✓ Khớp 100% |
| 15 | `COMPLAINT` | **50** | 50 | Khiếu nại và biên bản xử lý chất lượng dịch vụ | ✓ Khớp 100% |
| 16 | `PACKAGE_SPACE` | **120** | 120 | Bảng trung gian Gói dịch vụ - Không gian (M:N) | ✓ Khớp 100% |
| 17 | `PACKAGE_RESOURCE` | **180** | 180 | Bảng trung gian Gói dịch vụ - Tài nguyên (M:N) | ✓ Khớp 100% |
| 18 | `RESERVATION_SPACE` | **600** | 600 | Bảng trung gian Đặt chỗ - Không gian (M:N) | ✓ Khớp 100% |
| 19 | `RESERVATION_RESOURCE` | **800** | 800 | Bảng trung gian Đặt chỗ - Tài nguyên (M:N) | ✓ Khớp 100% |
| 20 | `SESSION_RESOURCE` | **600** | 600 | Bảng trung gian Phiên sử dụng - Tài nguyên (M:N) | ✓ Khớp 100% |
| 21 | `WORKSHOP_REGISTRATION` | **300** | 300 | Bảng trung gian Đăng ký tham gia Workshop (M:N) | ✓ Khớp 100% |

### 6.1. Câu truy vấn kiểm tra số lượng bản ghi

Để kiểm tra lại bất kỳ lúc nào, chạy truy vấn sau trong SQL Server:

```sql
USE FilmPhotographyDB;
GO

SELECT 
    t.name AS [Tên bảng],
    p.rows AS [Số bản ghi thực tế]
FROM sys.tables t
INNER JOIN sys.partitions p ON t.object_id = p.object_id AND p.index_id IN (0, 1)
ORDER BY p.rows DESC, t.name ASC;
GO
```

---

## VII. HƯỚNG DẪN SAO LƯU (BACKUP) VÀ PHỤC HỒI (RESTORE)

### 7.1. Tạo bản sao lưu (`.bak`)

Chạy lệnh sau để xuất file sao lưu trực tiếp vào thư mục `SQL_src` trên máy host:

```bash
docker exec -it sqlserver_filmphoto /opt/mssql-tools18/bin/sqlcmd \
  -S localhost -U sa -P "FilmPhoto2026!DB" -C \
  -Q "BACKUP DATABASE [FilmPhotographyDB] TO DISK = N'/usr/src/app/sql/FilmPhotographyDB_Backup.bak' WITH FORMAT, MEDIANAME = N'FilmPhoto_SQLServer_Backup', NAME = N'Full Backup of FilmPhotographyDB';"
```

### 7.2. Phục hồi từ file sao lưu (`.bak`)

```bash
docker exec -it sqlserver_filmphoto /opt/mssql-tools18/bin/sqlcmd \
  -S localhost -U sa -P "FilmPhoto2026!DB" -C \
  -Q "RESTORE DATABASE [FilmPhotographyDB] FROM DISK = N'/usr/src/app/sql/FilmPhotographyDB_Backup.bak' WITH REPLACE;"
```

---

## VIII. XỬ LÝ SỰ CỐ THƯỜNG GẶP (TROUBLESHOOTING)

1. **Lỗi: "Login failed for user 'sa'"**
   - Đảm bảo mật khẩu nhập đúng khớp với `SA_PASSWORD` trong tệp `.env`.
   - Lưu ý mật khẩu phải có ít nhất 8 ký tự, bao gồm ký tự viết hoa, viết thường, chữ số và ký tự đặc biệt.

2. **Lỗi: "The certificate chain was issued by an authority that is not trusted"**
   - Với SQL Server 2022 và các công cụ kết nối mới (SSMS 19+, ODBC Driver 18+), mặc định mã hóa TLS được bật.
   - **Khắc phục:** Bật tùy chọn `Trust Server Certificate = True` hoặc thêm cờ `-C` khi chạy lệnh `sqlcmd`.

3. **Lỗi: "Port 1433 is already in use"**
   - Do trên máy host đã có sẵn một phiên bản SQL Server Local đang chạy và chiếm cổng 1433.
   - **Khắc phục:** Đổi cổng trong `.env` thành `DB_PORT=14333` rồi chạy lại `docker compose up -d`. Khi đó kết nối sẽ là `localhost,14333`.
