/*═══════════════════════════════════════════════════════════════════════
  SQL SERVER SETUP FOR POWER BI
  Companion script · DragoFab · github.com/ailinnesse/semantic-model

  Sets up a local SQL Server with four sample databases and a read-only
  login that Power BI can use.

  Written for SQL Server 2025 · September 2026

  ─────────────────────────────────────────────────────────────────────
  HOW TO USE THIS FILE

  Run one section at a time, in order. Highlight a section and press F5
  rather than running the whole file at once — sections 1 and 2 return
  values that you need for section 4.

  Sections marked LOOK are queries: they tell you something.
  Sections marked DO are changes: they alter the server.

    0  LOOK   Before you start
    1  LOOK   Where do data files go on this machine?
    2  LOOK   What's inside each backup?
    3  DO     Restore the databases
    4  DO     Create a login for Power BI
    5  DO     Give that login read access everywhere
    6  LOOK   Check it worked
    7  DO     Optional — cap SQL Server's memory

  Errors are explained in troubleshooting.md, next to this file.
═══════════════════════════════════════════════════════════════════════*/



/*───────────────────────────────────────────────────────────────────────
  0 · BEFORE YOU START
  ─────────────────────────────────────────────────────────────────────
  Two folders, created in Explorer before anything below will work:

    C:\SQLBackups    the four .bak files you downloaded
    C:\SQLData       where the restored databases will live

  C:\SQLData needs one extra step. Folders made at the root of C:\ do
  not inherit write permission for the SQL Server service account, so
  the restore fails with "Operating system error 5" even though the
  folder exists.

    Right-click C:\SQLData  →  Properties  →  Security  →  Edit  →  Add
    Type:  NT SERVICE\MSSQLSERVER    →  Check Names  →  OK
    Tick:  Full control              →  OK

  Prefer to skip that? Use the instance's own data folder instead — see
  section 1. It already has the right permissions. The paths are just
  much longer.
───────────────────────────────────────────────────────────────────────*/



/*───────────────────────────────────────────────────────────────────────
  1 · WHERE DO DATA FILES GO ON THIS MACHINE?          [LOOK]
  ─────────────────────────────────────────────────────────────────────
  Only needed if you are not using C:\SQLData. Whatever this returns
  can be pasted into the MOVE clauses in section 3 instead.
───────────────────────────────────────────────────────────────────────*/

SELECT SERVERPROPERTY('InstanceDefaultDataPath') AS DataPath,
       SERVERPROPERTY('InstanceDefaultLogPath')  AS LogPath;



/*───────────────────────────────────────────────────────────────────────
  2 · WHAT'S INSIDE EACH BACKUP?                       [LOOK]
  ─────────────────────────────────────────────────────────────────────
  A backup file remembers the folder layout of the machine it was made
  on. Those folders do not exist here, so every file inside has to be
  redirected with MOVE.

  MOVE takes the LOGICAL name of each file, not its file name. This is
  how you find out what those are.

  Run these one at a time and read the LogicalName column.
  Type D is a data file. Type L is the log.
───────────────────────────────────────────────────────────────────────*/

RESTORE FILELISTONLY FROM DISK = 'C:\SQLBackups\Contoso 100K.bak';
GO
RESTORE FILELISTONLY FROM DISK = 'C:\SQLBackups\Contoso 10M.bak';
GO
RESTORE FILELISTONLY FROM DISK = 'C:\SQLBackups\WideWorldImporters-Standard.bak';
GO
RESTORE FILELISTONLY FROM DISK = 'C:\SQLBackups\WideWorldImportersDW-Standard.bak';
GO



/*───────────────────────────────────────────────────────────────────────
  3 · RESTORE THE DATABASES                            [DO]
  ─────────────────────────────────────────────────────────────────────
  One MOVE clause per row that section 2 returned.

  File extensions are convention, not a rule:
    .mdf   primary data file
    .ndf   additional data file
    .ldf   transaction log

  If your logical names differ from the ones below, use yours.
  STATS = 5 prints progress every 5 percent.
───────────────────────────────────────────────────────────────────────*/

--  3a · Contoso 100K — the everyday teaching database
RESTORE DATABASE Contoso
  FROM DISK = 'C:\SQLBackups\Contoso 100K.bak'
  WITH MOVE 'Contoso 100K'     TO 'C:\SQLData\Contoso.mdf',
       MOVE 'Contoso 100K_log' TO 'C:\SQLData\Contoso.ldf',
       RECOVERY, STATS = 5;
GO


--  3b · Contoso 10M — big enough that slow DAX is visibly slow
RESTORE DATABASE Contoso10M
  FROM DISK = 'C:\SQLBackups\Contoso 10M.bak'
  WITH MOVE 'Contoso 10M'     TO 'C:\SQLData\Contoso10M.mdf',
       MOVE 'Contoso 10M_log' TO 'C:\SQLData\Contoso10M.ldf',
       RECOVERY, STATS = 5;
