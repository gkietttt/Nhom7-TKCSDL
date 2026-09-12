# MỤC LỤC – THIẾT KẾ CƠ SỞ DỮ LIỆU

## CHƯƠNG 1. PHÂN TÍCH YÊU CẦU

### 1.1. Giới thiệu bài toán

* 1.1.1. Bối cảnh và mục đích của hệ thống
* 1.1.2. Phạm vi dữ liệu cần quản lý
* 1.1.3. Các đối tượng tham gia hệ thống

### 1.2. Phân tích nghiệp vụ

* 1.2.1. Các nghiệp vụ chính của hệ thống
* 1.2.2. Quy trình đặt dịch vụ/phòng và tài nguyên
* 1.2.3. Quy trình quản lý phòng, thiết bị và tài nguyên
* 1.2.4. Quy trình quản lý gói dịch vụ
* 1.2.5. Quy trình quản lý phiên sử dụng
* 1.2.6. Quy trình đánh giá và chia sẻ nội dung

### 1.3. Xác định yêu cầu dữ liệu

* 1.3.1. Các nhóm dữ liệu cần lưu trữ
* 1.3.2. Thông tin người dùng và vai trò
* 1.3.3. Thông tin nhà cung cấp và không gian dịch vụ
* 1.3.4. Thông tin thiết bị và tài nguyên
* 1.3.5. Thông tin đặt chỗ và sử dụng dịch vụ
* 1.3.6. Thông tin thanh toán, đánh giá và nội dung cộng đồng

### 1.4. Xác định các quy tắc nghiệp vụ

* 1.4.1. Quy tắc quản lý người dùng
* 1.4.2. Quy tắc quản lý tài nguyên
* 1.4.3. Quy tắc đặt chỗ và tránh trùng lịch
* 1.4.4. Quy tắc sử dụng và bảo trì tài nguyên
* 1.4.5. Các ràng buộc nghiệp vụ khác

### 1.5. Tổng hợp yêu cầu dữ liệu

* 1.5.1. Danh sách yêu cầu dữ liệu
* 1.5.2. Danh sách quy tắc nghiệp vụ
* 1.5.3. Đầu vào cho thiết kế quan niệm

> **Mục tiêu Chương 1:** chưa vẽ bảng hay quyết định kiểu dữ liệu. Kết quả chính là **đặc tả yêu cầu dữ liệu và quy tắc nghiệp vụ**, đúng với slide. 

---

# CHƯƠNG 2. THIẾT KẾ QUAN NIỆM

### 2.1. Xác định các thực thể

* 2.1.1. Phương pháp xác định thực thể
* 2.1.2. Danh sách các thực thể chính
* 2.1.3. Xác định khóa định danh cho thực thể

### 2.2. Xác định thuộc tính

* 2.2.1. Thuộc tính của các thực thể
* 2.2.2. Thuộc tính định danh
* 2.2.3. Thuộc tính dẫn xuất/đa trị nếu có

### 2.3. Xác định mối kết hợp

* 2.3.1. Các mối kết hợp giữa các thực thể
* 2.3.2. Xác định bản số 1:1
* 2.3.3. Xác định bản số 1:N
* 2.3.4. Xác định bản số M:N
* 2.3.5. Xác định mức tham gia bắt buộc/tùy chọn

### 2.4. Xây dựng mô hình ERD/EER

* 2.4.1. ERD tổng thể
* 2.4.2. Biểu diễn thuộc tính và khóa
* 2.4.3. Biểu diễn bản số và mức tham gia
* 2.4.4. Các ràng buộc nghiệp vụ trên mô hình

### 2.5. Các trường hợp đặc biệt trong mô hình

* 2.5.1. Mối kết hợp M:N có thuộc tính riêng
* 2.5.2. Thực thể yếu
* 2.5.3. Tổng quát hóa/chuyên biệt hóa EER

### 2.6. Kiểm chứng mô hình quan niệm

* 2.6.1. Kiểm tra thực thể và thuộc tính
* 2.6.2. Kiểm tra mối kết hợp và bản số
* 2.6.3. Kiểm tra bằng dữ liệu mẫu và tình huống

### 2.7. Kết quả thiết kế quan niệm

* 2.7.1. ERD/EER hoàn chỉnh
* 2.7.2. Từ điển dữ liệu
* 2.7.3. Danh sách các ràng buộc nghiệp vụ

Các mục trên bám khá sát Chương 2: slide nhấn mạnh **thực thể, thuộc tính, khóa, mối kết hợp, bản số, mức tham gia**, sau đó xử lý **M:N, thực thể yếu và chuyên biệt hóa/tổng quát hóa**.  

---

# CHƯƠNG 3. THIẾT KẾ LOGIC

### 3.1. Chuyển mô hình quan niệm sang mô hình quan hệ

