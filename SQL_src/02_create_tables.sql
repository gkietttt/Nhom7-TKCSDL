-- ============================================================================
-- SCRIPT 02: CREATE TABLES (DDL)
-- Project: Platform Connecting Film Photography Community with Darkroom & Studio Services
-- Exactly matching Chapter 1, 2, 3 LaTeX documents & plan_db.md
-- ============================================================================

USE FilmPhotographyDB;
GO

-- Xóa các bảng theo đúng thứ tự phụ thuộc (nếu đã tồn tại)
IF OBJECT_ID('dbo.WORKSHOP_REGISTRATION', 'U') IS NOT NULL DROP TABLE dbo.WORKSHOP_REGISTRATION;
IF OBJECT_ID('dbo.SESSION_RESOURCE', 'U') IS NOT NULL DROP TABLE dbo.SESSION_RESOURCE;
IF OBJECT_ID('dbo.RESERVATION_RESOURCE', 'U') IS NOT NULL DROP TABLE dbo.RESERVATION_RESOURCE;
IF OBJECT_ID('dbo.RESERVATION_SPACE', 'U') IS NOT NULL DROP TABLE dbo.RESERVATION_SPACE;
IF OBJECT_ID('dbo.PACKAGE_RESOURCE', 'U') IS NOT NULL DROP TABLE dbo.PACKAGE_RESOURCE;
IF OBJECT_ID('dbo.PACKAGE_SPACE', 'U') IS NOT NULL DROP TABLE dbo.PACKAGE_SPACE;
IF OBJECT_ID('dbo.COMPLAINT', 'U') IS NOT NULL DROP TABLE dbo.COMPLAINT;
IF OBJECT_ID('dbo.PHOTO', 'U') IS NOT NULL DROP TABLE dbo.PHOTO;
IF OBJECT_ID('dbo.WORKSHOP', 'U') IS NOT NULL DROP TABLE dbo.WORKSHOP;
IF OBJECT_ID('dbo.COMMUNITY_CONTENT', 'U') IS NOT NULL DROP TABLE dbo.COMMUNITY_CONTENT;
IF OBJECT_ID('dbo.REVIEW', 'U') IS NOT NULL DROP TABLE dbo.REVIEW;
IF OBJECT_ID('dbo.SERVICE_SESSION', 'U') IS NOT NULL DROP TABLE dbo.SERVICE_SESSION;
IF OBJECT_ID('dbo.PAYMENT', 'U') IS NOT NULL DROP TABLE dbo.PAYMENT;
IF OBJECT_ID('dbo.RESERVATION', 'U') IS NOT NULL DROP TABLE dbo.RESERVATION;
IF OBJECT_ID('dbo.PROMOTION', 'U') IS NOT NULL DROP TABLE dbo.PROMOTION;
IF OBJECT_ID('dbo.SERVICE_PACKAGE', 'U') IS NOT NULL DROP TABLE dbo.SERVICE_PACKAGE;
IF OBJECT_ID('dbo.MAINTENANCE', 'U') IS NOT NULL DROP TABLE dbo.MAINTENANCE;
IF OBJECT_ID('dbo.RESOURCE', 'U') IS NOT NULL DROP TABLE dbo.RESOURCE;
IF OBJECT_ID('dbo.CREATIVE_SPACE', 'U') IS NOT NULL DROP TABLE dbo.CREATIVE_SPACE;
IF OBJECT_ID('dbo.SERVICE_PROVIDER', 'U') IS NOT NULL DROP TABLE dbo.SERVICE_PROVIDER;
IF OBJECT_ID('dbo.USER', 'U') IS NOT NULL DROP TABLE dbo.[USER];
GO

-- ----------------------------------------------------------------------------
-- 1. BẢNG [USER] (15 Thực thể chính - STT 1)
-- ----------------------------------------------------------------------------
CREATE TABLE dbo.[USER] (
    user_id     INT IDENTITY(1,1) NOT NULL,
    full_name   NVARCHAR(100) NOT NULL,
    email       NVARCHAR(100) NOT NULL,
    phone       NVARCHAR(20) NOT NULL,
    password    NVARCHAR(255) NOT NULL,
    role        NVARCHAR(50) NOT NULL,
    status      NVARCHAR(50) NOT NULL DEFAULT N'Active',
    created_at  DATETIME2(0) NOT NULL DEFAULT SYSDATETIME(),
    CONSTRAINT PK_USER PRIMARY KEY CLUSTERED (user_id),
    CONSTRAINT UQ_USER_EMAIL UNIQUE (email),
    CONSTRAINT UQ_USER_PHONE UNIQUE (phone)
);
GO