GO


--  3c · WideWorldImporters — a normalised transactional database.
--       Three files: note the extra .ndf in its own filegroup.
RESTORE DATABASE WideWorldImporters
  FROM DISK = 'C:\SQLBackups\WideWorldImporters-Standard.bak'
  WITH MOVE 'WWI_Primary'  TO 'C:\SQLData\WideWorldImporters.mdf',
       MOVE 'WWI_UserData' TO 'C:\SQLData\WideWorldImporters_UserData.ndf',
       MOVE 'WWI_Log'      TO 'C:\SQLData\WideWorldImporters.ldf',
       RECOVERY, STATS = 5;
GO


--  3d · WideWorldImportersDW — the warehouse version of the same data.
--       Same logical names as 3c. They are separate backups, so that
--       is not a conflict.
RESTORE DATABASE WideWorldImportersDW
  FROM DISK = 'C:\SQLBackups\WideWorldImportersDW-Standard.bak'
  WITH MOVE 'WWI_Primary'  TO 'C:\SQLData\WideWorldImportersDW.mdf',
       MOVE 'WWI_UserData' TO 'C:\SQLData\WideWorldImportersDW_UserData.ndf',
       MOVE 'WWI_Log'      TO 'C:\SQLData\WideWorldImportersDW.ldf',
       RECOVERY, STATS = 5;
GO



/*───────────────────────────────────────────────────────────────────────
  4 · CREATE A LOGIN FOR POWER BI                      [DO]
  ─────────────────────────────────────────────────────────────────────
  A LOGIN is server-level. It gets you through the front door.
  A USER is database-level. It is what that login is called inside one
  database. You need both — the users come in section 5.

  Windows authentication works fine for you. A separate login exists so
  you have a username and password that can be typed, shared, or shown
  on screen without exposing your own account.

  Requires Mixed Mode authentication. If this login later fails with
  "Login failed for user", that is almost certainly why — see
  troubleshooting.md.

  Change the password before running this.
───────────────────────────────────────────────────────────────────────*/

CREATE LOGIN pbi_demo
  WITH PASSWORD      = 'Demo-Lab-2026!',
       CHECK_POLICY  = ON,
       DEFAULT_DATABASE = Contoso;
GO



/*───────────────────────────────────────────────────────────────────────
  5 · GIVE THAT LOGIN READ ACCESS EVERYWHERE           [DO]
  ─────────────────────────────────────────────────────────────────────
  The straightforward version, repeated once per database:

      USE Contoso;
      CREATE USER pbi_demo FOR LOGIN pbi_demo;
      ALTER ROLE db_datareader ADD MEMBER pbi_demo;

  The version below does every user database at once, and is safe to
  run again after you add another one later.

  database_id > 4 skips the four databases SQL Server ships with:
  master, tempdb, model and msdb.
───────────────────────────────────────────────────────────────────────*/

DECLARE @sql nvarchar(max) = N'';

SELECT @sql = @sql + N'
USE ' + QUOTENAME(name) + N';
IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = ''pbi_demo'')
    CREATE USER pbi_demo FOR LOGIN pbi_demo;
ALTER ROLE db_datareader ADD MEMBER pbi_demo;'
FROM sys.databases
WHERE database_id > 4
  AND state       = 0;      -- online only

EXEC sp_executesql @sql;
GO



/*───────────────────────────────────────────────────────────────────────
  6 · CHECK IT WORKED                                  [LOOK]
  ─────────────────────────────────────────────────────────────────────
  Reconnect as pbi_demo using SQL Server Authentication, then run this.

  If it returns your four databases, Power BI will see them too. If it
  does not, Power BI will not either — fix it here first.
───────────────────────────────────────────────────────────────────────*/

SELECT SUSER_NAME() AS LoginName,
       DB_NAME()    AS CurrentDatabase;

SELECT name AS DatabaseName
FROM   sys.databases
WHERE  database_id > 4
ORDER  BY name;



/*───────────────────────────────────────────────────────────────────────
  7 · OPTIONAL — CAP SQL SERVER'S MEMORY               [DO]
  ─────────────────────────────────────────────────────────────────────
  Left alone, SQL Server will take as much RAM as it can get. On a
  laptop that is also running Power BI Desktop, give it a ceiling.

  6144 MB = 6 GB. On a 16 GB machine, 4096 is a safer number.
───────────────────────────────────────────────────────────────────────*/

EXEC sp_configure 'show advanced options', 1;
RECONFIGURE;

EXEC sp_configure 'max server memory (MB)', 6144;
RECONFIGURE;
GO
