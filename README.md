# SugarCRM Integration for Spree Hub

## Overview
[SugarCRM](http://www.sugarcrm.com/) is a popular customer relationship management system.

This integration provides an endpoint for use with [Spree Hub](http://spreecommerce.com/hub) and version 7.x of
SugarCRM.

## Connection Parameters
The following parameters must be setup within Spree Hub:

| Name | Value |
| :----| :-----|
| sugarcrm_username | SugarCRM account username (required) |
| sugarcrm_password | SugarCRM account password (required) |
| sugarcrm_url | SugarCRM base URL (required). Example: https://mysugaraccount.sugarcrm.com |

## Webhooks
The following webhooks are implemented:

| Name | Description |
| :----| :-----------|
| add_customer | Adds an ecommerce customer to SugarCRM. Creates an Account and a linked Contact within
SugarCRM. |
| update_customer | Updates an Account and linked Contact within SugarCRM. |
| add_order | Adds an ecommerce order to SugarCRM. Creates an Opportunity within SugarCRM with a status of "Closed Won" |
| update_order | Updates an ecommerce Order's corresponding Opportunity within SugarCRM. |

## Testing
Coming soon ...
