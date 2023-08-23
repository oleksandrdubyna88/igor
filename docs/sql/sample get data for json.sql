BEGIN TRY DECLARE @hwb VARCHAR(40),
                       @bdy VARCHAR(4000);


SET @hwb = 'xxA110077';


SELECT a.awbid,
       [partyType] = 'Shipper',
       c.Name,
       c.Address1,
       c.Address2,
       c.City,
       c.State,
       c.Zip,
       c.Country INTO #tempTable
FROM [TGOPSDOM].[TransGroup].[dbo].[AWB_SHIPPER] c
INNER JOIN TGOPSDOM.TransGroup.dbo.AWB a ON a.AWBID = c.AWBID
WHERE a.HWB = @hwb
UNION
SELECT b.awbid,
       [partyType] = 'Consignee',
       d.Name,
       d.Address1,
       d.Address2,
       d.City,
       d.State,
       d.Zip,
       d.Country
FROM [TGOPSDOM].[TransGroup].[dbo].[AWB_Consignee] d
INNER JOIN TGOPSDOM.TransGroup.dbo.AWB b ON b.AWBID = d.AWBID
WHERE b.HWB = @hwb;


SELECT *
FROM #tempTable
SELECT senderId = 'TGOPS' ,
       recipientId = 'SGL',
       shipmentType = 'HOUSE' ,
       modeOfTransport = 'ROAD' ,
       containerType = 'BreakBullk' ,
       serviceLevel = 'Economy' ,
       TRIM(a.HWB) AS localShipmentNumber ,
       'NORAM-'+TRIM(a.HWB) as globalShipmentNumber ,

  ( SELECT c.Pieces as [quantity],
           c.Weight as [grossWeight],
           c.FghtDesc as [goodDescription],

     ( SELECT c.Pieces as [quantity],
              c.Weight as [grossWeight],
              c.FghtDesc as [goodDescription],

        ( SELECT b.Pieces as [quantity],
                 b.Height as [height],
                 b.Length as [length] ,
                 b.Width as [width],
                 b.Weight as [grossWeight],
                 b.DimUnitMeas as [dimensionalUnit]
         FROM [TGOPSDOM].[TransGroup].[dbo].[AWB_DIM] b
         WHERE b.AWBID = a.AWBID
           FOR JSON AUTO ) AS [dimensions]
      FROM [TGOPSDOM].[TransGroup].[dbo].[AWB_PIECES] c
      WHERE c.AWBID = a.AWBID
        FOR JSON AUTO ) AS [items]
   FROM [TGOPSDOM].[TransGroup].[dbo].[AWB_PIECES] c
   WHERE c.AWBID = a.AWBID
     FOR JSON AUTO ) AS [goods],

  ( SELECT k.partyType,
           k.Name as [companyName],
           k.Address1 as addressLine1,
           k.Address2 as addressLine2,
           k.[state],
           k.zip as zipCode,
           k.city,
           TRIM(k.Country) as countryCode
   FROM #tempTable k
   WHERE k.awbid = a.awbid
     FOR JSON AUTO ) AS [parties]
FROM TGOPSDOM.TransGroup.dbo.AWB a
WHERE a.HWB = @hwb
  FOR JSON AUTO END TRY BEGIN CATCH PRINT @@ERROR;

END CATCH IF OBJECT_ID('tempdb..#tempTable') IS NOT NULL -- Check for table existence

DROP TABLE #tempTable;