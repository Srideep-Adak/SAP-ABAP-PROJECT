# SAP-ABAP-PROJECT
# ZZ_VENDOR_INV_ALV

A custom SAP ABAP Vendor Invoice Aging Report developed using the modern `CL_SALV_TABLE` framework.

## Objective

The purpose of this project is to help the Accounts Payable team monitor vendor invoices with real-time aging buckets and vendor-wise totals.

The report combines:
- Open Vendor Items (`BSIK`)
- Cleared Vendor Items (`BSAK`)
- Vendor Master Data (`LFA1`)
- Accounting Header Data (`BKPF`)

---

## Features

- Dynamic invoice aging calculation
- Aging buckets:
  - Current
  - 1–30 Days
  - 31–60 Days
  - 61–90 Days
  - 90+ Days
- Vendor-wise subtotals
- Total invoice amount aggregation
- Modern OOP SALV Report
- Filters for Company Code, Vendor and Posting Date

---

## SAP Tables Used

| Table | Purpose |
|-------|----------|
| BSIK | Open Vendor Items |
| BSAK | Cleared Vendor Items |
| BKPF | Accounting Document Header |
| LFA1 | Vendor Master |

---

## How to Use

1. Open transaction `SE38`
2. Create report `ZZ_VENDOR_INV_ALV`
3. Paste the code from `ZZ_VENDOR_INV_ALV_FULL.abap`
4. Activate and execute
5. Enter company code/vendor filters and run the report

---

## Project Structure

```text
ZZ_VENDOR_INV_ALV/
│
├── ZZ_VENDOR_INV_ALV_FULL.abap
├── README.md
├── screenshots/
│   ├── welcome-screen.png
│   └── alv-output.png
## Project Structure
ZZ_VENDOR_INV_ALV/
│
├── ZZ_VENDOR_INV_ALV_FULL.abap
├── README.md
├── screenshots/
│   ├── welcome-screen.png
│   └── alv-output.png
```
---

## Future Improvements

* Drill-down to `FB03`
* Integration with `F-53`
* Layout save variants
* Export to Excel and PDF
* Fiori-based dashboard version

---

## Author

Srideep Adak
Roll Number: 23051631
SAP ABAP / KIIT University

```
```

