GO

IF NOT EXISTS (SELECT * FROM information_schema.tables WHERE table_name = 'Test1') 
BEGIN
CREATE TABLE Test1 (
    guid UNIQUEIDENTIFIER PRIMARY KEY,
    senderId NVARCHAR(MAX),
    recipientId NVARCHAR(MAX),
    shipmentType NVARCHAR(MAX), 
    globalShipmentNumber NVARCHAR(MAX) 
);
END;

--oauth2
DECLARE @outputString NVARCHAR(MAX);
EXEC [dbo].[GetKey] '11', '22', @outputString OUTPUT;

--GET
DECLARE @result INT, @status INT = 1, @statusText VARCHAR(100), @responseText NVARCHAR(MAX), @postData NVARCHAR(MAX), @authHeader NVARCHAR(MAX), @urlString NVARCHAR(MAX)
SELECT  @urlString = 'https://localhost:5001/'
SELECT @authHeader =  @outputString;

EXEC    @result = dbo.usp_sys_InvokeWebService 'GET', @urlString, @timeout = 5
                        , @status = @status OUTPUT, @statusText = @statusText OUTPUT, @responseText = @responseText OUTPUT, @authHeader = @authHeader
SELECT  @result AS result, @status AS status, @statusText AS statusText, @responseText AS responseText

--Saving data from get request to database 
IF @result = 0
BEGIN
INSERT INTO Test1 (guid, senderId, recipientId, shipmentType, globalShipmentNumber)
SELECT 
    JSON_VALUE(@ResponseText, '$.guid') AS guid,
    JSON_VALUE(@ResponseText, '$.senderId') AS senderId,
    JSON_VALUE(@ResponseText, '$.recipientId') AS recipientId,
    JSON_VALUE(@ResponseText, '$.shipmentType') AS shipmentType,
    JSON_VALUE(@ResponseText, '$.globalShipmentNumber') AS globalShipmentNumber;
END