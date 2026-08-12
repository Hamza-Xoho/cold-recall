---
type: source-map
subject: ""
book: ""
author: ""
edition: ""
file: ""                 # relative path, e.g. "Library/Avery — Oral Histology 3e.pdf"
page_offset: 0           # printed page 1 = PDF page (page_offset + 1)
created: ""
---

# {{title}}

<!-- Navigation for one source PDF. Sections, not chapters — a chapter is 40–60 pages
     and is not one session's worth. A section is 4–10 pages.

     The PDF pp. column is what sessions actually read from. Printed pp. is kept only
     so you can find the same place in a physical copy. Never read from the printed
     column: front matter shifts the numbering, usually by 10–30 pages. -->

**File:** `Library/<filename>.pdf`
**Page offset:** printed page 1 = PDF page `<n>`. Add `<n − 1>` to any printed page number.

---

## Ch <n> — <Chapter title>

| §   | Section | Printed pp. | PDF pp. | Concept | Status |
| --- | ------- | ----------- | ------- | ------- | ------ |
| 1   |         |             |         |         |        |
| 2   |         |             |         |         |        |
| 3   |         |             |         |         |        |

## Ch <n+1> — <Chapter title>

| §   | Section | Printed pp. | PDF pp. | Concept | Status |
| --- | ------- | ----------- | ------- | ------- | ------ |
| 1   |         |             |         |         |        |

---

<!-- Concept and Status stay empty until a session commits a note against that row.
     Filled in over time, this table becomes the honest coverage view for the book:
     what has been mined, what has only been read, and what has never been opened. -->
