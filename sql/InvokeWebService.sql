IF OBJECT_ID('InvokeWebService') IS NOT NULL DROP PROC InvokeWebService
GO
/*
DECLARE @Result INT, @Status INT, @StatusText VARCHAR(100), @ResponseText NVARCHAR(MAX)
EXEC    @Result = dbo.usp_sys_InvokeWebService 'GET', 'http://api.sample.com/test/ial_ses/ial/sespa/pharma/', @Timeout = 5
                        , @Status = @Status OUTPUT, @StatusText = @StatusText OUTPUT, @ResponseText = @ResponseText OUTPUT
SELECT  @Result AS Result, @Status AS Status, @StatusText AS StatusText, @ResponseText AS ResponseText


DECLARE @Result INT, @Status INT, @StatusText VARCHAR(100), @PostData NVARCHAR(MAX)
SELECT  @PostData = '{ your JSON here }'
EXEC    @Result = dbo.usp_sys_InvokeWebService 'POST', 'http://api.sample.com/test/ial_ses/sespa/trn/', @Timeout = 5
                        , @PostData=@PostData, @Status = @Status OUTPUT, @StatusText = @StatusText OUTPUT
SELECT  @Result AS Result, @Status AS Status, @StatusText AS StatusText
*/

CREATE PROC InvokeWebService(
            @Verb           VARCHAR(100)
            , @Url          VARCHAR(1000)
            , @AuthHeader   VARCHAR(100)    = NULL
            , @ContentType  VARCHAR(100)    = NULL
            , @Accept       VARCHAR(100)    = NULL
            , @PostData     NVARCHAR(MAX)   = NULL
            , @Timeout      FLOAT           = NULL          -- in seconds
            , @NoRaiseError BIT             = 0
            , @Status       INT             = NULL OUTPUT 
            , @StatusText   VARCHAR(100)    = NULL OUTPUT 
            , @ResponseText NVARCHAR(MAX)   = NULL OUTPUT 
) WITH EXECUTE AS OWNER AS
/*------------------------------------------------------------------------

    Invoke web service endpoint

*/------------------------------------------------------------------------
SET         NOCOUNT ON

DECLARE     @RetVal         INT
            , @HObj         INT
            , @HResult      INT
            , @TimeoutMs    INT
            , @ErrSource    VARCHAR(255)
            , @ErrDescription VARCHAR(1000)

DECLARE     @TmpGetProperty TABLE(Value NVARCHAR(MAX))

--- init local vars and param defaults
SELECT      @RetVal = 0
            , @ContentType = COALESCE(@ContentType, CASE WHEN @PostData IS NOT NULL THEN 'application/json' END)
            , @TimeoutMs = @Timeout * 1000

BEGIN TRY
            IF          SUSER_NAME() <> 'sa' EXECUTE AS LOGIN = 'sa'

            EXEC        @HResult = dbo.sp_OACreate 'MSXML2.ServerXMLHTTP', @HObj OUTPUT
            IF          @HResult <> 0 GOTO QH

            IF          @TimeoutMs IS NOT NULL
            BEGIN
                        --- resolveTimeout, connectTimeout, sendTimeout, receiveTimeout
                        EXEC        @HResult = dbo.sp_OAMethod @HObj, 'SetTimeouts', NULL, 5000, 5000, @TimeoutMs, @TimeoutMs
                        IF          @HResult <> 0 GOTO QH
            END

            IF          @Status IS NOT NULL
            BEGIN
                        --- ignore server certificate errors
                        EXEC        @HResult = dbo.sp_OAMethod @HObj, 'SetOption', NULL, 2, 13056
                        IF          @HResult <> 0 GOTO QH
            END

            EXEC        @HResult = dbo.sp_OAMethod @HObj, 'Open', NULL, @Verb, @Url, 0 -- Async:=False
            IF          @HResult <> 0 GOTO QH

            IF          @AuthHeader IS NOT NULL
            BEGIN
                        EXEC        @HResult = dbo.sp_OAMethod @HObj, 'SetRequestHeader', NULL, 'Authorization', @AuthHeader 
                        IF          @HResult <> 0 GOTO QH
            END

            IF          @ContentType IS NOT NULL
            BEGIN
                        EXEC        @HResult = dbo.sp_OAMethod @HObj, 'SetRequestHeader', NULL, 'Content-Type', @ContentType
                        IF          @HResult <> 0 GOTO QH
            END

            IF          @Accept IS NOT NULL
            BEGIN
                        EXEC        @HResult = dbo.sp_OAMethod @HObj, 'SetRequestHeader', NULL, 'Accept', @Accept
                        IF          @HResult <> 0 GOTO QH
            END

            IF          @PostData IS NOT NULL
            BEGIN
                        EXEC        @HResult = dbo.sp_OAMethod @HObj, 'Send', NULL, @PostData
                        IF          @HResult <> 0 GOTO QH
            END
            ELSE BEGIN
                        EXEC        @HResult = dbo.sp_OAMethod @HObj, 'Send'
                        IF          @HResult <> 0 GOTO QH
            END

            EXEC        @HResult = dbo.sp_OAGetProperty @HObj, 'Status', @Status OUTPUT
            IF          @HResult <> 0 GOTO QH

            EXEC        @HResult = dbo.sp_OAGetProperty @HObj, 'StatusText', @StatusText OUTPUT
            IF          @HResult <> 0 GOTO QH

            INSERT      @TmpGetProperty
            EXEC        @HResult = dbo.sp_OAGetProperty @HObj, 'ResponseText'
            IF          @HResult <> 0 GOTO QH

            SELECT      TOP 1 @ResponseText = Value
            FROM        @TmpGetProperty
END TRY
BEGIN CATCH
            SELECT      @ErrSource = CONVERT(VARCHAR(50), ERROR_LINE())
                        , @ErrDescription = RTRIM(REPLACE(ERROR_MESSAGE(), CHAR(13) + CHAR(10), ' '))

            SELECT      @RetVal = 1
                        , @StatusText = @ErrDescription

            IF          COALESCE(@NoRaiseError, 0) = 0
            BEGIN
                        RAISERROR   ('Error on line %s: %s', 16, 1, @ErrSource, @ErrDescription)
            END
END CATCH

QH:
IF          @HResult <> 0
BEGIN
            SELECT      @RetVal = 1
                        , @StatusText = CONVERT(VARCHAR(50), CONVERT(BINARY(4), @HResult), 1)

            IF          COALESCE(@NoRaiseError, 0) = 0
            BEGIN
                        EXEC        dbo.sp_OAGetErrorInfo @HObj, @ErrSource OUTPUT, @ErrDescription OUTPUT
                        
                        SELECT      @ErrDescription = RTRIM(REPLACE(@ErrDescription, CHAR(13) + CHAR(10), ' '))

                        RAISERROR   ('Error in %s: %s (0x%08X)', 16, 1, @ErrSource, @ErrDescription, @HResult)
            END
END

IF          @HObj IS NOT NULL
BEGIN
            EXEC        dbo.sp_OADestroy @HObj
            SET         @HObj = NULL
END

RETURN      @RetVal