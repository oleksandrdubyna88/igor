-- Retrieve all logins from old server
INSERT INTO [newserver].master.sys.server_principals (name, principal_id, sid, type_desc, create_date, is_disabled)
SELECT name, principal_id, sid, type_desc, create_date, is_disabled
FROM [oldserver].master.sys.server_principals
WHERE type_desc IN ('SQL_LOGIN', 'WINDOWS_LOGIN', 'WINDOWS_GROUP')

-- Copy login's server roles from 'old server' to 'new server'
INSERT INTO [newserver].master.sys.server_role_members (member_principal_id, role_principal_id)
SELECT member_principal_id, role_principal_id
FROM [oldserver].master.sys.server_role_members
WHERE member_principal_id IN (
    SELECT principal_id
    FROM [newserver].master.sys.server_principals
    WHERE type_desc IN ('SQL_LOGIN', 'WINDOWS_LOGIN', 'WINDOWS_GROUP')
)

-- Copy login's database roles from 'old server' to 'new server' for each user database
DECLARE @dbName NVARCHAR(128)
DECLARE db_cursor CURSOR FOR
SELECT name
FROM [newserver].master.sys.databases

OPEN db_cursor

FETCH NEXT FROM db_cursor INTO @dbName

WHILE @@FETCH_STATUS = 0
BEGIN
    EXEC('USE [' + @dbName + '];' +
         'INSERT INTO [test2].[' + @dbName + '].sys.database_principals (name, principal_id, sid, type_desc, default_schema_name, create_date, modify_date, is_disabled)
         SELECT name, principal_id, sid, type_desc, default_schema_name, create_date, modify_date, is_disabled
         FROM [test1].[' + @dbName + '].sys.database_principals
         WHERE type_desc IN (''SQL_USER'', ''WINDOWS_USER'', ''WINDOWS_GROUP'')')

    FETCH NEXT FROM db_cursor INTO @dbName
END

CLOSE db_cursor
DEALLOCATE db_cursor
