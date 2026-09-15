-- ============================================================================
-- SCRIPT 01: CREATE DATABASE
-- Project: Platform Connecting Film Photography Community with Darkroom & Studio Services
-- Target DBMS: Microsoft SQL Server 2022
-- ============================================================================

USE master;
GO

IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = N'FilmPhotographyDB')
BEGIN
    CREATE DATABASE FilmPhotographyDB
    COLLATE Vietnamese_100_CI_AS;
    PRINT N'>> Database FilmPhotographyDB created successfully.';
END
ELSE
BEGIN
    PRINT N'>> Database FilmPhotographyDB already exists.';
END
GO

USE FilmPhotographyDB;
GO

ALTER DATABASE FilmPhotographyDB SET RECOVERY SIMPLE;
ALTER DATABASE FilmPhotographyDB SET AUTO_UPDATE_STATISTICS ON;
GO

PRINT N'>> Database configuration applied successfully.';
GO
