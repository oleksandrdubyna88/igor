/****** Object:  Table [dbo].[AWB_DIH_XRef]    Script Date: 8/22/2023 11:37:12 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AWB_DIH_XRef](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[AWBID] [int] NOT NULL,
	[DIHNumber] [nvarchar](40) NOT NULL,
	[IsInternational] [bit] NOT NULL,
	[UtcDateAdded] [datetime] NOT NULL,
	[rowguid] [uniqueidentifier] ROWGUIDCOL  NOT NULL,
 CONSTRAINT [PK_AWB_DIH_XRef] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[DIH_SERVICE_LOG]    Script Date: 8/22/2023 11:37:12 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DIH_SERVICE_LOG](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[RequestDate] [datetime] NOT NULL,
	[ResponseDate] [datetime] NULL,
	[MessageBody] [varchar](4000) NOT NULL,
	[ResponseBody] [varchar](4000) NULL,
	[ProcName] [nvarchar](50) NOT NULL,
	[rowguid] [uniqueidentifier] ROWGUIDCOL  NOT NULL,
 CONSTRAINT [PK_DIH_SERVICE_LOG] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[EMAIL_LOG]    Script Date: 8/22/2023 11:37:12 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[EMAIL_LOG](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[To] [varchar](255) NULL,
	[Subject] [varchar](255) NULL,
	[Message] [varchar](4000) NULL,
	[DateAdded] [datetime] NOT NULL,
	[rowguid] [uniqueidentifier] ROWGUIDCOL  NOT NULL,
 CONSTRAINT [PK_EmailLog] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[EndPoint]    Script Date: 8/22/2023 11:37:12 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[EndPoint](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[EndPointName] [varchar](255) NOT NULL,
	[EndPointUrl] [varchar](4000) NOT NULL,
	[ClientId] [varchar](4000) NULL,
	[ClientSecret] [varchar](4000) NULL,
	[rowguid] [uniqueidentifier] ROWGUIDCOL  NOT NULL,
 CONSTRAINT [PK_EndPoint] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[FAIL_LOG]    Script Date: 8/22/2023 11:37:12 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FAIL_LOG](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[DIHNumber] [nvarchar](40) NOT NULL,
	[ErrorMessage] [varchar](4000) NULL,
	[DateAdded] [datetime] NOT NULL,
	[ProcName] [nvarchar](50) NOT NULL,
	[rowguid] [uniqueidentifier] ROWGUIDCOL  NOT NULL,
 CONSTRAINT [PK_FAIL_LOG] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[AWB_DIH_XRef] ADD  CONSTRAINT [DF_AWB_DIH_XRef_IsInternational]  DEFAULT ((0)) FOR [IsInternational]
GO
ALTER TABLE [dbo].[AWB_DIH_XRef] ADD  CONSTRAINT [DF_AWB_DIH_XRef_DateAdded]  DEFAULT (getutcdate()) FOR [UtcDateAdded]
GO
ALTER TABLE [dbo].[AWB_DIH_XRef] ADD  CONSTRAINT [DF_AWB_DIH_XRef_rowguid]  DEFAULT (newid()) FOR [rowguid]
GO
ALTER TABLE [dbo].[EMAIL_LOG] ADD  CONSTRAINT [DF_EmailLog_DateAdded]  DEFAULT (getutcdate()) FOR [DateAdded]
GO
ALTER TABLE [dbo].[EMAIL_LOG] ADD  CONSTRAINT [DF_EmailLog_rowguid]  DEFAULT (newid()) FOR [rowguid]
GO
ALTER TABLE [dbo].[EndPoint] ADD  CONSTRAINT [DF_EndPoint_rowguid]  DEFAULT (newid()) FOR [rowguid]
GO
ALTER TABLE [dbo].[FAIL_LOG] ADD  CONSTRAINT [DF_FAIL_LOG_DateAdded]  DEFAULT (getutcdate()) FOR [DateAdded]
GO
ALTER TABLE [dbo].[FAIL_LOG] ADD  CONSTRAINT [DF_FAIL_LOG_rowguid]  DEFAULT (newid()) FOR [rowguid]
GO
/****** Object:  StoredProcedure [dbo].[ProcGetAuthToken]    Script Date: 8/22/2023 11:37:12 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[ProcGetAuthToken]
	-- Add the parameters for the stored procedure here
	@token VARCHAR(8000) OUTPUT
AS
BEGIN
	BEGIN TRY

		DECLARE @object INT, @hr INT;
		DECLARE @url VARCHAR(4000), @key VARCHAR(4000), @secret VARCHAR(4000), @body NVARCHAR(4000), @response NVARCHAR(4000), @contentType NVARCHAR(64);

		SELECT @url = EndPointUrl, @key = ClientId, @secret = ClientSecret FROM [EndPoint] WHERE EndPointName = 'AuthToken'; 

		SET @body = 'grant_type=client_credentials&client_id='+ @key +'&client_secret='+ @secret +'&scope=https://management.azure.com//.default';
		SET @contentType = 'application/x-www-form-urlencoded';

		EXEC @hr = sp_OACreate 'MSXML2.XMLHTTP', @object OUT; -- Opens the connection
		IF @hr <> 0 RAISERROR('Unable to open connection,', 10,1);

		EXEC @hr = sp_OAMethod @object, 'open', NULL, 'POST', @url, 'false' -- Specifies what action will be taken against the specified URL
		EXEC @hr = sp_OAMethod @object, 'setRequestHeader', NULL, 'Content-type', @contentType; -- Adds the content type header
		EXEC @hr = sp_OAMethod @object, 'send', NULL, @body -- Sends the specified message body
		EXEC @hr = sp_OAGetProperty @object, 'responseText', @response OUT;  --Gets the response text property from the response message

		-- Converts the JSON text to a key:value pair table and extracts the access_token value from the table.
		SELECT @token = 'Bearer ' + [value] FROM OPENJSON(@response) WHERE [key] = 'access_token'


	END TRY
	BEGIN CATCH
		SELECT ERROR_MESSAGE() AS ErrorMessage
	END CATCH
END
GO