-- ----------------------------------------------------------------------------
-- 2. BẢNG SERVICE_PROVIDER (15 Thực thể chính - STT 2)
-- ----------------------------------------------------------------------------
CREATE TABLE dbo.SERVICE_PROVIDER (
    provider_id   INT IDENTITY(1,1) NOT NULL,
    business_name NVARCHAR(150) NOT NULL,
    description   NVARCHAR(MAX) NULL,
    address       NVARCHAR(255) NOT NULL,
    status        NVARCHAR(50) NOT NULL DEFAULT N'Active',
    created_at    DATETIME2(0) NOT NULL DEFAULT SYSDATETIME(),
    CONSTRAINT PK_SERVICE_PROVIDER PRIMARY KEY CLUSTERED (provider_id)
);
GO

-- ----------------------------------------------------------------------------
-- 3. BẢNG CREATIVE_SPACE (15 Thực thể chính - STT 3)
-- ----------------------------------------------------------------------------
CREATE TABLE dbo.CREATIVE_SPACE (
    space_id                INT IDENTITY(1,1) NOT NULL,
    provider_id             INT NOT NULL,
    name                    NVARCHAR(150) NOT NULL,
    space_type              NVARCHAR(50) NOT NULL,
    description             NVARCHAR(MAX) NULL,
    area                    DECIMAL(10,2) NOT NULL,
    capacity                INT NOT NULL,
    artistic_style          NVARCHAR(100) NULL,
    lighting_condition      NVARCHAR(100) NULL,
    ventilation             NVARCHAR(100) NULL,
    acoustic_characteristics NVARCHAR(100) NULL,
    operating_hours         NVARCHAR(100) NULL,
    usage_policy            NVARCHAR(MAX) NULL,
    pricing                 DECIMAL(12,2) NOT NULL,
    status                  NVARCHAR(50) NOT NULL DEFAULT N'Available',
    CONSTRAINT PK_CREATIVE_SPACE PRIMARY KEY CLUSTERED (space_id),
    CONSTRAINT FK_CREATIVE_SPACE_PROVIDER FOREIGN KEY (provider_id)
        REFERENCES dbo.SERVICE_PROVIDER (provider_id)
);
GO

-- ----------------------------------------------------------------------------
-- 4. BẢNG RESOURCE (15 Thực thể chính - STT 4)
-- ----------------------------------------------------------------------------
CREATE TABLE dbo.RESOURCE (
    resource_id               INT IDENTITY(1,1) NOT NULL,
    provider_id               INT NOT NULL,
    name                      NVARCHAR(150) NOT NULL,
    resource_type             NVARCHAR(50) NOT NULL,
    description               NVARCHAR(MAX) NULL,
    quantity                  INT NOT NULL DEFAULT 1,
    condition                 NVARCHAR(50) NOT NULL DEFAULT N'Good',
    rental_price              DECIMAL(12,2) NOT NULL,
    compatibility_information NVARCHAR(255) NULL,
    status                    NVARCHAR(50) NOT NULL DEFAULT N'Available',
    CONSTRAINT PK_RESOURCE PRIMARY KEY CLUSTERED (resource_id),
    CONSTRAINT FK_RESOURCE_PROVIDER FOREIGN KEY (provider_id)
        REFERENCES dbo.SERVICE_PROVIDER (provider_id)
);
GO

-- ----------------------------------------------------------------------------
-- 5. BẢNG MAINTENANCE (15 Thực thể chính - STT 5)
-- ----------------------------------------------------------------------------
CREATE TABLE dbo.MAINTENANCE (
    maintenance_id   INT IDENTITY(1,1) NOT NULL,
    resource_id      INT NOT NULL,
    maintenance_type NVARCHAR(50) NOT NULL,
    description      NVARCHAR(MAX) NULL,
    scheduled_at     DATETIME2(0) NOT NULL,
    completed_at     DATETIME2(0) NULL,
    cost             DECIMAL(12,2) NOT NULL DEFAULT 0,
    status           NVARCHAR(50) NOT NULL DEFAULT N'Scheduled',
    CONSTRAINT PK_MAINTENANCE PRIMARY KEY CLUSTERED (maintenance_id),
    CONSTRAINT FK_MAINTENANCE_RESOURCE FOREIGN KEY (resource_id)
        REFERENCES dbo.RESOURCE (resource_id)
);
GO

