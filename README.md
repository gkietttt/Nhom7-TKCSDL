# Nhom7-TKCSDL

Cơ sở dữ liệu cho đề tài **Platform Connecting the Film Photography Community with Darkroom and Studio Services**.

Repo sử dụng Microsoft SQL Server 2022 Developer chạy bằng Docker Compose. Bộ mã nguồn SQL gồm 21 bảng và dữ liệu mẫu theo `doc/plan_db.md`.

## 1. Yêu cầu môi trường

- Git
- Docker Desktop phiên bản có Docker Compose v2
- Windows, macOS hoặc Linux
- Tối thiểu khoảng 4 GB RAM cấp cho Docker
- Cổng `1433` chưa bị ứng dụng khác sử dụng

## 2. Tải đầy đủ source code

### Cách 1: Dùng Git

```bash
git clone https://github.com/gkietttt/Nhom7-TKCSDL.git
cd Nhom7-TKCSDL
```

Nếu đã tải trước đó, cập nhật toàn bộ source:

```bash
git pull origin main
```

Nếu nhánh mặc định của repo là nhánh khác, thay `main` bằng tên nhánh tương ứng.

### Cách 2: Tải file ZIP

1. Mở https://github.com/gkietttt/Nhom7-TKCSDL.
2. Chọn **Code** > **Download ZIP**.
3. Giải nén toàn bộ thư mục rồi mở terminal tại thư mục có `docker-compose.yml`.

Không chỉ tải riêng thư mục `SQL_src`; Docker Compose cần cả `docker-compose.yml`, `.env` và toàn bộ thư mục `SQL_src`.

## 3. Cấu hình môi trường

Tạo hoặc kiểm tra file `.env` ở thư mục gốc:

```dotenv
ACCEPT_EULA=Y
SA_PASSWORD=FilmPhoto@2026!DB
MSSQL_PID=Developer
DB_PORT=1433
DB_NAME=FilmPhotographyDB
CONTAINER_NAME=sqlserver_filmphoto
```

Có thể bắt đầu từ file mẫu:

```powershell
Copy-Item .env.example .env
```

Trên Linux/macOS:

```bash
cp .env.example .env
```

Đổi `SA_PASSWORD` trước khi dùng cho môi trường chia sẻ hoặc triển khai thật. Mật khẩu SQL Server phải có chữ hoa, chữ thường, số và ký tự đặc biệt.

## 4. Chạy database bằng Docker

Mở terminal tại thư mục gốc dự án và chạy:

```bash
docker compose up -d
```

Docker Compose sẽ:

1. Tải image `mcr.microsoft.com/mssql/server:2022-latest` nếu máy chưa có.
2. Khởi động SQL Server ở container `sqlserver_filmphoto`.
3. Chờ healthcheck xác nhận SQL Server sẵn sàng.
4. Chạy `SQL_src/init_db.sql` trong container khởi tạo.
5. Tạo database, 21 bảng, ràng buộc, trigger, procedure và dữ liệu mẫu.

Kiểm tra trạng thái:

```bash
docker compose ps
```

Xem log khởi tạo:

```bash
docker compose logs sqlserver-init
docker compose logs -f sqlserver
```

Chờ đến khi log init hiển thị hoàn tất trước khi kết nối từ SSMS, VS Code hoặc DBeaver.

## 5. Kết nối SQL Server

Thông tin mặc định:

| Thuộc tính | Giá trị |
|---|---|
| Server | `localhost,1433` |
| Database | `FilmPhotographyDB` |
| Authentication | SQL Server Authentication |
| User | `sa` |
| Password | Giá trị `SA_PASSWORD` trong `.env` |
| Trust server certificate | `True` |

Chuỗi kết nối mẫu:

```text
Server=localhost,1433;Database=FilmPhotographyDB;User Id=sa;Password=FilmPhoto@2026!DB;TrustServerCertificate=True;
```

Kết nối trực tiếp bằng `sqlcmd` trong container:

```bash
docker exec -it sqlserver_filmphoto /opt/mssql-tools18/bin/sqlcmd \
  -S localhost -U sa -P "FilmPhoto@2026!DB" -C -d FilmPhotographyDB
```

Trong PowerShell, dùng một dòng tương đương:

