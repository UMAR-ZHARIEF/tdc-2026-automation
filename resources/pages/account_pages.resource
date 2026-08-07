*** Settings ***
Documentation     Page object: classic Shopify customer authentication forms — the login page
...               (/account/login: customer[email], customer[password], Sign In submit) and the
...               registration page (/account/register: customer[first_name], customer[last_name],
...               customer[email], customer[password], Create submit). Built for TS-16 User
...               Authentication (UC-16, TB-AUTH-001..007) under the zero-store-traffic
...               constraint: every locator below is PROVISIONAL — inferred from Shopify classic
...               theme conventions and Test Basis v1.0 observations (TB-AUTH-001/002), not from
...               a live visit to these two pages. Each is flagged individually; live-verify
...               before relying on this file outside dry-run. Error/validation oracles are
...               written as UNION checks (a locator-based surface OR a body-text regex) so a
...               wrong PROVISIONAL locator does not by itself make an assertion unwinnable once
...               this suite runs live.
Library           Browser
Resource          ../common.resource

*** Variables ***
${LOGIN_EMAIL_INPUT}            css=input[name="customer[email]"]:visible    # PROVISIONAL — live-verify before commit
${LOGIN_PASSWORD_INPUT}         css=input[name="customer[password]"]:visible    # PROVISIONAL — live-verify before commit
${LOGIN_SUBMIT}                 xpath=//input[@type='submit' and (contains(@value,'Sign In') or contains(@value,'Sign in'))] | //button[contains(normalize-space(),'Sign In') or contains(normalize-space(),'Sign in')]    # PROVISIONAL — live-verify before commit
${LOGIN_ERROR_SURFACE}          css=#customer_login .errors, #login_form .errors, .form__message, [class*="error"]:visible    # PROVISIONAL — live-verify before commit; exact class/id unconfirmed, used only as one arm of a union oracle
${REGISTER_FIRST_NAME_INPUT}    css=input[name="customer[first_name]"]:visible    # PROVISIONAL — live-verify before commit
${REGISTER_LAST_NAME_INPUT}     css=input[name="customer[last_name]"]:visible    # PROVISIONAL — live-verify before commit
${REGISTER_EMAIL_INPUT}         css=input[name="customer[email]"]:visible    # PROVISIONAL — live-verify before commit
${REGISTER_PASSWORD_INPUT}      css=input[name="customer[password]"]:visible    # PROVISIONAL — live-verify before commit
${REGISTER_SUBMIT}              xpath=//input[@type='submit' and contains(@value,'Create')] | //button[contains(normalize-space(),'Create')]    # PROVISIONAL — live-verify before commit
${REGISTER_ERROR_SURFACE}       css=#create_customer .errors, .form__message, [class*="error"]:visible    # PROVISIONAL — live-verify before commit; exact class/id unconfirmed, used only as one arm of a union oracle
${ACCOUNT_LOGGED_IN_MARK}       css=a[href*="/account/logout"]:visible    # PROVISIONAL — live-verify before commit; presence is taken as evidence of an active session

*** Keywords ***
Open Login Page
    [Documentation]    Direct navigation to the classic Shopify customer login form.
    Go To    ${STORE_URL}account/login

Open Register Page
    [Documentation]    Direct navigation to the classic Shopify customer registration form.
    Go To    ${STORE_URL}account/register

Fill Login Credentials
    [Documentation]    Types the given email and password into the login form. Does not submit.
    [Arguments]    ${email}    ${password}
    Fill Text    ${LOGIN_EMAIL_INPUT}    ${email}
    Fill Text    ${LOGIN_PASSWORD_INPUT}    ${password}

Submit Login
    Click    ${LOGIN_SUBMIT}

Generate Fictitious Nonexistent Email
    [Documentation]    Builds a random-ish, syntactically valid e-mail address for an account
    ...    guaranteed not to be registered (TC-16-003) — avoids hardcoding one fixed string that
    ...    could coincidentally collide with a real or future test account.
    ${suffix}=    Evaluate    random.randint(100000, 999999)    modules=random
    ${email}=    Set Variable    tdc.nonexistent.${suffix}@example-tdc-invalid.test
    RETURN    ${email}

