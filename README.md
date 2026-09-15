# SQLite Library System

A simple library database: manages members, books, and borrowing records using SQLite. Includes constraints (CHECK, FOREIGN KEY, UNIQUE), sample data, and reporting queries (JOIN, GROUP BY, HAVING, CASE, subqueries).


##  Contents

| File | Description |
|---|---|
| `kutuphane_db.sql` | Full database schema, sample data, and queries |
| `SQLite Kütüphane Sistemi Çözümü.db` | Pre-built database file with the script already run |

## Database Structure

**`uyeler`** (members)
- `id` — primary key
- `ad` — member name
- `yas` — age, constrained with `CHECK (yas > 13)`
- `sehir` — city, defaults to `'Erzincan'`
- `kayit_ani` — registration timestamp
- `eposta` — unique email

**`kitaplar`** (books)
- `id` — primary key
- `ad` — book title, `UNIQUE`

**`odunc`** (borrowing records)
- `uye_id`, `kitap_id` — composite primary key
- `gun` — days the book was kept
- `uye_id` → `uyeler(id)` **ON DELETE CASCADE**
- `kitap_id` → `kitaplar(id)`
- 
##  How to Run

### With DB Browser for SQLite
1. Open the `.db` file (**File → Open Database**)
2. Go to the **Execute SQL** tab
3. Paste in the contents of `kutuphane_db.sql`
4. Run it with **Execute all** (▶)

### From the terminal
```bash
sqlite3 "SQLite Kütüphane Sistemi Çözümü.db" < kutuphane_db.sql
```

> The script starts with `DROP TABLE IF EXISTS`, so it can be re-run any number of times — tables are rebuilt from scratch each time with no errors.

---

## Sample Queries

The script includes queries such as:

- JOIN queries combining member, book, and borrowing-duration info
- Member count by city, borrow count per book (GROUP BY)
- Members whose average borrowing duration exceeds 20 days (HAVING)
- CASE statements for overdue status (Normal / Warning / Overdue)
- Records above the overall average duration (subquery)

---

## Notes

- The attempts to insert `Ali Can` (age 10) and a borrowing record with a non-existent `uye_id` are kept **as comments** in the script, to illustrate how the `CHECK` and `FOREIGN KEY` constraints work.
- Deleting a book is blocked by the database while it has an active borrowing record (`ON DELETE CASCADE` is intentionally used only for `uye_id`).

## Tech Used

- SQLite 3
- DB Browser for SQLite (recommended GUI)