```powershell
docker exec -it sqlserver_filmphoto /opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P "FilmPhoto@2026!DB" -C -d FilmPhotographyDB
```

## 6. Kiểm tra database

Sau khi kết nối, chạy:

```sql
USE FilmPhotographyDB;
GO

SELECT COUNT(*) AS TableCount
FROM sys.tables
WHERE is_ms_shipped = 0;
GO

SELECT
    t.name AS TableName,
    p.rows AS RowCount
FROM sys.tables AS t
JOIN sys.partitions AS p
    ON p.object_id = t.object_id
   AND p.index_id IN (0, 1)
WHERE t.is_ms_shipped = 0
ORDER BY t.name;
GO
```

Kết quả mong đợi là **21 bảng** và tổng cộng **5.710 bản ghi** theo `doc/plan_db.md`.

## 7. Dừng, khởi động lại và xóa dữ liệu

Dừng container nhưng giữ dữ liệu:

```bash
docker compose down
```

Khởi động lại:

```bash
docker compose up -d
```

Xóa container và volume database để tạo lại hoàn toàn từ đầu:

```bash
docker compose down -v
docker compose up -d
```

> `docker compose down -v` sẽ xóa toàn bộ dữ liệu trong volume `mssql_data`. Chỉ dùng khi muốn reset database hoặc đang ở môi trường phát triển.

## 8. Chạy script thủ công

Docker Compose đã tự chạy `SQL_src/init_db.sql`. Chỉ chạy thủ công khi cần khởi tạo lại hoặc đang dùng SQL Server bên ngoài Docker.

### PowerShell trên Windows

Cần cài `sqlcmd` và bảo đảm lệnh `sqlcmd` có trong `PATH`:

```powershell
cd SQL_src
.\init.ps1 -Server "localhost,1433" -User "sa" -Password "FilmPhoto@2026!DB"
```

### Bash trên Linux/macOS

```bash
cd SQL_src
chmod +x init.sh
./init.sh
```

Các script được thực thi theo thứ tự:

1. `01_create_database.sql`
2. `02_create_tables.sql`
3. `03_create_constraints_and_indexes.sql`
4. `04_create_triggers_and_procedures.sql`
5. `05_seed_data.sql`

## 9. Cấu trúc chính của repository

```text
.
├── docker-compose.yml
├── .env.example
├── SQL_src/
│   ├── 01_create_database.sql
│   ├── 02_create_tables.sql
│   ├── 03_create_constraints_and_indexes.sql
│   ├── 04_create_triggers_and_procedures.sql
│   ├── 05_seed_data.sql
│   ├── init_db.sql
│   ├── init.ps1
│   └── init.sh
├── doc/
│   ├── docker_sql_server.md
│   └── plan_db.md
├── diagram/
└── book.tex
```

## 10. Xử lý lỗi thường gặp

### Port 1433 đã được sử dụng

Đổi cổng host trong `.env`, ví dụ:

```dotenv
DB_PORT=14333
```

Sau đó chạy lại:

```bash
docker compose down
docker compose up -d
```

Khi kết nối, dùng `localhost,14333`.

### Login failed for user `sa`

Kiểm tra `SA_PASSWORD` trong `.env`. Nếu container đã được tạo với mật khẩu cũ, đổi mật khẩu trong `.env` không tự thay đổi mật khẩu của database hiện có. Với môi trường phát triển, reset volume:

```bash
docker compose down -v
docker compose up -d
```

### Certificate chain was issued by an authority that is not trusted

Bật `Trust Server Certificate=True` trong công cụ kết nối hoặc dùng tùy chọn `-C` với `sqlcmd`.

### Init container kết thúc với trạng thái `Exited (0)`

Đây là trạng thái bình thường: `sqlserver-init` chỉ chạy một lần để nạp database rồi kết thúc. Kiểm tra kết quả bằng:

```bash
docker compose logs sqlserver-init
```

### Xem log container

```bash
docker compose logs --tail=100 sqlserver
docker compose logs --tail=100 sqlserver-init
```

## 11. Tài liệu liên quan

- [Hướng dẫn Docker SQL Server chi tiết](doc/docker_sql_server.md)
- [Kế hoạch dữ liệu mẫu](doc/plan_db.md)
- [Báo cáo LaTeX](book.pdf)
