CREATE PROCEDURE [dbo].[GetKey]
       -- Add the parameters for the stored procedure here
       @key NVARCHAR(MAX),
       @secret NVARCHAR(MAX),
       @token NVARCHAR(MAX) OUTPUT
AS
BEGIN
DECLARE @autResult INT, @autStatus INT = 1, @autStatusText VARCHAR(100), @autResponseText NVARCHAR(MAX), @autPostData NVARCHAR(MAX), @autUrlString NVARCHAR(MAX)
DECLARE @newGuidString NVARCHAR(36);

SET @newGuidString = CONVERT(NVARCHAR(36), NEWID());
SET @autPostData = 'grant_type=client_credentials&client_id='+ @key +'&client_secret='+ @secret +'&scope=https://management.azure.com//.default';
SELECT @autUrlString = 'https://localhost:5001/' + @NewGuidString + '/oauth2/v2.0/token';

EXEC    @autResult = dbo.usp_sys_InvokeWebService 'post', @autUrlString, @Timeout = 5
                        , @status = @autStatus OUTPUT, @statusText = @autStatusText OUTPUT, @responseText = @autResponseText OUTPUT, @postData=@autPostData

SET @token = @autResponseText
END
GO