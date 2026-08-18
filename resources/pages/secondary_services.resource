*** Settings ***
Documentation     Page object: oracle logic for TS-14 Secondary & Support Services (UC-14) —
...               built on top of layout.resource's Wish list / Refer a
...               Friend / social-links chrome rather than redefining locators. Provides: a
...               generic before/after response-fingerprint check (used for the inert
...               wishlist/refer-a-friend/guest-wishlist remnants), a Don't
...               #3-compliant social-link sweep (presence and href only, never
...               navigated to), a pre-purchase support-channel sweep, and an
...               observation-only referral-sharing check that passes on either branch.
Library           Browser
Resource          ../common.resource
Resource          layout.resource

*** Keywords ***
Current Page Fingerprint
    [Documentation]    Returns a "URL-without-fragment|visible-element-count" runtime snapshot —
    ...    a lightweight proxy for "did anything meaningfully change" (navigation OR new visible
    ...    content/dialog), used to detect a response from controls whose behaviour is otherwise
    ...    undocumented.
    ...
    ...    THE URL FRAGMENT IS DELIBERATELY EXCLUDED. The inert Sauce-app controls are anchors
    ...    (href="#sauce-show-wish-list", href="#sauce-show-refer-friend"), so activating one
    ...    appends a fragment to the URL while changing nothing else whatsoever. Including the
    ...    fragment made this oracle report that dead control as a meaningful response: on
    ...    12 Aug 2026 TC-14-001, TC-14-002 and TC-14-004 all PASSED with an identical visible-
    ...    element count of 95 before and after, differing only by "#sauce-show-wish-list".
    ...    Those were vacuous passes that certified a known defect as working. A fragment-only
    ...    change is navigation in name only and must not count as a response.
    ${url}=    Get Url
    ${base_url}=    Evaluate    $url.split("#")[0]
    ${count}=    Get Element Count    css=body *:visible
    ${fingerprint}=    Set Variable    ${base_url}|${count}
    RETURN    ${fingerprint}

Page Response Should Have Changed
    [Documentation]    Asserts a control produced a meaningful response — its activation
    ...    changed either the URL or the page's visible-element count relative to the given
    ...    "before" fingerprint (click-verified 5 Aug 2026): the Wish list and
    ...    Refer a Friend controls are documented inert Sauce-app remnants that produce no
    ...    response, so this oracle is EXPECTED TO FAIL live when applied to them — the FAIL is
    ...    the harvested defect evidence (known-defect-lead), not test breakage.
    [Arguments]    ${before_fingerprint}
    ${after_fingerprint}=    Current Page Fingerprint
    Should Not Be Equal    ${before_fingerprint}    ${after_fingerprint}
    ...    msg=No meaningful response (no URL change, no visible-content change) followed activating the control

All Social Links Should Have External Targets
    [Documentation]    Sweeps every social link found via layout.resource's ${SOCIAL_LINKS}
    ...    locator: asserts each has a non-empty href pointing off-store, and logs the target as
    ...    the recorded evidence (recorded targets: facebook.com/shopify,
    ...    twitter.com/sauce_io [defunct], instagram.com/shopify, a personal Pinterest board).
    ...    Per competition Don't #3, targets are never navigated to or clicked — presence and
    ...    href value only.
    ${n}=    Social Link Count
    Should Be True    ${n} > 0    msg=No social links found in the storefront chrome
    FOR    ${i}    IN RANGE    ${n}
        ${href}=    Social Link Target At Index    ${i}
        Should Not Be Empty    ${href}    msg=Social link at index ${i} has an empty href
        Should Not Contain    ${href}    sauce-demo.myshopify.com
        ...    msg=Social link at index ${i} unexpectedly targets the store itself, not an external site
        Log    Social link target ${i} (recorded evidence per Don't #3 — not navigated): ${href}
    END

Support Channel Should Be Present On Current Page
    [Documentation]    Union oracle: asserts a working pre-purchase support/contact affordance
    ...    is present on the current page — a mailto: link, a tel: link, or a link whose text
    ...    contains "contact". Per Test Basis v1.0 (observed 5 Aug 2026) none exists
    ...    pre-purchase — the sole channel is a defunct post-purchase mailto to a third-party
    ...    address — so this oracle is EXPECTED TO FAIL on every pre-purchase page swept here;
    ...    the FAIL is the harvested defect evidence (known-defect-lead), not test breakage. The
    ...    confirmation-page half of the underlying TCS case needs a placed order and is
    ...    manual-scope, out of this keyword's (and TC-14-005's) reach.
    [Arguments]    ${page_label}
    ${mailto_hits}=    Get Element Count    css=a[href^="mailto:"]:visible
    ${tel_hits}=    Get Element Count    css=a[href^="tel:"]:visible
    ${contact_hits}=    Get Element Count    xpath=//a[contains(normalize-space(),'Contact') or contains(normalize-space(),'contact')]
    ${total}=    Evaluate    ${mailto_hits} + ${tel_hits} + ${contact_hits}
    Log    Support-channel sweep on ${page_label}: mailto=${mailto_hits}, tel=${tel_hits}, contact-text=${contact_hits} (evidence).
    Should Be True    ${total} > 0
    ...    msg=No pre-purchase support/contact affordance found on ${page_label} (known defect: the sole channel is a defunct post-purchase mailto)

Referral Mechanism Observation
    [Documentation]    Observation-logger, NOT a defect-lead: checks the current page for a
    ...    referral/share-with-a-friend mechanism (the Refer a Friend control) and logs either
    ...    its presence or its absence — both outcomes PASS, per 02 v2.1's own either/or expected
    ...    result for TC-14-006 ("...exists and functions, OR its absence is recorded as an
    ...    observation (defunct Sauce feature)"). Deliberately carries no Should-type assertion
    ...    so it cannot fail on its own.
    [Arguments]    ${page_label}
    ${refer_hits}=    Get Element Count    ${REFER_FRIEND_LINK}
    IF    ${refer_hits} > 0
        Log    Referral/share mechanism found on ${page_label} (Refer a Friend control) — presence recorded as the observation; TC-14-006 does not re-exercise its response beyond TC-14-002's own check.
    ELSE
        Log    No referral/share mechanism found on ${page_label} — absence recorded as the observation per 02 v2.1 (defunct Sauce feature).
    END
    Log    TC-14-006 observation for ${page_label} complete; this case passes on either branch by design.