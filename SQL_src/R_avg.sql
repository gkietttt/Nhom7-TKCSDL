USE FilmPhotographyDB;
GO

;WITH StorageStats AS
(
    SELECT
        t.object_id,
        t.name AS TableName,
        MAX(p.rows) AS [RowCount],
        SUM(a.total_pages) AS TotalPages,
        SUM(a.used_pages) AS UsedPages,
        SUM(a.data_pages) AS DataPages,
        SUM(a.total_pages) * 8 AS ReservedSpaceKB,
        SUM(a.data_pages) * 8 AS DataSpaceKB
    FROM sys.tables AS t
    INNER JOIN sys.indexes AS i
        ON t.object_id = i.object_id
    INNER JOIN sys.partitions AS p
        ON i.object_id = p.object_id
       AND i.index_id = p.index_id
    INNER JOIN sys.allocation_units AS a
        ON p.partition_id = a.container_id
    WHERE t.is_ms_shipped = 0
    GROUP BY t.object_id, t.name
),
RowStats AS
(
    SELECT
        ips.object_id,
        SUM(ips.record_count) AS PhysicalRowCount,
        CAST(
            SUM(ips.record_count * ips.avg_record_size_in_bytes)
            / NULLIF(SUM(ips.record_count), 0)
            AS DECIMAL(10, 2)
        ) AS AvgRecordSizeBytes
    FROM sys.dm_db_index_physical_stats(
        DB_ID(),
        NULL,
        NULL,
        NULL,
        'DETAILED'
    ) AS ips
    INNER JOIN sys.indexes AS i
        ON ips.object_id = i.object_id
       AND ips.index_id = i.index_id
    WHERE ips.index_level = 0
      AND i.index_id = 1
      AND i.type = 1
      AND ips.record_count > 0
    GROUP BY ips.object_id
)
SELECT
    s.TableName,
    s.[RowCount],
    r.AvgRecordSizeBytes AS [R_AverageBytes],
    FLOOR(8060.0 / NULLIF(r.AvgRecordSizeBytes, 0)) AS [BFR],
    CEILING(
        s.[RowCount] / NULLIF(FLOOR(8060.0 / NULLIF(r.AvgRecordSizeBytes, 0)), 0.0)
    ) AS [EstimatedDataPages],
    s.TotalPages,
    s.UsedPages,
    s.DataPages,
    s.ReservedSpaceKB,
    s.DataSpaceKB
FROM StorageStats AS s
LEFT JOIN RowStats AS r
    ON s.object_id = r.object_id
ORDER BY s.DataSpaceKB DESC, s.TableName;
GO