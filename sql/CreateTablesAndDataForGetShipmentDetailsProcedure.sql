--AWB table
CREATE TABLE [dbo].[AWB] (
    [AWBID] INT PRIMARY KEY,
    [HWB] VARCHAR(40)
);

INSERT INTO [dbo].[AWB] ([AWBID], [HWB])
VALUES
    (1, 'HWB001'),
    (2, 'HWB002');

-- AWB_Consignee table
CREATE TABLE [dbo].[AWB_Consignee] (
    [AWBID] INT PRIMARY KEY,
    [Name] NVARCHAR(255),
    [Address1] NVARCHAR(255),
    [Address2] NVARCHAR(255),
    [City] NVARCHAR(255),
    [State] NVARCHAR(255),
    [Zip] NVARCHAR(20),
    [Country] NVARCHAR(255)
);

INSERT INTO [dbo].[AWB_Consignee] ([AWBID], [Name], [Address1], [City], [State], [Zip], [Country])
VALUES
    (1, 'Consignee 1', 'Address 1', 'City 1', 'State 1', 'Zip 1', 'Country 1'),
    (2, 'Consignee 2', 'Address 2', 'City 2', 'State 2', 'Zip 2', 'Country 2');

--AWB_DIM table
CREATE TABLE [dbo].[AWB_DIM] (
    [AWBID] INT,
    [Pieces] INT,
    [Height] DECIMAL(10, 2),
    [Length] DECIMAL(10, 2),
    [Width] DECIMAL(10, 2),
    [Weight] DECIMAL(10, 2),
    [DimUnitMeas] NVARCHAR(50)
);

INSERT INTO [dbo].[AWB_DIM] ([AWBID], [Pieces], [Height], [Length], [Width], [Weight], [DimUnitMeas])
VALUES
    (1, 2, 10.5, 20.5, 15.0, 30.0, 'cm'),
    (2, 1, 5.0, 15.0, 10.0, 18.5, 'cm');

--AWB_PIECES table
CREATE TABLE [dbo].[AWB_PIECES] (
    [AWBID] INT,
    [Pieces] INT,
    [Weight] DECIMAL(10, 2),
    [FghtDesc] NVARCHAR(255)
);

INSERT INTO [dbo].[AWB_PIECES] ([AWBID], [Pieces], [Weight], [FghtDesc])
VALUES
    (1, 2, 15.0, 'Piece 1'),
    (2, 1, 8.5, 'Piece 2');

--AWB_SHIPPER table
CREATE TABLE [dbo].[AWB_SHIPPER] (
    [AWBID] INT PRIMARY KEY,
    [Name] NVARCHAR(255),
    [Address1] NVARCHAR(255),
    [Address2] NVARCHAR(255),
    [City] NVARCHAR(255),
    [State] NVARCHAR(255),
    [Zip] NVARCHAR(20),
    [Country] NVARCHAR(255)
);

INSERT INTO [dbo].[AWB_SHIPPER] ([AWBID], [Name], [Address1], [City], [State], [Zip], [Country])
VALUES
    (1, 'Shipper 1', 'Address 1', 'City 1', 'State 1', 'Zip 1', 'Country 1'),
    (2, 'Shipper 2', 'Address 2', 'City 2', 'State 2', 'Zip 2', 'Country 2');
