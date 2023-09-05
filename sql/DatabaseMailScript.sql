-- Check the sysmail event log
USE msdb;
GO
SELECT * FROM dbo.sysmail_event_log;
