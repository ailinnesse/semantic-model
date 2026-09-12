# Troubleshooting

The five failures that come up most often when setting up a local SQL Server,
with what each one actually means.

---

## Login failed for user 'MicrosoftAccount\your@email.com'

**Error 18456.**

Your Windows profile is backed by a Microsoft account, so it authenticates
under a different name than the one Windows shows you. Windows says
`MACHINE\yourname`; SQL Server receives `MicrosoftAccount\your@email.com`.
If SQL Server was installed by a different account, there is no login for
yours.

Whoever runs SQL Server setup becomes its administrator, and nobody else does.
Install while signed in as the account you'll actually use, and make sure that
account is a local administrator first.

If you're already locked out, the supported recovery is to start the engine in
single-user mode and add your login:

1. `SQLServerManager17.msc` → SQL Server Services → SQL Server (MSSQLSERVER) →
   Properties → Startup Parameters → add `-mSQLCMD` → restart the service
2. From an **administrator** command prompt:
   ```
   sqlcmd -S localhost -E -C
   ```
   The `-C` matters. Without it you get a certificate error instead.
3. At the `1>` prompt:
   ```sql
   CREATE LOGIN [MicrosoftAccount\your@email.com] FROM WINDOWS;
   GO
   ALTER SERVER ROLE sysadmin ADD MEMBER [MicrosoftAccount\your@email.com];
   GO
   EXIT
   ```
4. Remove `-mSQLCMD` and restart the service again.

Uninstalling and reinstalling as the right account is also a perfectly good
fix, and often faster.

---

## Login failed for user 'pbi_demo'

**Error 18456 again, but a different cause — and it is usually not the
password.**

SQL Server will happily let you *create* a SQL login while the server is in
Windows Authentication mode. It just won't let that login authenticate. So the
login exists, `is_disabled` is 0, the password is right, and it still fails.

Check which mode you're in:

```sql
SELECT SERVERPROPERTY('IsIntegratedSecurityOnly') AS WindowsAuthOnly;
```

`1` means Windows only. `0` is what you want.

Fix: right-click the server in Object Explorer → Properties → Security → **SQL
Server and Windows Authentication mode**, then **restart the service**. The
setting is only read at startup, so skipping the restart makes it look like
nothing happened.

---

## Operating system error 2 (The system cannot find the file specified)

Seen during `RESTORE DATABASE`, on the *directory lookup*, not the backup.

The folder you named in the `MOVE` clause doesn't exist. SQL Server will not
create it for you.

Either create the folder first, or restore into the instance's own data
directory, which always exists:

```sql
SELECT SERVERPROPERTY('InstanceDefaultDataPath'),
       SERVERPROPERTY('InstanceDefaultLogPath');
```

---

## Operating system error 5 (Access is denied)

The follow-on from the one above, and the reason creating the folder isn't
always enough.

Folders created at the root of `C:\` don't inherit write permission for the
SQL Server service account. The folder exists, and SQL Server still can't
write to it.

Right-click the folder → Properties → Security → Edit → Add → type
`NT SERVICE\MSSQLSERVER` → Check Names → OK → **Full control**.

Or avoid it entirely by using the instance default data path, which already
has the right permissions.

---

## The certificate chain was issued by an authority that is not trusted

Appears in SSMS, sqlcmd, VS Code and Power BI — usually more than once, which
makes people think they have several problems.

It is transport-level and happens *before* authentication, so it is never a
credentials problem. Your local SQL Server has a certificate it signed itself,
and nothing trusts a certificate that vouches for itself.

- **SSMS / VS Code / Power BI** — tick **Trust server certificate** in the
  connection dialog
- **sqlcmd** — add `-C` to the command line

On your own machine this is fine: you know what the server is. On a production
server it would be worth a real certificate.

---

## Restore fails on WideWorldImporters-Full.bak

The Full builds use Enterprise-only features. On Developer Standard Edition
they won't restore.

Use `WideWorldImporters-Standard.bak` and
`WideWorldImportersDW-Standard.bak` instead. The Standard builds still include
the system-versioned temporal tables, so nothing useful is lost.
