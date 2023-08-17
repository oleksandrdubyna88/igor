GO
--oauth2
DECLARE @outputString NVARCHAR(MAX);
EXEC [dbo].[GetKey] '11', '22', @outputString OUTPUT;

--POST
DECLARE @result INT, @status INT = 1, @statusText VARCHAR(100), @responseText NVARCHAR(MAX), @postData NVARCHAR(MAX), @authHeader NVARCHAR(MAX), @urlString NVARCHAR(MAX)
SELECT  @urlString = 'https://localhost:5001/'
SELECT  @authHeader = @outputString; 

--Generating data for request body 
SET @postData = (
    SELECT TOP 1 *
    FROM Test1
    FOR JSON AUTO
);

EXEC    @result = dbo.InvokeWebService 'post', @urlString, @timeout = 5
                        , @status = @status OUTPUT, @statusText = @statusText OUTPUT, @responseText = @responseText OUTPUT, @postData=@postData, @authHeader = @authHeader
SELECT  @result AS result, @status AS status, @statusText AS statusText, @responseText AS responseText