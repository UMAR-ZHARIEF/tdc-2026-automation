*** Settings ***
Documentation     Page object: the cart page (/cart). The theme uses classic
...               input[name="updates[]"] quantity fields, one per cart line; GET /cart/clear
...               empties the cart. After an add the theme stays on the product page, so
...               cart-content assertions must Open Cart explicitly (finding AF-09).
...               TB-CART-002 known display defect: the line title renders duplicated on this
...               page (and triplicated in the header's mini-cart drawer — see layout.resource);
...               keywords here read line/total text without asserting title equality. The
...               header mini-cart drawer's own copy of the cart form is present (hidden) in the
...               DOM on every page, including this one, so line/total/remove/update/note
...               locators are scoped to css=#cart to avoid matching the drawer's hidden copy.
Library           Browser
Resource          ../common.resource

*** Variables ***
${QTY_INPUT}                css=input[name^="updates"]:visible
${LINE_TOTAL_TEXT}          css=#cart .row .total.desktop span
${CART_GRAND_TOTAL_TEXT}    css=#cart .cart.total h2
${REMOVE_LINE_LINK}         css=#cart a[href*="/cart/change"]
${UPDATE_BUTTON}            css=#cart input#update
${NOTE_TEXTAREA}            css=#cart textarea[name*="note"]

*** Keywords ***
Open Cart
    Go To    ${STORE_URL}cart

Cart Should Contain
    [Documentation]    Asserts the cart page shows the given text (a runtime-captured product
    ...    name or price). Guards against an EMPTY expected string first: "contains ''" passes
    ...    against any page, which silently voids the oracle — discovered by live verification
    ...    7 Aug 2026 when an empty runtime-captured title made this check pass on an empty
    ...    cart.
    [Arguments]    ${text}
    Should Not Be Empty    ${text}    msg=Cart Should Contain called with an EMPTY expected text — the runtime capture that produced it failed; the oracle would be vacuous
    Get Text    body    contains    ${text}

Cart Should Have Lines
    [Arguments]    ${count}
    Get Element Count    ${QTY_INPUT}    ==    ${count}

Line Quantity Should Be
    [Documentation]    Asserts the quantity field of the first visible cart line (strict mode
    ...    is off; first match).
    [Arguments]    ${quantity}
    Get Attribute    ${QTY_INPUT}    value    ==    ${quantity}

Clear Cart
    [Documentation]    Empties the cart via GET /cart/clear (store hygiene in teardowns);
    ...    failures are ignored so teardown never masks a test result.
    Run Keyword And Ignore Error    Go To    ${STORE_URL}cart/clear

Cart Is Empty
    [Documentation]    Returns True when the cart page shows no quantity input (no line
    ...    present) — the theme renders an empty-cart message instead of the line form.
    ${count}=    Get Element Count    ${QTY_INPUT}
    ${is_empty}=    Evaluate    ${count} == 0
    RETURN    ${is_empty}

Empty Cart State Should Be Shown
    [Documentation]    Asserts the /cart page renders its empty-cart message rather than a line
    ...    list, error, or blank page (TB-CART-001 / TCND-008 empty-state expectation).
    Get Text    body    contains    cart is currently empty

Current Line Quantity
    [Documentation]    Returns the first visible cart line's quantity as an integer.
    ${value}=    Get Attribute    ${QTY_INPUT}    value
    ${number}=    Convert To Integer    ${value}
    RETURN    ${number}

Set Line Quantity
    [Documentation]    Types the given value into the first visible cart line's quantity field —
    ...    the theme's only quantity-editing control; no increment/decrement buttons exist
    ...    (TB-CUP-001). Does not submit; call Update Cart afterwards to apply.
    [Arguments]    ${value}
    Fill Text    ${QTY_INPUT}    ${value}

Update Cart
    [Documentation]    Submits the cart page's Update control, applying any pending quantity or
    ...    note edits (the theme performs a full page reload on submit).
    Click    ${UPDATE_BUTTON}

Remove First Cart Line
    [Documentation]    Clicks the cart page's line-level Remove control — a plain "x" link to
    ...    /cart/change?...&quantity=0 (TB-CUP-004). Distinct from the mini-cart drawer's own
    ...    "Remove" link, which carries a "removeLine" class this page control lacks (see
    ...    layout.resource).
    Click    ${REMOVE_LINE_LINK}

Fill Order Note
    [Documentation]    Types into the cart page's order-note textarea (TB-CART-006). Does not
    ...    submit; call Update Cart afterwards to apply.
    [Arguments]    ${text}
    Fill Text    ${NOTE_TEXTAREA}    ${text}

Order Note Text Should Contain
    [Arguments]    ${text}
    Get Text    ${NOTE_TEXTAREA}    contains    ${text}

Currency Text To Number
    [Documentation]    Parses a rendered currency string (for example "£55.00" or
    ...    "Total £165.00") into a float for arithmetic assertions.
    [Arguments]    ${text}
    ${number}=    Evaluate    float("""${text}""".replace(',', '').split('£')[-1].strip())
    RETURN    ${number}

Cart Line Total Amount
    [Documentation]    Returns the first visible cart line's total price as a number.
    ${text}=    Get Text    ${LINE_TOTAL_TEXT}
    ${amount}=    Currency Text To Number    ${text}
    RETURN    ${amount}

Cart Grand Total Amount
    [Documentation]    Returns the cart page's displayed grand total as a number.
    ${text}=    Get Text    ${CART_GRAND_TOTAL_TEXT}
    ${amount}=    Currency Text To Number    ${text}
    RETURN    ${amount}
