# TDC 2026 — Test Automation

Robot Framework test suites for the MSTB Test Design Competition 2026 test object
(Sauce Demo Shopify store). This repository holds the Part 2 (test automation)
work product only.

## Stack

- Robot Framework 7.4.2
- Browser library 20.1.0 (Playwright engine) driving Brave (Chromium)
- Python 3.11 via the Windows `py` launcher

## Architecture — Page Object Model

The suites are organised in two layers:

- `resources/pages/` — **page objects**: one resource file per store page (plus the
  `product_listing` component and the `layout` chrome), holding that page's element
  locators and named actions. Every locator lives in exactly one file.
- `tests/` — **test suites**: business-readable steps only, mirroring the team Test
  Case Specification 1:1 (test name = TCS id + title; tags carry suite/use-case/
  priority/type). Tests contain **no element locators** (verifiable:
  `grep "css=\|xpath=" tests/*.robot` returns nothing).
- `resources/common.resource` — browser session management, network emulation
  (client-side offline), fresh-context helper, store URL and headless toggle.

A store theme change is absorbed by editing one page file, not every suite — the
property that makes the suites reusable for maintenance testing across future
versions of the store.

## Setup

```
py -m pip install -r requirements.txt
py -m Browser.entry init
```

The Brave executable path used by the suites is documented in `requirements.txt`.

## Run

```
py -m robot -d results tests                     # all suites
py -m robot -d results tests/ts05_add_to_cart.robot   # one suite
py -m robot --variable HEADLESS:True -d results tests # unattended
py -m robot --include TS-02 -d results tests          # by trace tag
```

Results (log.html, report.html, output.xml, failure screenshots) are written to
`results/`, which is not tracked in git.

## Suites

| File | Status | Notes |
|---|---|---|
| `tests/smoke_critical_path.robot` | Active — 7/7 passing | Suite A: cross-module guest critical-path smoke; also the historical prototype that validated the tool selection on both candidate stacks |
| `tests/ts01_store_access.robot` | Active — 4/0/3 | TS-01 Store Access (UC-01): TC-01-001..007 mirrored from the TCS — 4 automated, 3 documented SKIPs (not executable on a live shared store) |
| `tests/ts02_product_catalogue.robot` | Active — 5/0/1 | TS-02 Product Catalogue (UC-02): TC-02-001..006 — 5 automated (incl. catalogue→PDP click navigation, no-results empty state, nonexistent-product 404), 1 documented SKIP (data-fault injection impossible on a live store) |
| `tests/ts03_product_detail.robot` | Active — 4/0/4 | TS-03 Product Detail (UC-03): TC-03-001..008 — 4 automated (PDP completeness, back-button return, description-optional purchase path, sold-out view), 4 documented SKIPs (fault injection; breadcrumb trail has no broken link and no category level; no description-expansion control) |
| `tests/ts04_product_variants.robot` | Active — 4/0/3 | TS-04 Variants (UC-04): TC-04-001..007 — 6 automated with runtime data guards (selection applied, final-choice persistence, default preselected, refresh state, size+colour), 1 designed SKIP (stock cannot be manipulated) |
| `tests/ts05_add_to_cart.robot` | Active — 5/0/1 | TS-05 Add to Cart (UC-05): TC-05-001..006 — 5 automated (add with variant, duplicate consolidation, sequential additions, offline add leaves cart unchanged, sold-out prevention; cart-clearing teardown), 1 designed SKIP (rapid-click timing) |

The two retired SeleniumLibrary suites were removed from the working tree after the
stack retirement; they remain available in the git history.

## Rules of engagement

The test object is a live, shared store used by other competing teams:

- Run suites sparingly and human-paced (normal traffic volumes only).
- Never place real orders — execution stops at checkout data entry.
- Functional UI testing only; no load, security or availability testing.
