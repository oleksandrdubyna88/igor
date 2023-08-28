--POST
DECLARE 
	@authHeader VARCHAR(4000),
	@contentType VARCHAR(64),
	@httpTypeMethod VARCHAR(4000),
    @body VARCHAR(4000),
    @postDataOld VARCHAR(4000),
	@responseText VARCHAR(4000),
    @ret INT, 
    @status INT = 1,                                 
    @statusText VARCHAR(100),
    @url VARCHAR(4000),
    @DIHNumber VARCHAR(4000),
    @start DATETIME,
    @end DATETIME,

	@HResult INT

	DECLARE @object INT, @hr INT;

	DECLARE @key VARCHAR(4000), @secret VARCHAR(4000), @response NVARCHAR(4000)
	
SET @start = GETDATE();
SELECT @DIHNumber = '0110';
SELECT @httpTypeMethod = 'post';

SET @contentType = 'application/json';
SET @url = 'https://localhost:5001/';
	IF (@url IS NULL OR @url = '')
		BEGIN
			SELECT @url = EndPointUrl FROM [EndPoint] WHERE EndPointName = 'CreateShipment'
		END

DECLARE @hwb VARCHAR(40);
DECLARE @jsonStr NVARCHAR(MAX);

SET @hwb = 'xxA110077';
EXEC dbo.GetShipmentDetails @hwb, @jsonStr OUTPUT;

IF (@jsonStr IS NULL OR @jsonStr = '')
BEGIN
	SET @body = '[{
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
	SET @body = @jsonStr;
END


SET @start = GETDATE();

--oauth2
EXEC [dbo].[ProcGetAuthToken] @authHeader OUTPUT;

		EXEC @HResult = sp_OACreate 'MSXML2.XMLHTTP', @object OUT; -- Opens the connection
		IF @HResult <> 0 RAISERROR('Unable to open connection,', 10,1);
		EXEC @HResult = sp_OAMethod @object, 'open', NULL, @httpTypeMethod, @url, 'false' -- Specifies what action will be taken against the specified URL		
		EXEC @HResult = sp_OAMethod @object, 'setRequestHeader', NULL, 'Authorization', @authHeader; -- Adds the content type header	
		EXEC @HResult = sp_OAMethod @object, 'setRequestHeader', NULL, 'Content-type', 'application/json';
		EXEC @HResult = sp_OAMethod @object, 'send', NULL, @body -- Sends the specified message body		
		EXEC @HResult = sp_OAGetProperty @object, 'responseText', @responseText OUT;  --Gets the response text property from the response message
		EXEC @HResult = sp_OAGetProperty @object, 'Status', @Status OUTPUT

		select @body
		select @responseText
		select @response = [value] FROM OPENJSON(@responseText)
		SELECT @response
		select @status
		select JSON_VALUE(@ResponseText, '$.data.failData')

SET @end = GETDATE();

--SELECT @DIHNumber = JSON_VALUE(@ResponseText, '$.data.failRowsData[0].globalShipmentNumber');

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
                @start, 
                @end, 
                @body, 
                @ResponseText, 
                @httpTypeMethod,
                CONVERT(NVARCHAR(36), 
                NEWID()))
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
					@start, 
                    @end, 
                    @body, 
                    @ResponseText)
	END

DECLARE @profile_name NVARCHAR(128);
DECLARE @recipients NVARCHAR(MAX);
DECLARE @subject NVARCHAR(255);
DECLARE @bodyEmail NVARCHAR(MAX);
DECLARE @body_format NVARCHAR(20);

SET @profile_name = 'SQLALERTS';
SET @recipients = 'alex@yahoo.com;alex2';
SET @subject = 'Error in Ops to DIH Sync process';
SET @bodyEmail = 'Your email body content here.';
SET @body_format = 'HTML';

EXEC [dbo].[SendEmailAndLog] @profile_name, @recipients, @subject, @body, @body_format;

INSERT INTO [dbo].[EMAIL_LOG] (
			[To],
			[Subject], 
			[Message], 
			[DateAdded], 
			[rowguid])
	VALUES (
			@recipients,
			@subject,
			@bodyEmail,
			GETDATE(),
			NEWID());