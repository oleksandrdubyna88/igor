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

--Generating data for request body
SET @postDataOld =

( SELECT TOP 1
    *
FROM Test1
FOR JSON AUTO);

DECLARE @hwb VARCHAR(40);
DECLARE @jsonStr NVARCHAR(MAX);

SET @hwb = 'xxA110077';
EXEC dbo.GetShipmentDetails @hwb, @jsonStr OUTPUT;

IF (@jsonStr IS NULL OR @jsonStr = '')
BEGIN
	SET @postData = '[{
	    "senderId": "TGOPS",
		"recipientId": "SGL",
	    "shipmentType": "HOUSE",
	    "modeOfTransport": "ROAD",
		"localShipmentNumber": "22234",
	    "globalShipmentNumber": "NORAM-99891"
	}]';
END
ELSE
BEGIN
	SET @postData = @jsonStr;
END

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
                    CONVERT(NVARCHAR(36), NEWID()))
			END
ELSE
	BEGIN
					SELECT @DIHNumber = JSON_VALUE(@ResponseText, '$.data.failRowsData[0].globalShipmentNumber');
					INSERT INTO FAIL_LOG 
                    (DIHNumber, 
                    ErrorMessage, 
                    ProcName, 
                    rowguid,
					RequestDate, 
                    ResponseDate, 
                    MessageBody, 
                    ResponseBody)
				VALUES (
                    @DIHNumber ,
                    JSON_VALUE(@ResponseText, '$.data.failRowsData[0].errorMessage'), 
                    @httpTypeMethod, 
                    CONVERT(NVARCHAR(36), NEWID()),
					@RequestDate, 
                    @ResponseDate, 
                    @PostData, 
                    @ResponseText)
	END


DECLARE @profile_name NVARCHAR(128);
DECLARE @recipients NVARCHAR(MAX);
DECLARE @subject NVARCHAR(255);
DECLARE @body NVARCHAR(MAX);
DECLARE @body_format NVARCHAR(20);

SET @profile_name = 'SQLALERTS';
SET @recipients = 'alex@yahoo.com;alex2';
SET @subject = 'Error in Ops to DIH Sync process';
SET @body = 'Your email body content here.';
SET @body_format = 'HTML';

--EXEC [dbo].[SendEmailAndLog] @profile_name, @recipients, @subject, @body, @body_format;

INSERT INTO [dbo].[EMAIL_LOG] ([To], [Subject], [Message], [DateAdded], [rowguid])
VALUES (@recipients, @subject, @body, GETDATE(), NEWID());