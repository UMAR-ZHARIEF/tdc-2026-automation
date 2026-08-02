*** Settings ***
Documentation     TS-04 Product Variant Handling — executable mirror of TCS cases TC-04-001..007.
...               Source: team TCS (revision 29 July 2026), UC-04. 6 cases automated (two carry
...               runtime data guards: they skip with a stated reason if the current catalogue
...               snapshot lacks the product data they need); 1 documented SKIP (inventory
...               cannot be manipulated on a live store). Variant product: the two-dimension
...               item titled 'Black heels' served at /products/flower-print-jeans (title/URL
...               mismatch recorded as automation finding AF-03).
...               Page Object Model: element locators live in resources/pages/ — this file
...               contains business-readable steps only.
...               Environment: Brave (Chromium) via Browser library (Playwright), guest role.
...               Traffic: ~5 page loads per run — run sparingly (shared live store).
Resource          ../resources/common.resource
Resource          ../resources/pages/product_page.resource
Suite Setup       Open Store Session
Suite Teardown    Close Store Session
Test Tags         TS-04    UC-04    guest

*** Variables ***
${VARIANT_HANDLE}             flower-print-jeans
${SINGLE_CANDIDATE_HANDLE}    grey-jacket

*** Test Cases ***
TC-04-001 Variant Selection Is Applied And Reflected
    [Documentation]    The customer selects a product variant and the page reflects the active
    ...    choice. The first variant dimension is changed to its second option and the selected
    ...    label is asserted to have changed. Priority High / Positive.
    [Tags]    priority-high    type-positive
    Open Product    ${VARIANT_HANDLE}
    ${selects}=    Variant Dimension Count
    Should Be True    ${selects} >= 1    msg=No variant selectors found on the variant product page
    ${options}=    Variant Option Count    0
    Skip If    ${options} < 2    Variant dimension offers fewer than two options in the current catalogue snapshot.
    ${initial}=    Selected Variant Label    0
    Select Variant Option    0    1
    ${after}=    Selected Variant Label    0
    Should Not Be Equal    ${initial}    ${after}    msg=Variant selection was not applied
    Log    Variant selection applied: ${initial} -> ${after}

TC-04-002 Single-Variant Product Proceeds Without Explicit Selection
    [Documentation]    Alternative flow: a product without selectable options can be added
    ...    without an explicit variant choice. Runtime data guard: the case skips with a reason
    ...    if the candidate product presents variant selectors in the current snapshot.
    ...    Priority Medium / Positive.
    [Tags]    priority-medium    type-positive
    Open Product    ${SINGLE_CANDIDATE_HANDLE}
    ${selects}=    Variant Dimension Count
    Skip If    ${selects} > 0    Candidate product presents ${selects} variant selector(s); no single-variant product identified in the current catalogue snapshot.
    Active Add To Cart Should Be Present

TC-04-003 Final Selection Persists Across Multiple Changes
    [Documentation]    Alternative flow: the customer changes the variant selection several
    ...    times; only the final choice remains active. Priority Medium / Positive.
    [Tags]    priority-medium    type-positive
    Open Product    ${VARIANT_HANDLE}
    ${options}=    Variant Option Count    0
    Skip If    ${options} < 2    Variant dimension offers fewer than two options in the current catalogue snapshot.
    Select Variant Option    0    1
    ${target}=    Selected Variant Label    0
    Select Variant Option    0    0
    Select Variant Option    0    1
    ${final}=    Selected Variant Label    0
    Should Be Equal    ${final}    ${target}    msg=Final variant selection was not preserved after multiple changes

TC-04-004 A Default Variant Is Always Preselected
    [Documentation]    TCS negative case: adding without a mandatory variant selection must be
    ...    blocked. On this theme the invalid state is unreachable by design: every variant
    ...    dimension loads with a default option already selected, so no unselected add is
    ...    possible. The case is executed as a verification of that safeguard.
    ...    Priority High / Negative.
    [Tags]    priority-high    type-negative
    Open Product    ${VARIANT_HANDLE}
    All Variant Dimensions Should Have Defaults

TC-04-005 Selected Variant Becomes Out Of Stock (Design-Only)
    [Documentation]    TCS expects notification when a selected variant sells out while the
    ...    customer is on the page. Not executed: stock levels cannot be manipulated on a live
    ...    store the team does not control. Priority High / Negative.
    [Tags]    priority-high    type-negative    design-only
    Skip    Not executable: stock levels cannot be manipulated on a live store the team does not control. Designed case retained in the TCS.

TC-04-006 Page Refresh Yields A Valid Variant State
    [Documentation]    TCS robustness case: after a refresh the page must either restore the
    ...    prior selection or reset cleanly to a default — never present an invalid state. The
    ...    observed behaviour (restored or reset) is logged as evidence.
    ...    Priority Medium / Negative.
    [Tags]    priority-medium    type-negative
    Open Product    ${VARIANT_HANDLE}
    ${options}=    Variant Option Count    0
    Skip If    ${options} < 2    Variant dimension offers fewer than two options in the current catalogue snapshot.
    Select Variant Option    0    1
    ${before}=    Selected Variant Label    0
    Reload
    Product Page Should Be Complete
    ${after}=    Selected Variant Label    0
    Should Not Be Empty    ${after}    msg=No valid variant selected after refresh
    IF    $before == $after
        Log    Refresh behaviour: prior selection RESTORED (${after})
    ELSE
        Log    Refresh behaviour: selection RESET to default (${after}); prior was ${before}
    END

TC-04-007 Size And Colour Are Selectable Together
    [Documentation]    Extension flow: specific size and colour options are configured
    ...    together; both dimensions apply and the add control remains available. Runtime data
    ...    guard: skips if the product offers fewer than two variant dimensions, or if a
    ...    dimension offers fewer than two options (the theme's linked option selector can
    ...    constrain the second dimension by availability). Priority Low / Positive.
    [Tags]    priority-low    type-positive
    Open Product    ${VARIANT_HANDLE}
    ${selects}=    Variant Dimension Count
    Skip If    ${selects} < 2    Product offers ${selects} variant dimension(s) in the current snapshot; two are required for this case.
    ${opt0}=    Variant Option Count    0
    ${opt1}=    Variant Option Count    1
    Log    Variant dimension option counts at run time: ${opt0} / ${opt1} (the theme's linked option selector can constrain the second dimension by availability)
    Skip If    ${opt0} < 2 or ${opt1} < 2    A variant dimension offers fewer than two options in the current catalogue snapshot (option counts: ${opt0}/${opt1}); the theme's linked option selector constrains the second dimension by availability.
    Select Variant Option    0    1
    Select Variant Option    1    1
    ${first}=    Selected Variant Label    0
    ${second}=    Selected Variant Label    1
    Should Not Be Empty    ${first}
    Should Not Be Empty    ${second}
    Active Add To Cart Should Be Present
    Log    Combined configuration applied: ${first} / ${second}
