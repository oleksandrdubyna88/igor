USE [ttt];

ALTER TABLE [dbo].[FAIL_LOG]
ADD [RequestDate] DATETIME,
    [ResponseDate] DATETIME,
    [MessageBody] NVARCHAR(MAX),
    [ResponseBody] NVARCHAR(MAX);
DROP COLUMN [DateAdded];