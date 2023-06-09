USE [master]
GO

IF DB_ID('$(MSSQL_DB_DEFAULT)') IS NOT NULL
    SET NOEXEC ON

CREATE DATABASE [$(MSSQL_DB_DEFAULT)];
GO

CREATE LOGIN [$(MSSQL_DB_USERNAME)] WITH PASSWORD = '$(MSSQL_DB_PASSWORD)', DEFAULT_DATABASE=[$(MSSQL_DB_DEFAULT)], CHECK_EXPIRATION=OFF, CHECK_POLICY=ON;
GO

CREATE USER [$(MSSQL_DB_USERNAME)] FOR LOGIN [$(MSSQL_DB_USERNAME)];
GO

ALTER SERVER ROLE sysadmin ADD MEMBER [$(MSSQL_DB_USERNAME)];
GO