-- ----------------------------------------------------------------------------
-- 6. BẢNG SERVICE_PACKAGE (15 Thực thể chính - STT 6)
-- ----------------------------------------------------------------------------
CREATE TABLE dbo.SERVICE_PACKAGE (
    package_id   INT IDENTITY(1,1) NOT NULL,
    provider_id  INT NOT NULL,
    name         NVARCHAR(150) NOT NULL,
    description  NVARCHAR(MAX) NULL,
    price        DECIMAL(12,2) NOT NULL,
    duration     INT NOT NULL, -- Thời lượng tính theo giờ
    status       NVARCHAR(50) NOT NULL DEFAULT N'Active',
    created_at   DATETIME2(0) NOT NULL DEFAULT SYSDATETIME(),
    CONSTRAINT PK_SERVICE_PACKAGE PRIMARY KEY CLUSTERED (package_id),
    CONSTRAINT FK_SERVICE_PACKAGE_PROVIDER FOREIGN KEY (provider_id)
        REFERENCES dbo.SERVICE_PROVIDER (provider_id)
);
GO

-- ----------------------------------------------------------------------------
-- 7. BẢNG PROMOTION (15 Thực thể chính - STT 7)
-- ----------------------------------------------------------------------------
CREATE TABLE dbo.PROMOTION (
    promotion_id   INT IDENTITY(1,1) NOT NULL,
    provider_id    INT NOT NULL,
    name           NVARCHAR(150) NOT NULL,
    description    NVARCHAR(MAX) NULL,
    discount_type  NVARCHAR(20) NOT NULL,
    discount_value DECIMAL(12,2) NOT NULL,
    start_at       DATETIME2(0) NOT NULL,
    end_at         DATETIME2(0) NOT NULL,
    status         NVARCHAR(50) NOT NULL DEFAULT N'Active',
    CONSTRAINT PK_PROMOTION PRIMARY KEY CLUSTERED (promotion_id),
    CONSTRAINT FK_PROMOTION_PROVIDER FOREIGN KEY (provider_id)
        REFERENCES dbo.SERVICE_PROVIDER (provider_id)
);
GO

-- ----------------------------------------------------------------------------
-- 8. BẢNG RESERVATION (15 Thực thể chính - STT 8)
-- ----------------------------------------------------------------------------
CREATE TABLE dbo.RESERVATION (
    reservation_id INT IDENTITY(1,1) NOT NULL,
    user_id        INT NOT NULL,
    package_id     INT NULL,
    start_time     DATETIME2(0) NOT NULL,
    end_time       DATETIME2(0) NOT NULL,
    status         NVARCHAR(50) NOT NULL DEFAULT N'Pending',
    total_amount   DECIMAL(12,2) NOT NULL DEFAULT 0,
    created_at     DATETIME2(0) NOT NULL DEFAULT SYSDATETIME(),
    CONSTRAINT PK_RESERVATION PRIMARY KEY CLUSTERED (reservation_id),
    CONSTRAINT FK_RESERVATION_USER FOREIGN KEY (user_id)
        REFERENCES dbo.[USER] (user_id),
    CONSTRAINT FK_RESERVATION_PACKAGE FOREIGN KEY (package_id)
        REFERENCES dbo.SERVICE_PACKAGE (package_id)
);
GO

