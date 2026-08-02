*** Settings ***
Documentation     Page object: storefront homepage.
Library           Browser
Resource          ../common.resource

*** Keywords ***
Open Home
    Go To    ${STORE_URL}

Home Title Should Be Correct
    Get Title    ==    Sauce Demo
