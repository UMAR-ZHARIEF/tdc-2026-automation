# TDC 2026 — Test Automation

Robot Framework test suites for the MSTB Test Design Competition 2026 test object
(Sauce Demo Shopify store). This repository holds the Part 2 (test automation)
work product only.

## Stack

- Robot Framework 7.4.2
- Browser library 20.1.0 (Playwright engine) driving Brave
- Python 3.11 via the Windows `py` launcher

## Setup

```
py -m pip install -r requirements.txt
py -m Browser.entry init
```

The Brave executable path used by the suites is documented in `requirements.txt`.

## Run

```
py -m robot -d results tests/smoke_critical_path.robot
```

Headless mode: edit the `headless=` argument of `New Browser` in the suite.
Results (log.html, report.html, output.xml, failure screenshots) are written to
`results/`, which is not tracked in git.

## Suites

| File | Status | Notes |
|---|---|---|
| `tests/smoke_critical_path.robot` | Active — 7/7 passing | Suite A: guest critical path (Browser library + Brave) |
| `tests/ts01_store_access.robot` | Active | TS-01 Store Access (UC-01): TC-01-001..007 mirrored from the TCS — 4 automated, 3 documented SKIPs (not executable on a live shared store) |
| `tests/smoke_install_check.robot` | Legacy | SeleniumLibrary + Edge (retired stack) |
| `tests/my_first_test.robot` | Legacy | SeleniumLibrary teaching example (retired stack) |

## Rules of engagement

The test object is a live, shared store used by other competing teams:

- Run suites sparingly and human-paced (normal traffic volumes only).
- Never place real orders — execution stops at checkout data entry.
- Functional UI testing only; no load, security or availability testing.
