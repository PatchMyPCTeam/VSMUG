USE SUSDB

IF EXISTS (
    SELECT *
    FROM sys.indexes AS si
    JOIN sys.objects AS so on si.object_id=so.object_id
    JOIN sys.schemas AS sc on so.schema_id=sc.schema_id
    WHERE 
		(so.name = 'tbLocalizedPropertyForRevision' /* Table */
        AND si.name = 'nclLocalizedPropertyID' /* Index */))
PRINT 'nclLocalizedPropertyID index exists'
ELSE PRINT 'nclLocalizedPropertyID DOES NOT EXIST';
GO

IF EXISTS (
    SELECT *
    FROM sys.indexes AS si
    JOIN sys.objects AS so on si.object_id=so.object_id
    JOIN sys.schemas AS sc on so.schema_id=sc.schema_id
    WHERE 
		(so.name = 'tbRevisionSupersedesUpdate' /* Table */
        AND si.name = 'nclSupercededUpdateID' /* Index */))
PRINT 'nclSupercededUpdateID index exists'
ELSE PRINT 'nclSupercededUpdateID DOES NOT EXIST';
GO
