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
| add_customer | Adds an ecommerce Customer to SugarCRM. Creates an Account and a linked Contact within SugarCRM, both of which have an ID which is that of the Customer object sent from the Hub. |
| update_customer | Updates an Account and linked Contact within SugarCRM. |
| add_order | Adds an ecommerce Order to SugarCRM. Creates an Opportunity within SugarCRM with a status of "Closed Won." The SugarCRM Opportunity has an ID which is that of the Order object sent from the Hub. |
| update_order | Updates an ecommerce Order's corresponding Opportunity within SugarCRM. |

## Testing
Coming soon ...
