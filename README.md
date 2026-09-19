# semantic-model

Building Power BI semantic models properly — star schemas, DAX,
TMDL and version control.

Companion repo for the [DragoFab](https://youtube.com/@dragofab)
series. Each part of the series adds to it.

## Contents

| | Folder | What's in it |
|---|---|---|
| 1 | [`setup`](setup) | A local SQL Server with real sample databases, so you have something to work against. Start here if you have nothing set up. |
| 2 | [`preparing-for-migration`](preparing-for-migration) | What to do before you rebuild: review the reports with the business, find what the old model actually uses, and check the documentation you generate from it. |
| 3 | [`building-the-model`](building-the-model) | Building the new model. Exploring the warehouse first, then several fact tables on one set of shared dimensions. |

## Getting started

Everything is built on a local SQL Server with free Microsoft and
SQLBI sample databases — no Azure subscription, nothing that
expires. Start with [`setup/sql-server-setup.sql`](setup/sql-server-setup.sql).

## Environment

SQL Server 2025 Developer Edition · SSMS 22 · Power BI Desktop ·
Tabular Editor 2 · DAX Studio · VS Code with the MSSQL and TMDL
extensions