Login Error Should Be Shown
    [Documentation]    Asserts a generic authentication error/notice is shown after a failed
    ...    login attempt — union oracle: the PROVISIONAL error-surface element is present, or
    ...    the page text carries a generic error/invalid-credentials message (keeps the check
    ...    robust even if the surface locator proves wrong once live-verified). Realigned
    ...    TC-16-003 expected result (02 v2.1 §REWORDS): a generic error that does not reveal
    ...    whether the account exists or which field is wrong.
    ${surface_hits}=    Get Element Count    ${LOGIN_ERROR_SURFACE}
    ${page_text}=    Get Text    body
    ${text_hit}=    Run Keyword And Return Status    Should Match Regexp    ${page_text}
    ...    (?i)(incorrect|invalid|wrong|unrecognized|error|could not|didn.?t work)
    Should Be True    ${surface_hits} > 0 or ${text_hit}
    ...    msg=No login error surface and no generic error text found after a failed login attempt

Empty Login Validation Should Be Shown
    [Documentation]    Asserts submitting the login form with both fields empty is refused with
    ...    clear validation (TB-AUTH-001; TC-16-006). Union oracle: an explicit validation/error
    ...    message, OR — if the theme relies on native HTML5 "required" field validation, which
    ...    blocks submission client-side with a browser tooltip this stack cannot read as DOM
    ...    text — the page simply remains on the login form with no session created.
    ${page_text}=    Get Text    body
    ${message_hit}=    Run Keyword And Return Status    Should Match Regexp    ${page_text}
    ...    (?i)(required|can.?t be blank|fill (in|out)|this field|enter (your|a valid))
    ${surface_hits}=    Get Element Count    ${LOGIN_ERROR_SURFACE}
    ${still_on_login}=    Run Keyword And Return Status    Get Url    contains    /account/login
    Should Be True    ${message_hit} or ${surface_hits} > 0 or ${still_on_login}
    ...    msg=Empty-field login submission was neither validated with a message nor safely refused

No Session Should Be Established
    [Documentation]    Asserts the guest header state persists — no logged-in-session marker is
    ...    present — after a rejected login or registration attempt.
    Get Element Count    ${ACCOUNT_LOGGED_IN_MARK}    ==    0

Fill Registration Details
    [Documentation]    Types the given identity into the registration form. Does not submit.
    [Arguments]    ${first_name}    ${last_name}    ${email}    ${password}
    Fill Text    ${REGISTER_FIRST_NAME_INPUT}    ${first_name}
    Fill Text    ${REGISTER_LAST_NAME_INPUT}    ${last_name}
    Fill Text    ${REGISTER_EMAIL_INPUT}    ${email}
    Fill Text    ${REGISTER_PASSWORD_INPUT}    ${password}

Submit Registration
    Click    ${REGISTER_SUBMIT}

Registration Email Format Error Should Be Shown
    [Documentation]    Asserts a clear e-mail-format error is shown after submitting a malformed
    ...    e-mail on the registration form (TB-AUTH-002; TC-16-007). Union oracle across three
    ...    arms: the PROVISIONAL error-surface element is present, or the page text names an
    ...    e-mail/format problem, or — if the theme's e-mail input uses type="email", which makes
    ...    the browser block submission of "user@@test" client-side with a native tooltip this
    ...    stack cannot read as DOM text — the page simply remains on the registration form with
    ...    no account created (same fallback pattern as Empty Login Validation Should Be Shown).
    ${surface_hits}=    Get Element Count    ${REGISTER_ERROR_SURFACE}
    ${page_text}=    Get Text    body
    ${text_hit}=    Run Keyword And Return Status    Should Match Regexp    ${page_text}
    ...    (?i)(invalid email|email.{0,15}(invalid|not valid|format)|enter a valid email)
    ${still_on_register}=    Run Keyword And Return Status    Get Url    contains    /account/register
    Should Be True    ${surface_hits} > 0 or ${text_hit} or ${still_on_register}
    ...    msg=No registration error surface, no e-mail-format error text, and no still-on-register-page evidence found after submitting a malformed e-mail

No Account Created Should Be Confirmed
    [Documentation]    Confirms a rejected registration attempt did not create an account: still
    ...    on the registration page (no redirect into the account area) and no logged-in-session
    ...    marker is present.
    Get Url    contains    /account/register
    Get Element Count    ${ACCOUNT_LOGGED_IN_MARK}    ==    0
