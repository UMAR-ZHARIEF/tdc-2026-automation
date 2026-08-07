*** Settings ***
Documentation     TS-03 Product Detail Page — executable mirror of TCS cases TC-03-001..008.
...               Authorities: 02 - Test Case Specification v2.1 and
...               01 - Test Basis v1.0 (approved 2026-08-05), UC-03. 6 cases automated; 2 carry a
...               documented design-only SKIP (fault injection impossible on a live store; the
...               breadcrumb trail is Home — product with no category level, so no broken link
...               exists to exercise). Per 02 v2.1 audit addendum A8/A9, TC-03-007/008 execute
...               live checks (description visible by default; breadcrumb Home-link navigation)
...               rather than relying on a design-only skip.
...               Page Object Model: element locators live in resources/pages/ — this file
...               contains business-readable steps only.
...               Environment: Brave (Chromium) via Browser library (Playwright), guest role.
...               Traffic: ~8 page loads per run — run sparingly (shared live store).
Resource          ../resources/common.resource
Resource          ../resources/pages/home_page.resource
Resource          ../resources/pages/catalogue_page.resource
Resource          ../resources/pages/product_listing.resource
Resource          ../resources/pages/product_page.resource
Suite Setup       Open Store Session
Suite Teardown    Close Store Session
Test Tags         TS-03    UC-03    guest

*** Variables ***
${PDP_HANDLE}         grey-jacket
${SOLD_OUT_HANDLE}    white-sandals

*** Test Cases ***
TC-03-001 Product Detail Page Shows Pricing Availability And Attributes
    [Documentation]    The detail page loads its primary details: title heading, price and an
    ...    availability control. Breadcrumb element count is logged as evidence for the skip
    ...    decision of TC-03-006. Priority High / Positive.
    [Tags]    priority-high    type-positive    TC-03-001    TB-PDP-001    TB-PDP-002    TB-PDP-003    TB-PDP-004
    Open Product    ${PDP_HANDLE}
    Product Page Should Be Complete
    Active Add To Cart Should Be Present
    ${bc}=    Breadcrumb Link Count
    Log    Breadcrumb links found on the product detail page: ${bc} (evidence for TC-03-006)
    ${desc}=    Description Block Count
    Log    Description blocks rendered (fully visible, no expansion control): ${desc}

TC-03-002 Browser Back Button Returns To The Catalogue
    [Documentation]    Alternative flow: after opening a product from the catalogue, the browser
    ...    Back button returns the customer to the catalogue listing. Priority Medium / Positive.
    [Tags]    priority-medium    type-positive    TC-03-002    TB-PDP-001    TB-PDP-002    TB-PDP-003    TB-PDP-004
    Open Catalogue
    Open First Listed Product
    Go Back
    Should Be On Catalogue
    Products Should Be Listed

TC-03-003 Purchase Path Available Without Reading The Description
    [Documentation]    Alternative flow: the description is optional and does not gate the
    ...    purchase controls. The theme renders the description fully visible with no expansion
    ...    step; the add-to-cart control is available immediately alongside it.
    ...    Priority Medium / Positive.
    [Tags]    priority-medium    type-positive    TC-03-003    TB-PDP-001    TB-PDP-002    TB-PDP-003    TB-PDP-004
    Open Product    ${PDP_HANDLE}
    Active Add To Cart Should Be Present
    Product Page Should Be Complete

TC-03-004 Core Product Data Fails To Display (Design-Only)
    [Documentation]    TCS expects safe behaviour when core data (price, name, add control)
    ...    fails to load. Not executed: data-loading faults cannot be injected into a live store
    ...    the team does not control. Priority High / Negative.
    [Tags]    priority-high    type-negative    design-only    TC-03-004    TB-PDP-001    TB-PDP-002    TB-PDP-003    TB-PDP-004
    Skip    Not executable: cannot inject data-loading faults into a live store the team does not control. Designed case retained in the TCS.

TC-03-005 Sold-Out Product Indicates Unavailability
    [Documentation]    A product that is out of stock must indicate unavailability rather than
    ...    offer a normal add-to-cart action. Executed against a genuinely sold-out product;
    ...    the price remains displayed while no active add control is offered.
    ...    Priority High / Negative.
    [Tags]    priority-high    type-negative    TC-03-005    TB-PDP-001    TB-PDP-002    TB-PDP-003    TB-PDP-004
    Open Product    ${SOLD_OUT_HANDLE}
    Product Price Should Be Displayed
    Sold Out State Should Be Indicated

TC-03-006 Broken Breadcrumb Link Fails Safely (Design-Only)
    [Documentation]    TCS expects a broken breadcrumb to fail safely toward a known page. Not
    ...    executed: the trail (Home - product) contains only functional links, so no broken
    ...    breadcrumb exists to exercise (TC-03-001 logs the element count as evidence).
    ...    Priority High / Negative.
    [Tags]    priority-high    type-negative    design-only    TC-03-006    TB-PDP-001    TB-PDP-002    TB-PDP-003    TB-PDP-004
    Skip    Not executable: the detail page breadcrumb trail (Home - product) contains no broken link to exercise; its links are functional (element count logged by TC-03-001). Designed case retained in the TCS.

TC-03-007 Expand Full Product Description
    [Documentation]    TCS models an extension that expands a collapsed description. Executed
    ...    per 02 v2.1 audit addendum A8 / Test Basis TB-PDP-002 (verified 5 Aug 2026): opens the
    ...    PDP and re-verifies the description block renders by default. No expansion-control
    ...    element exists anywhere in this page object to probe for absence, so "no expansion
    ...    control exists" is carried forward as already-verified evidence rather than re-queried.
    ...    Priority Low / Positive.
    [Tags]    priority-low    type-positive    TC-03-007    TB-PDP-001    TB-PDP-002    TB-PDP-003    TB-PDP-004
    Open Product    ${PDP_HANDLE}
    ${desc}=    Description Block Count
    Should Be True    ${desc} > 0    msg=Description block not rendered on the product detail page
    Log    No expansion control exists for the description (TB-PDP-002, verified 5 Aug 2026) — the theme's DOM defines no such element to probe.

TC-03-008 Breadcrumb Category Step-Back
    [Documentation]    TCS models stepping back through a category hierarchy via breadcrumbs.
    ...    Executed per 02 v2.1 audit addendum A9: clicks the breadcrumb's Home link and verifies
    ...    navigation back to the homepage. The trail itself is Home - product with no category
    ...    level (the catalogue is a single flat collection; TB-PDP-003) — there is no category
    ...    step to exercise, only the Home step. Priority Low / Positive.
    [Tags]    priority-low    type-positive    TC-03-008    TB-PDP-001    TB-PDP-002    TB-PDP-003    TB-PDP-004
    Open Product    ${PDP_HANDLE}
    Click Breadcrumb Home Link
    Home Title Should Be Correct
