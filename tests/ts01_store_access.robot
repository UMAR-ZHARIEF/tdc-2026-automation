*** Settings ***
Documentation     TS-01 Store Access System — executable mirror of TCS cases TC-01-001..007.
...               Source: "test case n test suite tdc - amirah.docx" (TCS, 2026-07-29), UC-01.
...               4 cases automated; 3 carry a documented SKIP because they are not executable
...               against a live, shared production store (see each case's reason). Expected
...               results in the TCS are derived acceptance criteria (oracle = standard
...               e-commerce behaviour); a mismatch found here is a finding, not a broken test.
...               Environment: Brave 150 (Chromium) via Browser library (Playwright), guest role.
...               Traffic: ~4 page loads per run — run sparingly (shared live store).
Resource          ../resources/common.resource
Suite Setup       Open Store Session
Suite Teardown    Close Store Session
Test Tags         TS-01    UC-01    guest

*** Variables ***
# Stable in-stock product used for the deep-link case (availability re-checked at runtime)
${DEEP_LINK_URL}        ${STORE_URL}products/grey-jacket
${DEEP_LINK_PRODUCT}    Grey jacket

*** Test Cases ***
TC-01-001 Load Storefront Homepage Via URL
    [Documentation]    Customer loads the storefront homepage via its URL; the page loads and
    ...    displays the storefront home elements. Priority High / Positive.
    [Tags]    priority-high    type-positive
    Go To    ${STORE_URL}
    Get Title    ==    Sauce Demo
    Get Text    body    contains    My Cart
    Get Element Count    xpath=//a[contains(@href,'/products/')]    >    0

TC-01-002 Bookmark Or Direct Product Link Loads Without Homepage
    [Documentation]    Access via a saved bookmark or shared direct link. A bookmark is a stored
    ...    direct URL, so this is executed as direct deep-link navigation in a fresh browser
    ...    context (no history/cookies from the previous case). Priority High / Positive.
    [Tags]    priority-high    type-positive
    New Context
    New Page    about:blank
    Go To    ${DEEP_LINK_URL}
    Get Url    contains    /products/grey-jacket
    Get Text    body    contains    ${DEEP_LINK_PRODUCT}

TC-01-003 Layout Degradation On Older Browsers (Design-Only)
    [Documentation]    TCS expects a graceful, degraded layout on legacy browsers. Not executed:
    ...    no legacy browser is part of the approved environment (Brave/Chromium 150 only), and
    ...    "graceful degradation" has no objective automated oracle. Priority Medium / Negative.
    [Tags]    priority-medium    type-negative    design-only
    Skip    Not executable: legacy-browser environment is outside the approved test environment (Brave/Chromium only); no objective automated oracle for "graceful degradation".

TC-01-004 Storefront Renders Fully On Supported Modern Browser
    [Documentation]    TCS names Chrome/Safari/Edge as examples; the approved environment browser
    ...    is Brave (modern Chromium engine). Verifies the storefront's core layout renders
    ...    completely: cart indicator, catalogue navigation, search box, product grid.
    ...    Priority High / Positive.
    [Tags]    priority-high    type-positive
    Go To    ${STORE_URL}
    Get Text    body    contains    My Cart (
    Get Element Count    xpath=//a[contains(@href,'/collections/')]    >    0
    Get Element Count    input[name="q"]    >    0
    Get Element Count    xpath=//a[contains(@href,'/products/')]    >    0

TC-01-005 Network Disconnection Yields Clear Error And Recovery
    [Documentation]    With connectivity lost, attempting to load the store must surface an
    ...    explicit connection error rather than a blank page or silent hang; loading works again
    ...    once the connection returns. Executed with Playwright's client-side offline emulation
    ...    (Set Offline) — no request leaves this machine while offline, safe for the live store.
    ...    Priority High / Negative.
    [Tags]    priority-high    type-negative
    Set Offline    True
    ${err}=    Run Keyword And Expect Error    *    Go To    ${STORE_URL}collections/all
    Should Contain    ${err}    net::ERR
    ...    msg=Expected an explicit network error from the navigation attempt while offline
    Set Offline    False
    Go To    ${STORE_URL}collections/all
    Get Element Count    xpath=//a[contains(@href,'/products/')]    >    0
    [Teardown]    Set Offline    False

TC-01-006 Partial Content Load Failure (Design-Only)
    [Documentation]    TCS expects graceful handling when some assets fail to load. Not executed:
    ...    the chosen stack exposes no per-request fault injection, and throttling a live shared
    ...    store would cross into prohibited non-functional testing. Priority Medium / Negative.
    [Tags]    priority-medium    type-negative    design-only
    Skip    Not executable: requires per-request fault injection (not exposed by Browser library) and would amount to non-functional testing of a live shared store.

TC-01-007 Backend Platform Outage Messaging (Design-Only)
    [Documentation]    TCS expects a clean store-unavailable message when the e-commerce backend
    ...    is down. Not executed: the Shopify backend cannot and must not be taken offline by
    ...    testers on a live shared test object. Priority High / Negative.
    [Tags]    priority-high    type-negative    design-only
    Skip    Not executable: requires a backend outage; testers must not disrupt the live shared test object (competition conduct rules).
