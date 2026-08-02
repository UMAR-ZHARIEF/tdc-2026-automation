*** Settings ***
Documentation     Page object: search results (/search). Result-grid interaction is provided
...               by the product_listing component; the search box itself belongs to layout.
Library           Browser
Resource          ../common.resource

*** Keywords ***
Open Search Results For
    [Arguments]    ${term}
    Go To    ${STORE_URL}search?q=${term}

Should Be On Search Results
    Get Url    contains    /search
