| STT | Quan hệ                 | Số bản ghi hợp lý mới | Lý do                                                |
| --: | ----------------------- | --------------------: | ---------------------------------------------------- |
|   1 | `USER`                  |            **10,000** | Đủ lớn để phân bố Photographer/Provider/Expert/Admin |
|   2 | `SERVICE_PROVIDER`      |             **1,000** | Quy mô provider đủ lớn để thống kê                   |
|   3 | `CREATIVE_SPACE`        |             **3,000** | ~3 space/provider                                    |
|   4 | `RESOURCE`              |            **15,000** | Trung bình ~15 resource/provider                     |
|   5 | `MAINTENANCE`           |            **18,000** | Một resource có nhiều lịch sử bảo trì                |
|   6 | `SERVICE_PACKAGE`       |             **3,000** | ~3 package/provider                                  |
|   7 | `PROMOTION`             |             **1,000** | Provider có thể có nhiều chương trình                |
|   8 | `RESERVATION`           |            **16,000** | **Bảng giao dịch chính**, cần đủ lớn để phân tích    |
|   9 | `PAYMENT`               |            **10,000** | Phần lớn reservation có thanh toán                   |
|  10 | `SERVICE_SESSION`       |            **15,000** | Reservation đã thực hiện                             |
|  11 | `REVIEW`                |            **10,000** | Có đủ dữ liệu đánh giá                               |
|  12 | `COMMUNITY_CONTENT`     |             **5,000** | Đủ lớn để phân tích hoạt động cộng đồng              |
|  13 | `WORKSHOP`              |               **500** | Đủ để thống kê workshop                              |
|  14 | `PHOTO`                 |            **20,000** | Người dùng có thể đăng nhiều ảnh                     |
|  15 | `COMPLAINT`             |             **1,000** | Một phần nhỏ reservation phát sinh khiếu nại         |
|  16 | `PACKAGE_SPACE`         |             **6,000** | Quan hệ M:N, nhiều package dùng nhiều space          |
|  17 | `PACKAGE_RESOURCE`      |            **15,000** | Package có nhiều resource                            |
|  18 | `RESERVATION_SPACE`     |            **25,000** | Một reservation có thể liên quan nhiều space         |
|  19 | `RESERVATION_RESOURCE`  |            **30,000** | Reservation sử dụng nhiều resource                   |
|  20 | `SESSION_RESOURCE`      |            **20,000** | Session sử dụng nhiều resource                       |
|  21 | `WORKSHOP_REGISTRATION` |             **5,000** | Trung bình ~10 user/workshop                         |