-- ----------------------------------------------------------------------------
-- 9. BẢNG PAYMENT (15 Thực thể chính - STT 9, quan hệ 1:1 với RESERVATION)
-- ----------------------------------------------------------------------------
CREATE TABLE dbo.PAYMENT (
    payment_id       INT IDENTITY(1,1) NOT NULL,
    reservation_id   INT NOT NULL,
    amount           DECIMAL(12,2) NOT NULL,
    payment_method   NVARCHAR(50) NOT NULL,
    payment_status   NVARCHAR(50) NOT NULL DEFAULT N'Pending',
    transaction_code NVARCHAR(100) NOT NULL,
    paid_at          DATETIME2(0) NULL,
    CONSTRAINT PK_PAYMENT PRIMARY KEY CLUSTERED (payment_id),
    CONSTRAINT UQ_PAYMENT_RESERVATION UNIQUE (reservation_id),
    CONSTRAINT UQ_PAYMENT_TRANSACTION_CODE UNIQUE (transaction_code),
    CONSTRAINT FK_PAYMENT_RESERVATION FOREIGN KEY (reservation_id)
        REFERENCES dbo.RESERVATION (reservation_id)
);
GO

-- ----------------------------------------------------------------------------
-- 10. BẢNG SERVICE_SESSION (15 Thực thể chính - STT 10, quan hệ 1:1 với RESERVATION)
-- ----------------------------------------------------------------------------
CREATE TABLE dbo.SERVICE_SESSION (
    session_id             INT IDENTITY(1,1) NOT NULL,
    reservation_id         INT NOT NULL,
    check_in               DATETIME2(0) NOT NULL,
    check_out              DATETIME2(0) NULL,
    actual_usage_duration  INT NULL, -- Thời lượng thực tế tính bằng phút
    status                 NVARCHAR(50) NOT NULL DEFAULT N'Active',
    CONSTRAINT PK_SERVICE_SESSION PRIMARY KEY CLUSTERED (session_id),
    CONSTRAINT UQ_SERVICE_SESSION_RESERVATION UNIQUE (reservation_id),
    CONSTRAINT FK_SERVICE_SESSION_RESERVATION FOREIGN KEY (reservation_id)
        REFERENCES dbo.RESERVATION (reservation_id)
);
GO

-- ----------------------------------------------------------------------------
-- 11. BẢNG REVIEW (15 Thực thể chính - STT 11, quan hệ 1:1 với RESERVATION)
-- ----------------------------------------------------------------------------
CREATE TABLE dbo.REVIEW (
    review_id      INT IDENTITY(1,1) NOT NULL,
    user_id        INT NOT NULL,
    reservation_id INT NOT NULL,
    rating         INT NOT NULL,
    comment        NVARCHAR(MAX) NULL,
    created_at     DATETIME2(0) NOT NULL DEFAULT SYSDATETIME(),
    CONSTRAINT PK_REVIEW PRIMARY KEY CLUSTERED (review_id),
    CONSTRAINT UQ_REVIEW_RESERVATION UNIQUE (reservation_id),
    CONSTRAINT FK_REVIEW_USER FOREIGN KEY (user_id)
        REFERENCES dbo.[USER] (user_id),
    CONSTRAINT FK_REVIEW_RESERVATION FOREIGN KEY (reservation_id)
        REFERENCES dbo.RESERVATION (reservation_id)
);
GO

-- ----------------------------------------------------------------------------
-- 12. BẢNG COMMUNITY_CONTENT (15 Thực thể chính - STT 12)
-- ----------------------------------------------------------------------------
CREATE TABLE dbo.COMMUNITY_CONTENT (
    content_id   INT IDENTITY(1,1) NOT NULL,
    user_id      INT NOT NULL,
    title        NVARCHAR(200) NOT NULL,
    content      NVARCHAR(MAX) NOT NULL,
    content_type NVARCHAR(50) NOT NULL,
    status       NVARCHAR(50) NOT NULL DEFAULT N'Published',
    created_at   DATETIME2(0) NOT NULL DEFAULT SYSDATETIME(),
    updated_at   DATETIME2(0) NOT NULL DEFAULT SYSDATETIME(),
    CONSTRAINT PK_COMMUNITY_CONTENT PRIMARY KEY CLUSTERED (content_id),
    CONSTRAINT FK_COMMUNITY_CONTENT_USER FOREIGN KEY (user_id)
        REFERENCES dbo.[USER] (user_id)
);
GO

