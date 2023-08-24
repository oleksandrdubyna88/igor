GO
--oauth2
DECLARE @outputString NVARCHAR(MAX);

EXEC [dbo].[GetKey] '11', '22',  @outputString OUTPUT;

--POST
DECLARE 
    @result INT, 
    @status INT = 1,                                 
    @statusText VARCHAR(100),
    @responseText NVARCHAR(MAX),
    @postData NVARCHAR(MAX),
    @postDataOld NVARCHAR(MAX),
    @authHeader NVARCHAR(MAX),
    @urlString NVARCHAR(MAX),
    @httpTypeMethod NVARCHAR(MAX),
    @DIHNumber NVARCHAR(MAX),
    @requestDate DATETIME,
    @responseDate DATETIME;

SELECT @urlString = 'https://localhost:5001/'
SELECT @authHeader = @outputString;
SELECT @httpTypeMethod = 'post';
SELECT @DIHNumber = '0110';

--Generating data for request body
SET @postDataOld =

( SELECT TOP 1
    *
FROM Test1
FOR JSON AUTO);

SET @postData = '{
    "senderId": "TGOPS",
	"recipientId": "SGL",
    "shipmentType": "HOUSE",
    "modeOfTransport": "ROAD",
	"localShipmentNumber": "22234",
    "globalShipmentNumber": "NORAM-99884"
}';

SET @requestDate = GETDATE();

EXEC @result = dbo.InvokeWebService @httpTypeMethod,
                                    @urlString,
                                    @timeout = 5 ,
                                    @status = @status OUTPUT,
                                    @statusText = @statusText OUTPUT,
                                    @responseText = @responseText OUTPUT,
                                    @postData= @postData,
                                    @authHeader = @authHeader
SELECT @result AS result,
    @status AS status,
    @statusText AS statusText,
    @responseText AS responseText

SET @responseDate = GETDATE();

IF @Status = 200 AND JSON_VALUE(@ResponseText, '$.data.failData') = 0
			BEGIN
				INSERT INTO DIH_SERVICE_LOG 
                    (RequestDate, 
                    ResponseDate, 
                    MessageBody, 
                    ResponseBody, 
                    ProcName, 
                    rowguid)
				VALUES (
                    @RequestDate, 
                    @ResponseDate, 
                    @PostData, 
                    @ResponseText, 
                    @httpTypeMethod, 
                    CONVERT(NVARCHAR(36), 
                    NEWID()))
			END
ELSE
	BEGIN
					INSERT INTO FAIL_LOG 
                    (DIHNumber, 
                    ErrorMessage, 
                    DateAdded, 
                    ProcName, 
                    rowguid)
				VALUES (
                    @DIHNumber ,
                    @ResponseText, 
                    GETDATE(), 
                    @httpTypeMethod, 
                    CONVERT(NVARCHAR(36), 
                    NEWID()))
	END