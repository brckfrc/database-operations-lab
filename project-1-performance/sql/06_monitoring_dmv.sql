USE PerformanceLab;
GO

PRINT '=== DMV MONITORING SCRIPT ===';

-- 1. En çok okuma yapan ve kaynak tüketen ilk 5 sorguyu bulma (Query Stats)
PRINT '--- TOP 5 QUERY STATS BY LOGICAL READS ---';
SELECT TOP 5
    t.text AS query_text,
    s.execution_count,
    s.total_logical_reads,
    s.total_logical_reads / s.execution_count AS avg_logical_reads,
    s.total_worker_time AS cpu_time,
    s.total_elapsed_time
FROM sys.dm_exec_query_stats s
CROSS APPLY sys.dm_exec_sql_text(s.sql_handle) t
WHERE t.text NOT LIKE '%sys.dm_%' -- kendimizi hariç tutalım
ORDER BY s.total_logical_reads DESC;
GO

-- 2. Hangi indeksler ne kadar kullanılıyor? (Index Usage)
-- Hiç kullanılmayan veya çok az okunup sürekli update alan yazma-ağırlıklı indeksleri tespit eder.
PRINT '--- INDEX USAGE STATS ---';
SELECT 
    OBJECT_NAME(s.object_id) AS table_name,
    i.name AS index_name,
    s.user_seeks,
    s.user_scans,
    s.user_lookups,
    s.user_updates
FROM sys.dm_db_index_usage_stats s
JOIN sys.indexes i ON s.object_id = i.object_id AND s.index_id = i.index_id
WHERE OBJECTPROPERTY(s.object_id, 'IsUserTable') = 1
  AND DB_NAME(s.database_id) = 'PerformanceLab'
ORDER BY s.user_updates DESC, s.user_seeks ASC;
GO

-- 3. Eksik İndeks Önerileri (Missing Index Details)
-- SQL Server'ın "Şu indeksi ekleseydin şu sorgun %90 hızlanırdı" dediği yer.
PRINT '--- MISSING INDEX RECOMMENDATIONS ---';
SELECT TOP 5
    d.statement AS impact_table,
    d.equality_columns,
    d.inequality_columns,
    d.included_columns,
    ROUND(s.avg_total_user_cost * s.avg_user_impact * (s.user_seeks + s.user_scans), 0) AS estimated_improvement_score
FROM sys.dm_db_missing_index_group_stats s
JOIN sys.dm_db_missing_index_groups g ON s.group_handle = g.index_group_handle
JOIN sys.dm_db_missing_index_details d ON g.index_handle = d.index_handle
ORDER BY estimated_improvement_score DESC;
GO
