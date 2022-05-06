-- BACKUP SCRIPT --
DECLARE @BackupTableScript nvarchar(2000)
SET @BackupTableScript='SELECT * INTO Product_'+CONVERT(nvarchar,GETDATE(),112)+' FROM Product WHERE ModelYear != 2016';
EXEC(@BackupTableScript)

-- MODIFY SCRIPT --
DECLARE @ModifyTableScript nvarchar(2000)
SET @ModifyTableScript='UPDATE [dbo].Product_'+CONVERT(nvarchar,GETDATE(),112)+' 
SET ListPrice = 
CASE WHEN BrandId = 3 THEN ListPrice + (ListPrice* .2)
WHEN BrandId = 7 THEN ListPrice + (ListPrice* .1) 
ELSE ListPrice END;'
EXEC(@ModifyTableScript)