GO

IF NOT EXISTS (SELECT * FROM information_schema.tables WHERE table_name = 'Test1') 
BEGIN
    CREATE TABLE Test1 (
        guid UNIQUEIDENTIFIER PRIMARY KEY,
        name NVARCHAR(255),
        datetimestamp DATETIME
    );
END;

DECLARE @Result INT, @Status INT = 1, @StatusText VARCHAR(100), @ResponseText NVARCHAR(MAX), @PostData NVARCHAR(MAX), @AuthHeader NVARCHAR(MAX), @UrlString NVARCHAR(MAX)
SELECT  @UrlString = 'https://localhost:44372/'

--GET
EXEC    @Result = dbo.usp_sys_InvokeWebService 'GET', @UrlString, @Timeout = 5
                        , @Status = @Status OUTPUT, @StatusText = @StatusText OUTPUT, @ResponseText = @ResponseText OUTPUT
SELECT  @Result AS Result, @Status AS Status, @StatusText AS StatusText, @ResponseText AS ResponseText

--Saving data from get request to database 
IF @Result = 0
BEGIN
    INSERT INTO Test1 (guid, name, datetimestamp)
    SELECT 
        JSON_VALUE(ResponseText, '$.id') AS guid,
        JSON_VALUE(ResponseText, '$.name') AS name,
        CONVERT(DATETIMEOFFSET, JSON_VALUE(ResponseText, '$.datetimestamp'), 127) AS datetimestamp
    FROM (SELECT @ResponseText AS ResponseText) AS SubQuery
END

--Generating data for request body 
SELECT TOP 1 @PostData = N'{"id": "' + CAST(guid AS NVARCHAR(36)) + '","name": "' + name + '","datetimestamp": "' + CONVERT(NVARCHAR(30), datetimestamp, 127) + '"}' FROM Test1 ORDER BY datetimestamp DESC

--POST
SELECT  @AuthHeader = 'aaaaeee'
EXEC    @Result = dbo.usp_sys_InvokeWebService 'post', @UrlString, @Timeout = 5
                        , @Status = @Status OUTPUT, @StatusText = @StatusText OUTPUT, @ResponseText = @ResponseText OUTPUT, @PostData=@PostData, @AuthHeader = @AuthHeader
SELECT  @Result AS Result, @Status AS Status, @StatusText AS StatusText, @ResponseText AS ResponseText

--PUT
EXEC    @Result = dbo.usp_sys_InvokeWebService 'put', @UrlString, @Timeout = 5
                        , @Status = @Status OUTPUT, @StatusText = @StatusText OUTPUT, @ResponseText = @ResponseText OUTPUT, @PostData=@PostData
SELECT  @Result AS Result, @Status AS Status, @StatusText AS StatusText, @ResponseText AS ResponseText

--Obtaining id
DECLARE @LastId UNIQUEIDENTIFIER

SELECT TOP 1 @LastId = guid
FROM Test1
ORDER BY datetimestamp DESC

--Url modification
SET @UrlString = @UrlString + CAST(@LastId AS NVARCHAR(36))

--DELETE
EXEC    @Result = dbo.usp_sys_InvokeWebService 'delete', @UrlString, @Timeout = 5
                        , @Status = @Status OUTPUT, @StatusText = @StatusText OUTPUT, @ResponseText = @ResponseText OUTPUT, @PostData=@PostData
SELECT  @Result AS Result, @Status AS Status, @StatusText AS StatusText, @ResponseText AS ResponseTextgi