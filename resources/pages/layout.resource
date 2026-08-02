*** Settings ***
Documentation     Page object: persistent site chrome present on every storefront page —
...               the header (cart badge, search box) and sidebar navigation. Locators for
...               these shared elements live ONLY here.
Library           Browser

*** Variables ***
${SEARCH_BOX}       css=input[name="q"]:visible
${CATALOGUE_NAV}    css=a[href*="/collections/"]:visible

*** Keywords ***
Cart Badge Should Show
    [Documentation]    Asserts the header cart badge reads "My Cart (<count>)".
    [Arguments]    ${count}
    Get Text    body    contains    My Cart (${count})

Cart Indicator Should Be Present
    Get Text    body    contains    My Cart (

Search Box Should Be Present
    Get Element Count    ${SEARCH_BOX}    >    0

Catalogue Navigation Should Be Present
    Get Element Count    ${CATALOGUE_NAV}    >    0

Search For
    [Documentation]    Types the term into the header search box and submits with Enter.
    [Arguments]    ${term}
    Fill Text    ${SEARCH_BOX}    ${term}
    Keyboard Key    press    Enter

Go To Catalogue Via Navigation
    Click    ${CATALOGUE_NAV}