-- ----------------------------------------------------------------------------
-- 13. BẢNG WORKSHOP (15 Thực thể chính - STT 13)
-- ----------------------------------------------------------------------------
CREATE TABLE dbo.WORKSHOP (
    workshop_id  INT IDENTITY(1,1) NOT NULL,
    organizer_id INT NOT NULL,
    title        NVARCHAR(200) NOT NULL,
    description  NVARCHAR(MAX) NULL,
    topic        NVARCHAR(100) NOT NULL,
    start_time   DATETIME2(0) NOT NULL,
    end_time     DATETIME2(0) NOT NULL,
    capacity     INT NOT NULL,
    location     NVARCHAR(255) NOT NULL,
    price        DECIMAL(12,2) NOT NULL DEFAULT 0,
    status       NVARCHAR(50) NOT NULL DEFAULT N'Upcoming',
    created_at   DATETIME2(0) NOT NULL DEFAULT SYSDATETIME(),
    CONSTRAINT PK_WORKSHOP PRIMARY KEY CLUSTERED (workshop_id),
    CONSTRAINT FK_WORKSHOP_ORGANIZER FOREIGN KEY (organizer_id)
        REFERENCES dbo.[USER] (user_id)
);
GO

-- ----------------------------------------------------------------------------
-- 14. BẢNG PHOTO (15 Thực thể chính - STT 14)
-- ----------------------------------------------------------------------------
CREATE TABLE dbo.PHOTO (
    photo_id    INT IDENTITY(1,1) NOT NULL,
    user_id     INT NOT NULL,
    title       NVARCHAR(200) NOT NULL,
    file_url    NVARCHAR(500) NOT NULL,
    description NVARCHAR(MAX) NULL,
    created_at  DATETIME2(0) NOT NULL DEFAULT SYSDATETIME(),
    updated_at  DATETIME2(0) NOT NULL DEFAULT SYSDATETIME(),
    CONSTRAINT PK_PHOTO PRIMARY KEY CLUSTERED (photo_id),
    CONSTRAINT FK_PHOTO_USER FOREIGN KEY (user_id)
        REFERENCES dbo.[USER] (user_id)
);
GO

-- ----------------------------------------------------------------------------
-- 15. BẢNG COMPLAINT (15 Thực thể chính - STT 15)
-- ----------------------------------------------------------------------------
CREATE TABLE dbo.COMPLAINT (
    complaint_id INT IDENTITY(1,1) NOT NULL,
    user_id      INT NOT NULL,
    subject      NVARCHAR(200) NOT NULL,
    description  NVARCHAR(MAX) NOT NULL,
    status       NVARCHAR(50) NOT NULL DEFAULT N'Open',
    created_at   DATETIME2(0) NOT NULL DEFAULT SYSDATETIME(),
    resolved_at  DATETIME2(0) NULL,
    resolution   NVARCHAR(MAX) NULL,
    CONSTRAINT PK_COMPLAINT PRIMARY KEY CLUSTERED (complaint_id),
    CONSTRAINT FK_COMPLAINT_USER FOREIGN KEY (user_id)
        REFERENCES dbo.[USER] (user_id)
);
GO

-- ----------------------------------------------------------------------------
-- 16. BẢNG PACKAGE_SPACE (Quan hệ trung gian M:N - STT 16)
-- ----------------------------------------------------------------------------
CREATE TABLE dbo.PACKAGE_SPACE (
    package_id INT NOT NULL,
    space_id   INT NOT NULL,
    CONSTRAINT PK_PACKAGE_SPACE PRIMARY KEY CLUSTERED (package_id, space_id),
    CONSTRAINT FK_PACKAGE_SPACE_PACKAGE FOREIGN KEY (package_id)
        REFERENCES dbo.SERVICE_PACKAGE (package_id) ON DELETE CASCADE,
    CONSTRAINT FK_PACKAGE_SPACE_SPACE FOREIGN KEY (space_id)
        REFERENCES dbo.CREATIVE_SPACE (space_id)
);
GO

-- ----------------------------------------------------------------------------
-- 17. BẢNG PACKAGE_RESOURCE (Quan hệ trung gian M:N - STT 17)
-- ----------------------------------------------------------------------------
CREATE TABLE dbo.PACKAGE_RESOURCE (
    package_id  INT NOT NULL,
    resource_id INT NOT NULL,
    quantity    INT NOT NULL DEFAULT 1,
    CONSTRAINT PK_PACKAGE_RESOURCE PRIMARY KEY CLUSTERED (package_id, resource_id),
    CONSTRAINT FK_PACKAGE_RESOURCE_PACKAGE FOREIGN KEY (package_id)
        REFERENCES dbo.SERVICE_PACKAGE (package_id) ON DELETE CASCADE,
    CONSTRAINT FK_PACKAGE_RESOURCE_RESOURCE FOREIGN KEY (resource_id)
        REFERENCES dbo.RESOURCE (resource_id)
);
GO

