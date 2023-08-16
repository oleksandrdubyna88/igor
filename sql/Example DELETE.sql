GO
--oauth2
DECLARE @outputString NVARCHAR(MAX);
EXEC [dbo].[GetKey] '11', '22', @outputString OUTPUT;

--DELETE
--Obtaining id
DECLARE @lastId UNIQUEIDENTIFIER

SELECT TOP 1 @lastId = guid
FROM Test1

DECLARE @result INT, @status INT = 1, @statusText VARCHAR(100), @responseText NVARCHAR(MAX), @postData NVARCHAR(MAX), @authHeader NVARCHAR(MAX), @urlString NVARCHAR(MAX)
SELECT  @urlString = 'https://localhost:5001/' + CAST(@lastId AS NVARCHAR(36))
SELECT  @authHeader = @outputString;

--Generating data for request body 
SET @postData = (
    SELECT TOP 1 *
    FROM Test1
    FOR JSON AUTO
);

EXEC    @result = dbo.usp_sys_InvokeWebService 'delete', @urlString, @timeout = 5
                        , @status = @status OUTPUT, @statusText = @statusText OUTPUT, @responseText = @responseText OUTPUT, @postData=@postData, @authHeader = @authHeader
SELECT  @result AS result, @status AS status, @statusText AS statusText, @responseText AS responseText