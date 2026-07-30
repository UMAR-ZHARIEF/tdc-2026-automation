*** Settings ***
Documentation     Your first hands-on Robot Framework test (from the DIY guide).
...               Runs in VISIBLE Edge on purpose - so you can watch it work.
...               Run it yourself from the project folder with:
...               py -m robot --outputdir automation\results automation\tests\my_first_test.robot
Library           SeleniumLibrary

*** Test Cases ***
My First Test
    [Documentation]    Opens the Test Object homepage and checks the page title.
    Open Browser    https://sauce-demo.myshopify.com/    edge
    Title Should Be    Sauce Demo
    [Teardown]    Close All Browsers