* 3.1.1. Chuyển thực thể thành quan hệ
* 3.1.2. Xác định thuộc tính của quan hệ
* 3.1.3. Xác định khóa chính
* 3.1.4. Chuyển mối kết hợp 1:N
* 3.1.5. Chuyển mối kết hợp M:N
* 3.1.6. Chuyển thực thể yếu và EER

### 3.2. Xác định phụ thuộc hàm

* 3.2.1. Xác định các phụ thuộc hàm từ nghiệp vụ
* 3.2.2. Kiểm tra phụ thuộc hàm
* 3.2.3. Phụ thuộc đầy đủ
* 3.2.4. Phụ thuộc bắc cầu

### 3.3. Bao đóng và xác định khóa

* 3.3.1. Bao đóng của tập thuộc tính
* 3.3.2. Kiểm tra suy diễn phụ thuộc hàm
* 3.3.3. Xác định siêu khóa
* 3.3.4. Xác định khóa ứng viên

### 3.4. Phủ tối thiểu

* 3.4.1. Tách vế phải
* 3.4.2. Loại thuộc tính dư
* 3.4.3. Loại phụ thuộc hàm dư thừa
* 3.4.4. Xác định phủ tối thiểu

### 3.5. Chuẩn hóa lược đồ

* 3.5.1. Dạng chuẩn 1NF
* 3.5.2. Dạng chuẩn 2NF
* 3.5.3. Dạng chuẩn 3NF
* 3.5.4. Dạng chuẩn BCNF
* 3.5.5. Dạng chuẩn 4NF và 5NF *(nếu áp dụng cho bài toán)*

### 3.6. Phân rã lược đồ

* 3.6.1. Xác định quan hệ cần phân rã
* 3.6.2. Phân rã theo phụ thuộc hàm
* 3.6.3. Kiểm tra bảo toàn phụ thuộc
* 3.6.4. Kiểm tra bảo toàn kết nối
* 3.6.5. Phương pháp Chase *(nếu cần trình bày)*

### 3.7. Lược đồ logic cuối cùng

* 3.7.1. Danh sách các quan hệ
* 3.7.2. Khóa chính và khóa ngoại
* 3.7.3. Các ràng buộc dữ liệu
* 3.7.4. Lược đồ quan hệ sau chuẩn hóa

**Lưu ý:** Chương 3 của slide khá nặng về **FD → bao đóng → khóa → phủ tối thiểu → chuẩn hóa → phân rã → Chase**, nên nên giữ các phần này trong mục lục nhưng **không cần chia nhỏ hơn nữa** ở cấp báo cáo.   

---

# CHƯƠNG 4. THIẾT KẾ VẬT LÝ

### 4.1. Lựa chọn hệ quản trị cơ sở dữ liệu

* 4.1.1. DBMS được lựa chọn
* 4.1.2. Căn cứ lựa chọn DBMS

### 4.2. Thiết kế lưu trữ vật lý

* 4.2.1. Khối và bản ghi
* 4.2.2. Ước lượng số khối dữ liệu
* 4.2.3. Lựa chọn tổ chức tập tin
* 4.2.4. Heap, Sorted và Hash

### 4.3. Thiết kế chỉ mục

* 4.3.1. Xác định nhu cầu sử dụng chỉ mục
* 4.3.2. Chỉ mục Clustered/Nonclustered
* 4.3.3. Chỉ mục B+
* 4.3.4. Chỉ mục Hash
* 4.3.5. Chỉ mục kết hợp
* 4.3.6. Lựa chọn chỉ mục theo workload

### 4.4. Phân vùng dữ liệu

* 4.4.1. Phân vùng ngang
* 4.4.2. Phân vùng dọc
* 4.4.3. Lựa chọn khóa phân vùng

### 4.5. Tối ưu truy vấn

* 4.5.1. Phân tích workload
* 4.5.2. Cây truy vấn và tối ưu phép toán
* 4.5.3. Ước lượng kích thước trung gian
* 4.5.4. Ước lượng chi phí truy vấn
* 4.5.5. Lựa chọn thuật toán kết nối

### 4.6. Lựa chọn cấu hình vật lý

* 4.6.1. Bộ đệm (Buffer Pool)
* 4.6.2. RAID và tổ chức lưu trữ
* 4.6.3. Row-store và Column-store
* 4.6.4. Đánh đổi giữa đọc, ghi và dung lượng

### 4.7. Thiết kế vật lý cuối cùng

* 4.7.1. Kiểu dữ liệu
* 4.7.2. Các ràng buộc vật lý
* 4.7.3. Các chỉ mục
* 4.7.4. Phân vùng/cấu hình lưu trữ
* 4.7.5. Tổng hợp thiết kế vật lý