-- ----------------------------------------------------------------------------
-- 18. BẢNG RESERVATION_SPACE (Quan hệ trung gian M:N - STT 18)
-- ----------------------------------------------------------------------------
CREATE TABLE dbo.RESERVATION_SPACE (
    reservation_id INT NOT NULL,
    space_id       INT NOT NULL,
    CONSTRAINT PK_RESERVATION_SPACE PRIMARY KEY CLUSTERED (reservation_id, space_id),
    CONSTRAINT FK_RESERVATION_SPACE_RESERVATION FOREIGN KEY (reservation_id)
        REFERENCES dbo.RESERVATION (reservation_id) ON DELETE CASCADE,
    CONSTRAINT FK_RESERVATION_SPACE_SPACE FOREIGN KEY (space_id)
        REFERENCES dbo.CREATIVE_SPACE (space_id)
);
GO

-- ----------------------------------------------------------------------------
-- 19. BẢNG RESERVATION_RESOURCE (Quan hệ trung gian M:N - STT 19)
-- ----------------------------------------------------------------------------
CREATE TABLE dbo.RESERVATION_RESOURCE (
    reservation_id INT NOT NULL,
    resource_id    INT NOT NULL,
    quantity       INT NOT NULL DEFAULT 1,
    CONSTRAINT PK_RESERVATION_RESOURCE PRIMARY KEY CLUSTERED (reservation_id, resource_id),
    CONSTRAINT FK_RESERVATION_RESOURCE_RESERVATION FOREIGN KEY (reservation_id)
        REFERENCES dbo.RESERVATION (reservation_id) ON DELETE CASCADE,
    CONSTRAINT FK_RESERVATION_RESOURCE_RESOURCE FOREIGN KEY (resource_id)
        REFERENCES dbo.RESOURCE (resource_id)
);
GO

-- ----------------------------------------------------------------------------
-- 20. BẢNG SESSION_RESOURCE (Quan hệ trung gian M:N - STT 20)
-- ----------------------------------------------------------------------------
CREATE TABLE dbo.SESSION_RESOURCE (
    session_id  INT NOT NULL,
    resource_id INT NOT NULL,
    quantity    INT NOT NULL DEFAULT 1,
    CONSTRAINT PK_SESSION_RESOURCE PRIMARY KEY CLUSTERED (session_id, resource_id),
    CONSTRAINT FK_SESSION_RESOURCE_SESSION FOREIGN KEY (session_id)
        REFERENCES dbo.SERVICE_SESSION (session_id) ON DELETE CASCADE,
    CONSTRAINT FK_SESSION_RESOURCE_RESOURCE FOREIGN KEY (resource_id)
        REFERENCES dbo.RESOURCE (resource_id)
);
GO

-- ----------------------------------------------------------------------------
-- 21. BẢNG WORKSHOP_REGISTRATION (Quan hệ trung gian M:N - STT 21)
-- ----------------------------------------------------------------------------
CREATE TABLE dbo.WORKSHOP_REGISTRATION (
    user_id       INT NOT NULL,
    workshop_id   INT NOT NULL,
    registered_at DATETIME2(0) NOT NULL DEFAULT SYSDATETIME(),
    CONSTRAINT PK_WORKSHOP_REGISTRATION PRIMARY KEY CLUSTERED (user_id, workshop_id),
    CONSTRAINT FK_WORKSHOP_REG_USER FOREIGN KEY (user_id)
        REFERENCES dbo.[USER] (user_id),
    CONSTRAINT FK_WORKSHOP_REG_WORKSHOP FOREIGN KEY (workshop_id)
        REFERENCES dbo.WORKSHOP (workshop_id) ON DELETE CASCADE
);
GO

PRINT N'>> Created all 21 tables successfully according to Chapter 1-3 LaTeX & plan_db.md.';
GO
