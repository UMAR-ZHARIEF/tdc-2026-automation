*** Settings ***
Documentation     TS-07 Cart Management — executable mirror of TCS cases TC-07-001..007.
...               Authorities: the team's Test Case Specification and Test Basis, UC-07. 5 cases
...               automated; 1
...               documented SKIP (stock-limit capping cannot be induced on a live store).
...               TC-07-006 was removed together with the Test Case Specification's deletion of
...               the non-functional annex (competition Don't #1); the removal is recorded in the
...               Test Case Specification's change log and
...               the ID gap is intentional (no renumbering). TC-07-002 reworded: the theme
...               offers no increment/decrement controls, only a free-text quantity input
...               — the case verifies that input path instead. TC-07-004 uses soft,
...               observation-style assertions (Log per attempt) since the store's exact
...               invalid-input policy is undocumented; the observed behaviour becomes the
...               evidence, and only internal consistency (total vs. displayed quantity) is
...               hard-asserted. STATE-CHAINED execution (root-caused fix from live-run failure
...               analysis): cases run in FILE ORDER 001, 002, 004, 003, 007, 005 and share one
...               cart line built by Suite Setup, instead of each case clearing the cart itself —
...               repeated /cart/clear navigations (up to 6 per run under the old per-test-clear
...               design) trip the store's Cloudflare bot protection mid-suite. Only Suite Setup
...               and Suite Teardown call Clear Cart now (2 hits per run total). TC-07-003 carries
...               a defensive re-add guard (mirroring TC-07-004's own pattern) since TC-07-004's
...               invalid-input handling can leave its line intact or already removed — the
...               store's exact policy per value is undocumented, so TC-07-003 cannot assume
...               which state it inherits. TC-07-007 establishes its own single-item state via
...               one PDP add (TC-07-003's assertions guarantee an empty cart on entry), matching
...               its original precondition. Oracles are unchanged from the per-test-clear
...               design; only preconditions and cleanup moved.
...               Page Object Model: element locators live in resources/pages/ — this file
...               contains business-readable steps only.
...               Environment: Brave (Chromium) via Browser library (Playwright), guest role.
...               Traffic: ~20 page loads per run (down from ~30; data-dependent re-adds in
...               TC-07-003/004 aside) — run sparingly (shared live store).
Resource          ../resources/common.resource
Resource          ../resources/pages/layout.resource
Resource          ../resources/pages/product_page.resource
Resource          ../resources/pages/cart_page.resource
Suite Setup       Run Keywords    Open Store Session    AND    Clear Cart    AND    Establish Shared Cart Line
Suite Teardown    Run Keywords    Clear Cart    AND    Close Store Session
Test Tags         TS-07    UC-07    guest

*** Variables ***
${PRODUCT_HANDLE}         grey-jacket
@{INVALID_QUANTITIES}    0    -1    abc    ${EMPTY}

*** Keywords ***
Establish Shared Cart Line
    [Documentation]    Suite Setup helper: adds one unit of the shared product and captures its
    ...    unit price as a suite variable, so the chained tests below do not need to re-open the
    ...    product page merely to read the price. Composes only existing product_page keywords.
    Open Product    ${PRODUCT_HANDLE}
    ${price_text}=    Visible Price Text
    Set Suite Variable    ${UNIT_PRICE_TEXT}    ${price_text}
    Add Current Product To Cart

*** Test Cases ***
TC-07-001 Modify Item Quantity Via Quantity Input
    [Documentation]    The customer sets the cart line's quantity input to 3 and applies the
    ...    Update control: the quantity shows 3, the line total equals 3x the unit price, and the
    ...    header count reflects 3. State chained from Suite Setup's shared cart
    ...    line (deliberate — repeated /cart/clear navigations trip the store's bot protection):
    ...    the cart already holds one unit; this test edits its quantity directly.
    ...    Priority High / Positive.
    [Tags]    priority-high    type-positive    TC-07-001
    Open Cart
    Set Line Quantity    3
    Update Cart
    Line Quantity Should Be    3
    ${unit_price}=    Currency Text To Number    ${UNIT_PRICE_TEXT}
    ${expected}=    Evaluate    ${unit_price} * 3
    ${line_total}=    Cart Line Total Amount
    Should Be Equal As Numbers    ${line_total}    ${expected}
    ...    msg=Line total did not equal 3x the unit price after updating quantity to 3
    Cart Badge Should Show    3

TC-07-002 Quantity Input Editing Behaviour
    [Documentation]    The theme offers no increment/decrement controls — quantity is edited only
    ...    via the free-text input. The customer sets quantity to 2, then back to 1;
    ...    totals recalculate correctly on each Update. State chained from TC-07-001 (deliberate
    ...    — repeated /cart/clear navigations trip the store's bot protection): the line already
    ...    exists (at quantity 3 on entry); this test edits it to 2, then to 1, on that same line.
    ...    Priority High / Positive.
    [Tags]    priority-high    type-positive    TC-07-002
    ${unit_price}=    Currency Text To Number    ${UNIT_PRICE_TEXT}
    Open Cart
    Set Line Quantity    2
    Update Cart
    Line Quantity Should Be    2
    ${total_at_2}=    Cart Line Total Amount
    ${expected_at_2}=    Evaluate    ${unit_price} * 2
    Should Be Equal As Numbers    ${total_at_2}    ${expected_at_2}
    ...    msg=Line total did not recalculate correctly for quantity 2
    Set Line Quantity    1
    Update Cart
    Line Quantity Should Be    1
    ${total_at_1}=    Cart Line Total Amount
    Should Be Equal As Numbers    ${total_at_1}    ${unit_price}
    ...    msg=Line total did not recalculate correctly for quantity 1

TC-07-004 Invalid Quantity Input Handling
    [Documentation]    Quantity values 0, -1, "abc" and "" are each tried in turn with an Update
    ...    between attempts. The exact policy is not specified by the TCS, so this case documents
    ...    the observed handling per value (Log) rather than asserting one fixed outcome; the
    ...    cart must never enter a corrupted state — either the value is rejected/normalized or
    ...    (for 0) the line is removed, and the displayed total always stays consistent with the
    ...    displayed quantity. State chained from TC-07-002 (deliberate — repeated /cart/clear
    ...    navigations trip the store's bot protection): the line already exists (at quantity 1
    ...    on entry); this test's own empty-cart re-add guard inside the FOR loop already handles
    ...    the case where an invalid value empties the line mid-test, so no separate setup add is
    ...    performed here. Priority Medium / Negative.
    [Tags]    priority-medium    type-negative    TC-07-004
    ${unit_price}=    Currency Text To Number    ${UNIT_PRICE_TEXT}
    Open Cart
    FOR    ${value}    IN    @{INVALID_QUANTITIES}
        ${was_empty}=    Cart Is Empty
        IF    ${was_empty}
            Open Product    ${PRODUCT_HANDLE}
            Add Current Product To Cart
            Open Cart
        END
        Set Line Quantity    ${value}
        Update Cart
        ${now_empty}=    Cart Is Empty
        IF    ${now_empty}
            Log    Invalid quantity input "${value}": the store removed the line (cart is now empty) — treated as a safe outcome, equivalent to explicit removal.
        ELSE
            ${qty}=    Current Line Quantity
            ${line_total}=    Cart Line Total Amount
            ${expected}=    Evaluate    ${unit_price} * ${qty}
            ${diff}=    Evaluate    abs(${line_total} - ${expected})
            Log    Invalid quantity input "${value}": store shows quantity=${qty}, line total=${line_total} (${unit_price} x ${qty} = ${expected} expected) — value was rejected/normalized rather than corrupting the cart.
            Should Be True    ${diff} < 0.01    msg=Cart line total inconsistent with its own displayed quantity after invalid input "${value}"
        END
    END
    ${final_empty}=    Cart Is Empty
    IF    ${final_empty}
        Empty Cart State Should Be Shown
        Log    Final cart state after all invalid-input attempts: empty (internally consistent).
    ELSE
        ${qty}=    Current Line Quantity
        ${line_total}=    Cart Line Total Amount
        ${cart_total}=    Cart Grand Total Amount
        Should Be Equal As Numbers    ${cart_total}    ${line_total}
        ...    msg=Cart total inconsistent with the (single) line total after invalid-input attempts
        Log    Final cart state after all invalid-input attempts: quantity=${qty}, total=${cart_total} (internally consistent).
    END

TC-07-003 Remove Item Via Remove Link
    [Documentation]    The customer clicks the cart line's Remove control: the line disappears,
    ...    the empty-cart state renders, and the header count reflects the removal. State
    ...    chained from TC-07-004 (deliberate — repeated /cart/clear
    ...    navigations trip the store's bot protection): TC-07-004's invalid-input handling can
    ...    end with the line intact or already removed (the store's exact policy per value is
    ...    undocumented), so this test re-establishes one unit first if the cart is already empty
    ...    on entry — mirroring TC-07-004's own guard — before exercising the Remove control.
    ...    Priority High / Positive.
    [Tags]    priority-high    type-positive    TC-07-003
    Open Cart
    ${was_empty}=    Cart Is Empty
    IF    ${was_empty}
        Open Product    ${PRODUCT_HANDLE}
        Add Current Product To Cart
        Open Cart
    END
    Remove First Cart Line
    ${is_empty}=    Cart Is Empty
    Should Be True    ${is_empty}    msg=Cart line was not removed
    Empty Cart State Should Be Shown
    Cart Badge Should Show    0

TC-07-007 Removing Last Item Yields Empty-Cart State
    [Documentation]    With exactly one item in the cart — added by this test, not chained, since
    ...    TC-07-003's own assertions guarantee an empty cart on entry — removing it transitions
    ...    the cart page cleanly to the empty-cart state and the header count reads 0 (the
    ...    empty-state expectation). State chained from TC-07-003
    ...    (deliberate — repeated /cart/clear navigations trip the store's bot protection): no
    ...    Clear Cart is needed here because TC-07-003 already verified an empty cart.
    ...    Priority Medium / Negative.
    [Tags]    priority-medium    type-negative    TC-07-007
    Open Product    ${PRODUCT_HANDLE}
    Add Current Product To Cart
    Open Cart
    Remove First Cart Line
    Empty Cart State Should Be Shown
    Cart Badge Should Show    0

TC-07-005 Stock-Limit Capping (Design-Only)
    [Documentation]    TCS expects a quantity increase beyond available stock to be capped with a
    ...    notification. Not executed: stock levels are unknown and cannot be manipulated on a
    ...    live store the team does not control. Priority High / Negative.
    [Tags]    priority-high    type-negative    design-only    TC-07-005
    Skip    Design-only: stock levels are unknown and cannot be manipulated on a live store. Designed case retained in the TCS.
