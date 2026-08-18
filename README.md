# TDC 2026: Test Automation

Robot Framework test suites for the MSTB Test Design Competition 2026 test object
(Sauce Demo Shopify store). This repository holds the Part 2 (test automation)
work product only.

## Stack

- Robot Framework 7.4.2
- Browser library 20.1.0 (Playwright engine) driving Brave (Chromium)
- Python 3.11 via the Windows `py` launcher

## Architecture: Page Object Model

The suites are organised in two layers:

- `resources/pages/`: **page objects**, one resource file per store page (plus the
  `product_listing` component and the `layout` chrome), holding that page's element
  locators and named actions. Every locator lives in exactly one file.
- `tests/`: **test suites**, business-readable steps only, mirroring the team Test
  Case Specification 1:1 (test name = TCS id + title; tags carry suite/use-case/
  priority/type). Tests contain **no element locators** (verifiable:
  `grep "css=\|xpath=" tests/*.robot` returns nothing).
- `resources/common.resource`: browser session management, network emulation
  (client-side offline), fresh-context helper, store URL and headless toggle.

A store theme change is absorbed by editing one page file, not every suite; the
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

The inventory is the team's approved Test Case Specification mirrored 1:1: 18
suites, 108 tests, nothing else. Status columns are pass/fail/skip from the
authorized full live evidence run (`-v ALLOW_ORDERS:True`, order-creating
cases executed; a separate zero-order regression baseline exists); every fail is a
confirmed store defect and every skip carries its documented reason in the run
report.

| File | Status | Notes |
|---|---|---|
| `tests/ts01_store_access.robot` | 3/0/0 | TS-01 Store Access (UC-01): 3 cases, all automated |
| `tests/ts02_product_catalogue.robot` | 5/0/1 | TS-02 Product Catalogue (UC-02): 6 cases, 5 automated, 1 design-only SKIP (final4 realignment: the former empty-catalogue and detail-page-load-failure skips are replaced by two doable checks, a no-results search and a nonexistent-product 404, reusing the TS-17/TS-18 oracles) |
| `tests/ts03_product_detail.robot` | 6/0/2 | TS-03 Product Detail (UC-03): 8 cases: 6 automated, 2 design-only SKIPs |
| `tests/ts04_product_variants.robot` | 4/0/3 | TS-04 Variants (UC-04): 7 cases: 4 passing incl. the two re-pointed candidates (single-variant Striped top; two-dimension Noir jacket), 3 design-only SKIPs |
| `tests/ts05_add_to_cart.robot` | 5/0/1 | TS-05 Add to Cart (UC-05): 6 cases: 5 automated, 1 design-only SKIP (rapid-click timing) |
| `tests/ts06_cart_review.robot` | 5/0/2 | TS-06 Cart Review (UC-06): 7 cases: 5 automated, 2 design-only SKIPs |
| `tests/ts07_cart_management.robot` | 5/0/1 | TS-07 Cart Management (UC-07): 6 cases: 5 automated, 1 design-only SKIP |
| `tests/ts08_checkout_navigation.robot` | 5/0/1 | TS-08 Checkout Navigation (UC-08): 6 cases: 5 automated, 1 design-only SKIP |
| `tests/ts09_checkout_validation.robot` | 7/0/0 | TS-09 Checkout Validation (UC-09): 7 cases, all automated |
| `tests/ts10_shipping_selection.robot` | 4/0/2 | TS-10 Shipping (UC-10): 6 cases: 4 automated, 2 design-only SKIPs re-proven by a live 5-destination sweep (two methods exist store-wide but never together for one destination; worldwide catch-all zone) |
| `tests/ts11_discount.robot` | 2/0/4 | TS-11 Discount (UC-11): 6 cases: 2 automated, 4 blocked–no-data SKIPs (no genuine coupon code known) |
| `tests/ts12_payment.robot` | 4/0/2 | TS-12 Payment (UC-12): 6 cases: 4 executed incl. the authorized successful payment; TC-12-005 settled by manual confirmation retest (automation-limited, not a store defect); TC-12-004 design-only |
| `tests/ts13_order_confirmation.robot` | 5/0/2 | TS-13 Order Confirmation (UC-13): 7 cases: 5 executed under authorization against a real order (confirmation page, number, summary, continue-shopping, e-mail dispatch); 2 design-only |
| `tests/ts14_secondary_services.robot` | 2/4/0 | TS-14 Secondary Services (UC-14): 6 cases, all automated: 4 failing on confirmed defects (dead Wish List / Refer-a-Friend controls, no support channel) |
| `tests/ts15_guest_purchase.robot` | 3/1/1 | TS-15 Guest Purchase (UC-15): 5 cases: 3 passing incl. the authorized guest purchase; TC-15-005 fails on the confirmed missing post-purchase account-creation offer (defect); 1 design-only |
| `tests/ts16_authentication.robot` | 2/0/7 | TS-16 Authentication (UC-16): 9 cases: 2 automated (sign-up format validation; password-recovery UI half), 7 documented SKIPs: the store's account forms are hCaptcha-gated for automation, so the login cases carry manual evidence instead; the former 'silent failed login' and 'no validation' defects were re-graded as automation artifacts after a manual retest showed the store's generic 'Incorrect email or password.' error |
| `tests/ts17_search.robot` | 3/1/0 | TS-17 Search (UC-17): 4 cases, all automated: 1 failing on the search-relevance defect |
| `tests/ts18_content_error_pages.robot` | 3/0/0 | TS-18 Content & Error Pages (UC-18): 3 cases, all automated |

Retired and removed from the working tree (recoverable from git history): the two
SeleniumLibrary suites (stack retirement), and the Suite A smoke prototype
(it duplicated TS-01..05 coverage and sat outside the TCS-specified
108 cases; historically it validated the tool selection, passing 7/7 on both the
old and current stacks).

## Rules of engagement

The test object is a live, shared store used by other competing teams:

- Run suites sparingly and human-paced (normal traffic volumes only).
- Order-creating cases are gated behind `-v ALLOW_ORDERS:True` and run only in explicitly authorized sessions; default runs stop at checkout data entry and place no orders.
- Functional UI testing only; no load, security or availability testing.
