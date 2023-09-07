USE [master]
GO

-- Create the linked server
EXEC sp_addlinkedserver
    @server = 'tcp:investigating123.database.windows.net,1433',
    @srvproduct=N'SQL Server';

-- Set login credentials for the linked server
EXEC sp_addlinkedsrvlogin
    @rmtsrvname = 'tcp:investigating123.database.windows.net,1433',
    @useself = 'false',
    @rmtuser = 'admin123',
    @rmtpassword = '1waq!WAQ';

SELECT name FROM [tcp:investigating123.database.windows.net,1433].master.sys.databases;  
GO