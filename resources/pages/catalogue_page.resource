*** Settings ***
Documentation     Page object: the catalogue listing (/collections/all). Product-grid
...               interaction is provided by the product_listing component.
Library           Browser
Resource          ../common.resource

*** Keywords ***
Open Catalogue
    Go To    ${STORE_URL}collections/all

Should Be On Catalogue
    Get Url    contains    /collections/
