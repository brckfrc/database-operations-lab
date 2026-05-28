-- Setup pg_cron
CREATE EXTENSION IF NOT EXISTS pg_cron;

-- The actual pgbackrest backup commands run via system cron.
-- We use pg_cron just for visibility, creating job records for the same schedule.
-- Since pg_cron cannot run OS commands directly, we will just use it to log that a backup should have run,
-- or we can try to call a dummy SELECT or use COPY if we wanted. But the PLAN says "pg_cron: cron.job tablosuna kayit eklemek ve cron.job_run_details loglarini video'da gostermek icin kullanilir".
-- Let's just create dummy jobs that mirror the schedule so we have them in pg_cron.

SELECT cron.schedule('incremental_backup', '0 2 * * *', 'SELECT 1 AS incremental_backup_triggered');
SELECT cron.schedule('differential_backup', '0 3 * * 0', 'SELECT 1 AS differential_backup_triggered');
SELECT cron.schedule('full_backup', '0 4 1 * *', 'SELECT 1 AS full_backup_triggered');
