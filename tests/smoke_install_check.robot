*** Settings ***
Documentation     Installation smoke check for TDC 2.0 automation stack.
...               Opens the Test Object homepage in headless Edge and verifies the page title.
...               Traffic footprint: a single page load (competition-guideline compliant).
Library           SeleniumLibrary

*** Variables ***
${STORE_URL}      https://sauce-demo.myshopify.com/
${BROWSER}        edge

*** Test Cases ***
Store Homepage Opens And Shows Expected Title
    [Documentation]    Entry-criterion check: Test Object reachable, homepage renders, title correct.
    Open Browser    ${STORE_URL}    ${BROWSER}    options=add_argument("--headless=new")
    Title Should Be    Sauce Demo
    [Teardown]    Close All Browsers
