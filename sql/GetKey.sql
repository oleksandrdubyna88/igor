CREATE PROCEDURE [dbo].[GetKey]
       -- Add the parameters for the stored procedure here
       @key NVARCHAR(MAX),
       @secret NVARCHAR(MAX),
       @Token NVARCHAR(MAX) OUTPUT
AS
BEGIN
DECLARE @AutResult INT, @AutStatus INT = 1, @AutStatusText VARCHAR(100), @AutResponseText NVARCHAR(MAX), @AutPostData NVARCHAR(MAX), @AutUrlString NVARCHAR(MAX)
DECLARE @NewGuidString NVARCHAR(36);

SET @NewGuidString = CONVERT(NVARCHAR(36), NEWID());
SET @AutPostData = '{"body": "grant_type=client_credentials&client_id=key&client_secret=secret&scope=https://management.azure.com//.default"}';
SELECT @AutUrlString = 'https://localhost:44372/' + @NewGuidString + '/oauth2/v2.0/token';

EXEC    @AutResult = dbo.usp_sys_InvokeWebService 'post', @AutUrlString, @Timeout = 5
                        , @Status = @AutStatus OUTPUT, @StatusText = @AutStatusText OUTPUT, @ResponseText = @AutResponseText OUTPUT, @PostData=@AutPostData

SET @Token = @AutResponseText
END
GO