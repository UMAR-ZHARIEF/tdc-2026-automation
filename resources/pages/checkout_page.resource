*** Settings ***
Documentation     Page object: the modern ONE-PAGE checkout (/checkouts/cn/...), reached from the
...               cart page's #checkout control. Live sections observed: Contact / Delivery /
...               Shipping method / Payment / Credit card / Finalize order / Order summary /
...               Discount / Cost summary. Every locator below marked "captured live 2026-08-07"
...               comes from a real DOM capture of that page (archived at "claude's self created
...               docs/build sources/checkout_dom_capture_2026-08-07.json") — these are REAL,
...               verified handles, not provisional inference, EXCEPT the two locators
...               individually flagged PROVISIONAL below (the checkout header has no captured
...               Cart link, and the post-payment confirmation page was never captured at all,
...               since reaching it spends the store's real payment gateway and this task ran
...               under a zero-store-traffic constraint).
...               Element ids such as TextFieldP0-45 are RANDOMLY GENERATED per page load — never
...               used here. Stable handles are element NAMES, but a hidden autofill-helper form
...               duplicates every one of those names elsewhere in the DOM, so every name-based
...               locator below is filtered with :not([id^="autofill"]) to exclude that hidden
...               duplicate. Card fields are cross-origin PCI iframes
...               (checkout.pci.shopifyinc.com) with a random id suffix per load — selected by
...               prefix and pierced with the Browser library's ">>>" deep-selector syntax.
...               Known page quirks (observe/log only — NEVER assert absence): a recurring
...               transient banner "There was a problem with our checkout" plus roughly 140
...               console errors is a technical-health characteristic of this live checkout, not
...               a per-test failure signal (TC-12-006 is the one case that asserts the banner's
...               PRESENCE, which is a different, expected-result use, not an absence check); the
...               order-summary line doubles the product title ("Grey jacketGrey jacket") — every
...               product-name check in this suite family uses "contains", never equality.
...               Shipping has NO radio controls: a single method is offered, so every shipping
...               oracle here is TEXT-BASED (section/summary text), never radio-based. No stable
...               container locator was captured for the Order summary / Cost summary / alert /
...               error regions either (the capture recorded interactive controls, not prose
...               regions), so every summary/total/alert/error reader in this file works from the
...               page's visible text rather than a scoped element — the same technique
...               resources/pages/cart_page.resource already uses for "Cart Should Contain".
...               Page Object Model: element locators live only here; suites contain
...               business-readable steps only.
Library           Browser
Resource          ../common.resource
Resource          product_page.resource
Resource          cart_page.resource

*** Variables ***
# --- Cart -> checkout transition (physically on /cart; owned here as the checkout entry point) ---
${CART_CHECKOUT_BUTTON}              css=input#checkout    # captured live 2026-08-07; value "Check Out"

# --- Contact ---
${CONTACT_EMAIL_INPUT}               css=input#email    # captured live 2026-08-07; stable id

# --- Delivery address (name-based; hidden autofill-helper duplicate filtered out) ---
${FIRST_NAME_INPUT}                  css=input[name="firstName"]:not([id^="autofill"])    # captured live 2026-08-07
${LAST_NAME_INPUT}                   css=input[name="lastName"]:not([id^="autofill"])    # captured live 2026-08-07
${COMPANY_INPUT}                     css=input[name="company"]:not([id^="autofill"])    # captured live 2026-08-07; optional field
${ADDRESS1_INPUT}                    css=input[name="address1"]:not([id^="autofill"])    # captured live 2026-08-07
${ADDRESS2_INPUT}                    css=input[name="address2"]:not([id^="autofill"])    # captured live 2026-08-07; optional field
${POSTAL_CODE_INPUT}                 css=input[name="postalCode"]:not([id^="autofill"])    # captured live 2026-08-07
${CITY_INPUT}                        css=input[name="city"]:not([id^="autofill"])    # captured live 2026-08-07
${PHONE_INPUT}                       css=input[name="phone"]:not([id^="autofill"])    # captured live 2026-08-07; optional field
${COUNTRY_SELECT}                    css=select[name="countryCode"]    # captured live 2026-08-07; Malaysia = value "MY"
${ZONE_SELECT}                       css=select[name="zone"]    # captured live 2026-08-07; observed default "KUL"; Selangor selected by label

# --- Marketing consent ---
${MARKETING_OPT_IN}                  css=input#marketing_opt_in    # captured live 2026-08-07; observed PRE-TICKED (TC-09-007 evidence)

# --- Discount ---
${DISCOUNT_INPUT}                    css=input[name="reductions"]    # captured live 2026-08-07
${DISCOUNT_APPLY_BUTTON}             css=button[aria-label="Apply Discount Code"]    # captured live 2026-08-07

# --- Payment ---
${PAY_BUTTON}                        css=button#checkout-pay-button    # captured live 2026-08-07; stable id, "Pay now"
${BILLING_TOGGLE}                    css=input#billingAddressCheckbox    # captured live 2026-08-07

# --- Card fields: cross-origin PCI iframes, random id suffix per load, selected by prefix + pierced ---
${CARD_NUMBER_FRAME_INPUT}                 [id^="card-fields-number"] >>> input    # captured live 2026-08-07
${CARD_EXPIRY_FRAME_INPUT}                 [id^="card-fields-expiry"] >>> input    # captured live 2026-08-07
${CARD_SECURITY_CODE_FRAME_INPUT}          [id^="card-fields-verification_value"] >>> input    # captured live 2026-08-07
${CARD_NAME_FRAME_INPUT}                   [id^="card-fields-name"] >>> input    # captured live 2026-08-07

# --- Return-to-cart: the modern one-page checkout header may not carry a Cart link (unlike the
# classic /cart chrome) — this is the ONLY navigation-chrome PROVISIONAL locator in this file.
${RETURN_TO_CART_LINK}               css=a[href="/cart"]    # PROVISIONAL — live-verify before relying on this outside dry-run; documented fallback is Go Back (browser history)

# --- Post-payment confirmation page: NOT covered by the 2026-08-07 capture (reaching it spends
# the real payment gateway) — every locator/text pattern below is PROVISIONAL, inferred only from
# the verified TEXT evidence in 02 v2.1 (order #1YRC8ZIPW format: "Thank you" heading,
# confirmation number, order details sections, Continue shopping -> storefront). All TS-13/TS-15
# gated cases that depend on these run only under an explicit ALLOW_ORDERS-authorized session, so
# a human is present to course-correct if any of this needs live re-verification.
${CONTINUE_SHOPPING_LINK}            xpath=//a[contains(normalize-space(),'Continue shopping') or contains(normalize-space(),'Continue Shopping')]    # PROVISIONAL — live-verify before relying on this outside dry-run

# --- Text oracles (no stable container locators captured; see file Documentation) ---
${PRE_ADDRESS_SHIPPING_TEXT}         Enter your shipping address to view available shipping methods
${SHIPPING_METHOD_NAME_TEXT}         International Shipping
${SHIPPING_COST_TEXT}                Shipping £20.00
${CHECKOUT_PROBLEM_BANNER_TEXT}      There was a problem with our checkout
${PAYMENT_DECLINED_ALERT_TEXT}       There was an issue processing your payment. Try again or use a different payment method.

# --- Fictitious identity (Test Tester persona, per team policy) and store-safe test data ---
${FICTITIOUS_FIRST_NAME}             Test
${FICTITIOUS_LAST_NAME}              Tester
${FICTITIOUS_FULL_NAME}              Test Tester
${FICTITIOUS_EMAIL}                  tdc.checkout.fictitious@example-tdc-invalid.test
${FICTITIOUS_ADDRESS1}               1 Test Street
${FICTITIOUS_POSTAL_CODE}            40000
${FICTITIOUS_CITY}                   Shah Alam

*** Keywords ***
Open Checkout From Cart
    [Documentation]    Clicks the cart page's #checkout control (value "Check Out"), transitioning
    ...    from /cart into the modern one-page checkout (/checkouts/cn/...).
    Click    ${CART_CHECKOUT_BUTTON}

Reach Checkout With Product
    [Documentation]    Convenience suite-setup helper: adds the given product handle to an (already
    ...    emptied) cart and transitions into checkout in one call — most suites in this family
    ...    make this their single checkout-reach action. Leaves Contact/Delivery untouched, since
    ...    some suites need the pre-address state as their own first case's precondition.
    [Arguments]    ${handle}
    Open Product    ${handle}
    Add Current Product To Cart
    Open Cart
    Open Checkout From Cart

Reach Checkout With Product And Address
    [Documentation]    As `Reach Checkout With Product`, additionally filling the Contact e-mail
    ...    and the standard fictitious Delivery address — leaves checkout ready for a
    ...    shipping/discount/payment interaction. Used by suites whose cases do not need to
    ...    observe the pre-address checkout state.
    [Arguments]    ${handle}    ${email}=${FICTITIOUS_EMAIL}
    Reach Checkout With Product    ${handle}
    Fill Contact Email    ${email}
    Fill Delivery Address

Checkout Should Be Reached
    [Documentation]    Asserts the browser has transitioned from /cart into the modern one-page
    ...    checkout (URL family /checkouts/cn/..., captured live 2026-08-07).
    Get Url    contains    /checkouts/

Checkout Should Not Have Advanced To Confirmation
    [Documentation]    Asserts the browser is still on checkout (URL family /checkouts/cn/...)
    ...    rather than a post-payment confirmation page — the "no order was created" oracle used
    ...    by every declined/rejected/failed payment case in this suite family.
    Get Url    contains    /checkouts/

Fill Contact Email
    [Documentation]    Types the given address into the Contact section's e-mail field.
    [Arguments]    ${email}
    Fill Text    ${CONTACT_EMAIL_INPUT}    ${email}

Fill Delivery Address
    [Documentation]    Fills the Delivery section. Defaults to the team's standard fictitious
    ...    identity (Test Tester, 1 Test Street, 40000 Shah Alam, Selangor, MY) captured live
    ...    2026-08-07; any field can be overridden by callers (for example TC-09-002's blanked
    ...    required fields, or TC-09-006's unrealistic postal code/city). Company, address2 and
    ...    phone are optional on the live form and are only filled when a non-empty value is
    ...    supplied. Country is fixed to Malaysia (MY) and zone to Selangor on every call — the
    ...    suites' shared shipping oracle (International Shipping £20.00) depends on this
    ...    destination.
    [Arguments]    ${first_name}=${FICTITIOUS_FIRST_NAME}    ${last_name}=${FICTITIOUS_LAST_NAME}
    ...    ${address1}=${FICTITIOUS_ADDRESS1}    ${postal_code}=${FICTITIOUS_POSTAL_CODE}
    ...    ${city}=${FICTITIOUS_CITY}    ${company}=${EMPTY}    ${address2}=${EMPTY}
    ...    ${phone}=${EMPTY}
    Fill Text    ${FIRST_NAME_INPUT}    ${first_name}
    Fill Text    ${LAST_NAME_INPUT}    ${last_name}
    IF    $company != ''
        Fill Text    ${COMPANY_INPUT}    ${company}
    END
    Fill Text    ${ADDRESS1_INPUT}    ${address1}
    IF    $address2 != ''
        Fill Text    ${ADDRESS2_INPUT}    ${address2}
    END
    Fill Text    ${POSTAL_CODE_INPUT}    ${postal_code}
    Fill Text    ${CITY_INPUT}    ${city}
    Select Options By    ${COUNTRY_SELECT}    value    MY
    Select Options By    ${ZONE_SELECT}    label    Selangor
    IF    $phone != ''
        Fill Text    ${PHONE_INPUT}    ${phone}
    END

Return To Cart From Checkout
    [Documentation]    Returns from checkout to the cart page (TC-08-003). The modern one-page
    ...    checkout's header may not carry a Cart link the way the classic /cart chrome does, so
    ...    the PROVISIONAL ${RETURN_TO_CART_LINK} is tried first; when it is not present the
    ...    documented fallback is the browser's Go Back control, which returns to the referring
    ...    /cart page (checkout is reached by an in-page transition from /cart, so history back
    ...    lands there). Live-verify ${RETURN_TO_CART_LINK} before relying on the primary path
    ...    outside dry-run.
    ${count}=    Get Element Count    ${RETURN_TO_CART_LINK}
    IF    ${count} > 0
        Click    ${RETURN_TO_CART_LINK}
    ELSE
        Go Back
    END

Empty Cart Direct Checkout Should Be Refused
    [Documentation]    Navigates directly to /checkout with an empty cart and asserts checkout is
    ...    REFUSED (TC-08-004; TB-CHK-004). The recovered expectation is that the checkout flow
    ...    must not be offered when the cart is empty; the store may satisfy that by any
    ...    mechanism. The earlier oracle enumerated only two mechanisms (redirect to /cart, or an
    ...    on-page refusal message) because the real one was unobservable before a live run.
    ...    LIVE RUN 11 Aug 2026 established it: the storefront refuses by redirecting to the HOME
    ...    page — no /cart redirect and no explanatory message. The oracle therefore asserts the
    ...    requirement itself (the checkout flow is not reached) and records the mechanism, plus
    ...    the absence of any explanation, as an observation for the defect/observation log.
    Go To    ${STORE_URL}checkout
    ${url}=    Get Url
    ${page_text}=    Get Text    body
    ${reached_checkout}=    Run Keyword And Return Status    Should Match Regexp    ${url}    (?i)/checkouts?/
    ${redirected_to_cart}=    Run Keyword And Return Status    Should Contain    ${url}    /cart
    ${refusal_text}=    Run Keyword And Return Status    Should Match Regexp    ${page_text}
    ...    (?i)(empty|no items|nothing to checkout|add.{0,15}item)
    Log    Empty-cart /checkout landed on: ${url} | redirected to cart: ${redirected_to_cart} | explanatory message shown: ${refusal_text}
    Should Not Be True    ${reached_checkout}
    ...    msg=Checkout was REACHED with an empty cart — the store failed to refuse direct /checkout navigation
    IF    not ${redirected_to_cart} and not ${refusal_text}
        Log    OBSERVATION (TC-08-004, TB-CHK-004): empty-cart checkout is correctly refused, but the storefront silently redirects to the home page — it neither returns the customer to the cart nor explains why checkout was not offered.    level=WARN
    END

Checkout Page Text
    [Documentation]    Returns the checkout page's full visible text — the shared runtime-capture
    ...    primitive behind every summary/total/alert/error/observation reader in this file (no
    ...    stable container locator was captured for any of those prose regions on 2026-08-07).
    ${text}=    Get Text    body
    RETURN    ${text}

Checkout Page Should Contain
    [Documentation]    Asserts the checkout page's visible text contains the given string —
    ...    generic text oracle reused across section/summary/product-name checks in this suite
    ...    family (mirrors resources/pages/cart_page.resource's "Cart Should Contain"). Use for
    ...    product-name checks too: the order-summary line doubles the title ("Grey
    ...    jacketGrey jacket"), so "contains" is deliberate, never equality.
    [Arguments]    ${text}
    Get Text    body    contains    ${text}

Pre Address Shipping Message Should Be Shown
    [Documentation]    Asserts the Shipping method section shows its pre-address prompt (captured
    ...    live 2026-08-07): "Enter your shipping address to view available shipping methods".
    ...    First half of the TC-10-001 / A12 two-phase oracle.
    Get Text    body    contains    ${PRE_ADDRESS_SHIPPING_TEXT}

Shipping Method Should Be Displayed
    [Documentation]    Asserts the configured shipping method's name is shown after a valid
    ...    address is entered (captured live 2026-08-07: "International Shipping"). Second half
    ...    of the TC-10-001 / A12 two-phase oracle.
    Get Text    body    contains    ${SHIPPING_METHOD_NAME_TEXT}

Shipping Cost Line Text
    [Documentation]    Returns the checkout page's visible text for callers to log/assert the Cost
    ...    summary's shipping line (captured live 2026-08-07: "Shipping £20.00"). Text-based
    ...    oracle — the live checkout has no shipping radio controls to assert against instead.
    ${text}=    Checkout Page Text
    RETURN    ${text}

Order Total Text
    [Documentation]    Returns the checkout page's visible text for callers to log/assert the Cost
    ...    summary's Total line (captured live 2026-08-07: subtotal £55.00 + shipping £20.00 =
    ...    Total GBP £75.00).
    ${text}=    Checkout Page Text
    RETURN    ${text}

Untick Marketing Consent
    [Documentation]    Unticks the marketing-consent checkbox (TC-09-007 step 2).
    Uncheck Checkbox    ${MARKETING_OPT_IN}

Consent Checkbox State
    [Documentation]    Returns the marketing-consent checkbox's current checked state as a
    ...    boolean (captured live 2026-08-07: observed PRE-TICKED by default — TC-09-007
    ...    evidence).
    ${checked}=    Get Checkbox State    ${MARKETING_OPT_IN}
    RETURN    ${checked}

Toggle Billing Address Same As Shipping
    [Documentation]    Clicks the billing-address toggle checkbox (captured live 2026-08-07);
    ...    exposed here for completeness — not exercised by name in this batch's suite cases.
    Click    ${BILLING_TOGGLE}

Apply Discount Code
    [Documentation]    Types the given code into the Discount field and activates Apply.
    [Arguments]    ${code}
    Fill Text    ${DISCOUNT_INPUT}    ${code}
    Click    ${DISCOUNT_APPLY_BUTTON}

Discount Error Surface Text
    [Documentation]    Returns the checkout page's visible text for callers to assert/log the
    ...    discount-rejection error surface after an invalid code is applied. Text-based oracle —
    ...    no stable discount-error container locator was captured (2026-08-07).
    ${text}=    Checkout Page Text
    RETURN    ${text}

Field Error Text Near
    [Documentation]    Best-effort field-level validation-error reader: returns text from the
    ...    nearest enclosing container around the NAMED field's input (accepts "email",
    ...    "firstName", "lastName", "address1", "postalCode" or "city" — deliberately a semantic
    ...    name, not a raw locator, so callers in tests/ never need to hold a css=/xpath= string).
    ...    No stable per-field error-message container id/class was captured live (the 2026-08-07
    ...    capture recorded controls only, not validation-error markup, since no invalid
    ...    submission was made under the zero-store-traffic constraint) — PROVISIONAL,
    ...    supplementary evidence only; never crashes (returns an empty string if no enclosing
    ...    container is found or the name is unrecognised). Callers should use the page-level
    ...    union oracles below as the hard assertion.
    [Arguments]    ${field_name}
    ${selector}=    Set Variable If
    ...    '${field_name}' == 'email'    ${CONTACT_EMAIL_INPUT}
    ...    '${field_name}' == 'firstName'    ${FIRST_NAME_INPUT}
    ...    '${field_name}' == 'lastName'    ${LAST_NAME_INPUT}
    ...    '${field_name}' == 'address1'    ${ADDRESS1_INPUT}
    ...    '${field_name}' == 'postalCode'    ${POSTAL_CODE_INPUT}
    ...    '${field_name}' == 'city'    ${CITY_INPUT}
    ...    ${None}
    IF    $selector == $None
        RETURN    ${EMPTY}
    END
    ${status}    ${text}=    Run Keyword And Ignore Error
    ...    Get Text    ${selector} >> xpath=ancestor::div[1]
    IF    '${status}' == 'PASS'
        RETURN    ${text}
    END
    RETURN    ${EMPTY}

Page Level Error Region Text
    [Documentation]    Returns the checkout page's visible text so callers can assert/log a
    ...    page-level validation-error region. Text-based oracle — no stable page-level
    ...    error-region container id/class was captured live (2026-08-07); same union-oracle
    ...    philosophy as resources/pages/account_pages.resource.
    ${text}=    Checkout Page Text
    RETURN    ${text}

Required Field Validation Should Be Shown
    [Documentation]    Asserts submitting checkout with required fields blank is refused with
    ...    validation evidence (TC-09-002; TB-VAL-001..005): a validation/required/error message
    ...    in the page text, OR the browser remaining on checkout (/checkouts/) rather than
    ...    advancing — union oracle, mirroring resources/pages/account_pages.resource's
    ...    "Empty Login Validation Should Be Shown" pattern for an un-verified validation surface.
    ${page_text}=    Checkout Page Text
    ${message_hit}=    Run Keyword And Return Status    Should Match Regexp    ${page_text}
    ...    (?i)(required|can.?t be blank|fill (in|out)|this field|enter (your|a valid)|missing)
    ${still_on_checkout}=    Run Keyword And Return Status    Get Url    contains    /checkouts/
    Should Be True    ${message_hit} or ${still_on_checkout}
    ...    msg=Missing-required-field submission was neither validated with a message nor safely refused (still on checkout)

Email Format Validation Should Be Shown
    [Documentation]    Asserts submitting checkout with a malformed e-mail is refused with
    ...    validation evidence (TC-09-003; TB-VAL-003): an e-mail/format message in the page text,
    ...    OR the browser remaining on checkout — union oracle (same rationale as
    ...    `Required Field Validation Should Be Shown`).
    ${page_text}=    Checkout Page Text
    ${message_hit}=    Run Keyword And Return Status    Should Match Regexp    ${page_text}
    ...    (?i)(invalid email|email.{0,15}(invalid|not valid|format)|enter a valid email)
    ${still_on_checkout}=    Run Keyword And Return Status    Get Url    contains    /checkouts/
    Should Be True    ${message_hit} or ${still_on_checkout}
    ...    msg=Invalid-email submission was neither validated with a message nor safely refused (still on checkout)

Payment Rejection Should Be Shown
    [Documentation]    Asserts a payment attempt with invalid/garbage card data is rejected: the
    ...    browser must NOT advance to order confirmation (hard, safety-relevant assertion). A
    ...    payment-error/rejection message in the page text is additionally captured and logged as
    ...    supporting evidence (soft — exact wording was not observable under this task's
    ...    zero-store-traffic constraint before a live run).
    ${page_text}=    Checkout Page Text
    ${message_hit}=    Run Keyword And Return Status    Should Match Regexp    ${page_text}
    ...    (?i)(payment|card).{0,30}(error|invalid|declined|issue|problem|reject)
    Log    Payment-rejection message evidence present: ${message_hit}
    Checkout Should Not Have Advanced To Confirmation

Enter Card Number
    [Documentation]    Types into the card-number PCI iframe (cross-origin, random id suffix per
    ...    load — selected by prefix and pierced with the Browser library ">>>" syntax).
    [Arguments]    ${value}
    Fill Text    ${CARD_NUMBER_FRAME_INPUT}    ${value}

Enter Card Expiry
    [Documentation]    Types into the card-expiry PCI iframe (MM / YY).
    [Arguments]    ${value}
    Fill Text    ${CARD_EXPIRY_FRAME_INPUT}    ${value}

Enter Card Security Code
    [Documentation]    Types into the card security-code (CVV) PCI iframe.
    [Arguments]    ${value}
    Fill Text    ${CARD_SECURITY_CODE_FRAME_INPUT}    ${value}

Enter Card Name
    [Documentation]    Types into the name-on-card PCI iframe.
    [Arguments]    ${value}
    Fill Text    ${CARD_NAME_FRAME_INPUT}    ${value}

Enter Card Details
    [Documentation]    Convenience wrapper: fills all four card PCI iframe fields in one call.
    [Arguments]    ${number}    ${expiry}    ${security_code}    ${name}=${FICTITIOUS_FULL_NAME}
    Enter Card Number    ${number}
    Enter Card Expiry    ${expiry}
    Enter Card Security Code    ${security_code}
    Enter Card Name    ${name}

Click Pay Now
    [Documentation]    Clicks the stable #checkout-pay-button ("Pay now") to submit payment.
    Click    ${PAY_BUTTON}

Payment Alert Text
    [Documentation]    Returns the checkout page's visible text for callers to assert/log a
    ...    payment alert (for example the card-2 decline message, or the card-3 gateway-failure
    ...    alert plus Request ID). Text-based oracle — no stable alert-container locator was
    ...    captured (2026-08-07).
    ${text}=    Checkout Page Text
    RETURN    ${text}

Checkout Problem Banner Present
    [Documentation]    Returns True when the recurring transient banner "There was a problem with
    ...    our checkout" is currently visible. Captured 2026-08-07 as a technical-health
    ...    characteristic of this live checkout: callers must never assert its ABSENCE elsewhere
    ...    (it is known to appear intermittently regardless of test action); TC-12-006 is the one
    ...    case in this suite family that asserts its PRESENCE, which is a distinct, expected
    ...    use.
    ${present}=    Run Keyword And Return Status    Get Text    body    contains
    ...    ${CHECKOUT_PROBLEM_BANNER_TEXT}
    RETURN    ${present}

Order Confirmation Should Be Reached
    [Documentation]    Asserts the browser has reached the post-payment order-confirmation page
    ...    (verified live confirmation page, order #1YRC8ZIPW format, 5 Aug 2026): a "Thank you"
    ...    heading is present and a confirmation-number pattern is found in the page text.
    ...    PROVISIONAL text pattern (see file Documentation) — only reachable under an
    ...    ALLOW_ORDERS-authorized run.
    Get Text    body    contains    Thank you
    ${page_text}=    Checkout Page Text
    Should Match Regexp    ${page_text}    [#][A-Za-z0-9]{6,}
    ...    msg=No confirmation-number pattern (#<alphanumeric>) found on the post-payment page

Confirmation Page Should Contain
    [Documentation]    Asserts the post-payment confirmation page's visible text contains the
    ...    given string (product name, totals, order-detail sections). Same underlying mechanic as
    ...    "Checkout Page Should Contain" — kept as a separately named keyword for call-site
    ...    honesty once payment has succeeded and the browser has moved past checkout onto the
    ...    confirmation page.
    [Arguments]    ${text}
    Get Text    body    contains    ${text}

Confirmation Number Text
    [Documentation]    Returns the confirmation page's visible text for callers to log/assert the
    ...    order/confirmation number (verified format, e.g. "#1YRC8ZIPW", 5 Aug 2026) as
    ...    execution-log evidence (TC-13-002). No stable container locator was captured for the
    ...    confirmation page (see file Documentation) — text-based oracle.
    ${text}=    Checkout Page Text
    RETURN    ${text}

Click Continue Shopping
    [Documentation]    Clicks the confirmation page's "Continue shopping" control, returning to
    ...    the storefront (verified behaviour 5 Aug 2026). PROVISIONAL locator (see file
    ...    Documentation) — only reachable under an ALLOW_ORDERS-authorized run.
    Click    ${CONTINUE_SHOPPING_LINK}

Post Purchase Account Offer Present
    [Documentation]    Returns True if the confirmation page presents an account-creation offer.
    ...    Observed 5 Aug 2026: none present — TC-15-005 asserts this True and is expected to FAIL
    ...    live (known-defect-lead evidence per 02 v2.1 §REWORDS), the same pattern used by
    ...    tests/ts14_secondary_services.robot and tests/ts17_search.robot.
    ${page_text}=    Checkout Page Text
    ${hit}=    Run Keyword And Return Status    Should Match Regexp    ${page_text}
    ...    (?i)(create (an|your) account|save your information|sign up for|register).{0,40}(account|faster checkout)
    RETURN    ${hit}
