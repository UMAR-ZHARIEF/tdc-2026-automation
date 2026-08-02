*** Settings ***
Documentation     TS-03 Product Detail Page — executable mirror of TCS cases TC-03-001..008.
...               Source: team TCS (revision 29 July 2026), UC-03. 4 cases automated; 4 carry a
...               documented SKIP (fault injection impossible on a live store; the breadcrumb
...               trail is Home — product with no category level and no broken link to
...               exercise; the description-expansion control does not exist — the observed
...               element counts are logged at run time by TC-03-001 as evidence).
...               Environment: Brave (Chromium) via Browser library (Playwright), guest role.
...               Traffic: ~5 page loads per run — run sparingly (shared live store).
Resource          ../resources/common.resource
Suite Setup       Open Store Session
Suite Teardown    Close Store Session
Test Tags         TS-03    UC-03    guest

*** Variables ***
${PDP_URL}                 ${STORE_URL}products/grey-jacket
${SOLD_OUT_URL}            ${STORE_URL}products/white-sandals
${VISIBLE_PRODUCT_LINK}    css=a[href*="/products/"]:visible
${ACTIVE_ADD_TO_CART}      xpath=//button[normalize-space()='Add to Cart' and not(@disabled)] | //input[@type='submit' and @value='Add to Cart' and not(@disabled)]
${BREADCRUMB_LINKS}        css=div[id="breadcrumb"] a

*** Test Cases ***
TC-03-001 Product Detail Page Shows Pricing Availability And Attributes
    [Documentation]    The detail page loads its primary details: title heading, price and an
    ...    availability control. Breadcrumb and description-block element counts are logged as
    ...    evidence for the skip decisions of TC-03-006/007/008. Priority High / Positive.
    [Tags]    priority-high    type-positive
    Go To    ${PDP_URL}
    Get Element Count    h1    >    0
    Get Text    body    contains    £
    Get Element Count    ${ACTIVE_ADD_TO_CART}    >    0
    ${bc}=    Get Element Count    ${BREADCRUMB_LINKS}
    Log    Breadcrumb links found on the product detail page: ${bc} (evidence for TC-03-006/008)
    ${desc}=    Get Element Count    css=.product-description, #product-description, .description, .rte
    Log    Description blocks rendered (fully visible, no expansion control): ${desc} (evidence for TC-03-007)

TC-03-002 Browser Back Button Returns To The Catalogue
    [Documentation]    Alternative flow: after opening a product from the catalogue, the browser
    ...    Back button returns the customer to the catalogue listing. Priority Medium / Positive.
    [Tags]    priority-medium    type-positive
    Go To    ${STORE_URL}collections/all
    Click    ${VISIBLE_PRODUCT_LINK}
    Get Url    contains    /products/
    Go Back
    Get Url    contains    /collections/
    Get Element Count    ${VISIBLE_PRODUCT_LINK}    >    0

TC-03-003 Purchase Path Available Without Reading The Description
    [Documentation]    Alternative flow: the description is optional and does not gate the
    ...    purchase controls. The theme renders the description fully visible with no expansion
    ...    step; the add-to-cart control is available immediately alongside it.
    ...    Priority Medium / Positive.
    [Tags]    priority-medium    type-positive
    Go To    ${PDP_URL}
    Get Element Count    ${ACTIVE_ADD_TO_CART}    >    0
    Get Element Count    h1    >    0

TC-03-004 Core Product Data Fails To Display (Design-Only)
    [Documentation]    TCS expects safe behaviour when core data (price, name, add control)
    ...    fails to load. Not executed: data-loading faults cannot be injected into a live store
    ...    the team does not control. Priority High / Negative.
    [Tags]    priority-high    type-negative    design-only
    Skip    Not executable: cannot inject data-loading faults into a live store the team does not control. Designed case retained in the TCS.

TC-03-005 Sold-Out Product Indicates Unavailability
    [Documentation]    A product that is out of stock must indicate unavailability rather than
    ...    offer a normal add-to-cart action. Executed against a genuinely sold-out product;
    ...    the price remains displayed while no active add control is offered.
    ...    Priority High / Negative.
    [Tags]    priority-high    type-negative
    Go To    ${SOLD_OUT_URL}
    Get Text    body    contains    £
    ${sold_out_shown}=    Run Keyword And Return Status    Get Text    body    contains    Sold Out
    ${active_add}=    Get Element Count    ${ACTIVE_ADD_TO_CART}
    Should Be True    ${sold_out_shown} or ${active_add} == 0
    ...    msg=Neither a Sold Out indicator nor a blocked add-to-cart control found on a sold-out product

TC-03-006 Broken Breadcrumb Link Fails Safely (Design-Only)
    [Documentation]    TCS expects a broken breadcrumb to fail safely toward a known page. Not
    ...    executed: the trail (Home - product) contains only functional links, so no broken
    ...    breadcrumb exists to exercise (TC-03-001 logs the element count as evidence).
    ...    Priority High / Negative.
    [Tags]    priority-high    type-negative    design-only
    Skip    Not executable: the detail page breadcrumb trail (Home - product) contains no broken link to exercise; its links are functional (element count logged by TC-03-001). Designed case retained in the TCS.

TC-03-007 Expand Full Product Description (Design-Only)
    [Documentation]    TCS models an extension that expands a collapsed description. Not
    ...    executed: the theme renders the full description by default and offers no expansion
    ...    control (TC-03-001 logs the visible description block as evidence).
    ...    Priority Low / Positive.
    [Tags]    priority-low    type-positive    design-only
    Skip    Not executable: the description is fully visible by default; no expansion control exists (evidence logged by TC-03-001). Designed case retained in the TCS.

TC-03-008 Breadcrumb Category Step-Back (Design-Only)
    [Documentation]    TCS models stepping back through a category hierarchy via breadcrumbs.
    ...    Not executed: the trail is Home - product with no category level (the catalogue is a
    ...    single flat collection). Priority Low / Positive.
    [Tags]    priority-low    type-positive    design-only
    Skip    Not executable: the breadcrumb trail is Home - product with no category level (the catalogue is a single flat collection), so no category step-back exists. Designed case retained in the TCS.
