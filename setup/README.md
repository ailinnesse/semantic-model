# Setup

A local SQL Server with real sample databases, for Power BI work.
Nothing here needs a cloud subscription, and nothing expires.

Companion to the video
[Install SQL Server 2025, SSMS and Sample Databases for Power BI](https://youtu.be/NRyLbJUDTBs).

Allow about 30 minutes and 15 GB of disk.

## What to download

| | Link |
|---|---|
| SQL Server 2025 Developer Edition | [microsoft.com/sql-server/sql-server-downloads](https://www.microsoft.com/en-us/sql-server/sql-server-downloads) |
| SSMS 22 | Offered at the end of the SQL Server install |
| Contoso sample databases | [sql-bi/Contoso-Data-Generator → Releases → v1.0.0](https://github.com/sql-bi/Contoso-Data-Generator/releases) |
| WideWorldImporters sample databases | [microsoft/sql-server-samples → Releases](https://github.com/microsoft/sql-server-samples/releases/tag/wide-world-importers-v1.0) |
| Power BI Desktop | [powerbi.microsoft.com/desktop](https://powerbi.microsoft.com/desktop/) |

Which sample files to take:

- Contoso — `Contoso 100K.bak` for learning, `Contoso 10M.bak` for anything
  about performance. Both are under the v1.0.0 release; the later release only
  updates the generator.
- WideWorldImporters — `WideWorldImporters-Standard.bak` and
  `WideWorldImportersDW-Standard.bak`. Take the **Standard** builds. The Full
  ones use Enterprise-only features and will fail to restore on Developer
  Standard. Ignore anything marked `_old`.

Put all four in `C:\SQLBackups`.

## Order of operations

1. **Make sure your Windows account is a local administrator**, and install
   while signed in as that account. Whoever runs setup becomes SQL Server's
   administrator, and nobody else does.
2. **Install SQL Server**, choosing **Custom**. Three pages decide everything:
   - *Feature Selection* — Database Engine Services only. Untick **Azure
     Extension for SQL Server**, or setup will ask for an Azure subscription.
   - *Server Configuration* — tick **Grant Perform Volume Maintenance Task**.
     It makes the restores noticeably faster.
   - *Database Engine Configuration* — set **Mixed Mode**, give `sa` a
     password, and click **Add Current User**. Check your account actually
     appears in the list before continuing.
3. **Install SSMS 22** from the button on the completion screen. Core
   components only; you don't need the workloads.
4. **Connect** to `localhost` with Windows Authentication. Tick **Trust server
   certificate** — your local instance has a self-signed one, which is normal.
5. **Enable TCP/IP.** Run `SQLServerManager17.msc`, then SQL Server Network
   Configuration → Protocols for MSSQLSERVER → TCP/IP → Enable, and restart the
   service.
6. **Run [`sql-server-setup.sql`](sql-server-setup.sql)** section by section.
   It restores the databases, creates a read-only login for Power BI, and
   verifies the result. See below for why the restore looks the way it does.
7. **Connect Power BI Desktop** — Get Data → SQL Server → server `localhost`,
   database `Contoso`, Import mode.

## Why the restore needs MOVE

This is the part of the setup that confuses most people, and it is worth
understanding rather than copying.

A backup file remembers the folder layout of the machine it was made on. Those
folders almost certainly do not exist on yours. So every file inside the backup
has to be redirected to somewhere real, and that is what `MOVE` does.

`MOVE` needs the **logical** name of each file, not the file name you can see.
`RESTORE FILELISTONLY` is how you find them:

```sql
RESTORE FILELISTONLY FROM DISK = 'C:\SQLBackups\Contoso 100K.bak';
```

Read the `LogicalName` column, then write one `MOVE` clause per row. Type `D`
is a data file, type `L` is the log. Some backups have two files, some have
three.

The destination folder has to exist already. SQL Server will not create it.

## If something goes wrong

See [troubleshooting.md](troubleshooting.md). Five things commonly break, and
two of them look like password problems but aren't.

The two that catch almost everybody:

- **The person installing SQL Server becomes its administrator, and nobody
  else does.** Install using the Windows account you actually intend to use.
- **Operating system error 2 or 5 during a restore** is about the destination
  folder. Either it does not exist, or the SQL Server service account cannot
  write to it.

## Versions

Written against SQL Server 2025 (17.0) and SSMS 22, September 2026. Microsoft
changes these installers regularly. If your screens differ, open an issue.

---

Written up on LinkedIn:
[A free SQL Server on your own laptop takes about 30 minutes to set up](LINKEDIN-POST-URL)
