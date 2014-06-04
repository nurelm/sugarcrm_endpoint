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

The chosen user must have Developer rights to all SugarCRM objects mentioned below. See SugarCRM's Admin -> Role Management options (as an administrative user).

## Webhooks
The following webhooks are implemented:

| Name | Description |
| :----| :-----------|
| add_customer | Adds an ecommerce Customer to SugarCRM. Creates an Account and a linked Contact within SugarCRM. We search for an existing SugarCRM Contact with a matching email address, and create one if it does not exist, then search for that Contact's parent Account, creating one if it does not exist. If an existing SugarCRM Contact is found, it is updated based on the Hub Customer information passed in. If an existing SugarCRM Account is found, it is NOT updated. |
| update_customer | Updates an Account and linked Contact within SugarCRM, and functions exactly like add_customer. |
| add_order | Adds an ecommerce Order to SugarCRM. Creates an Opportunity within SugarCRM with a status of "Closed Won." The SugarCRM Opportunity has an ID which has a prefix of "hub-" and is followed by the ID of the Order object sent from the Hub, and has one RevenueLineItem corresponding to each line item, as well for adjustments, tax and shipping. Each RevenueLineItem corresponding to a product line item is linked within SugarCRM to its corresponding ProductTemplate using the SKU. |
| update_order | Updates an ecommerce Order's corresponding Opportunity within SugarCRM. |
| add_product | Adds an ecommerce Product to SugarCRM. Creates a ProductTemplate within SugarCRM. The SugarCRM ProductTemplate has an ID which is that of the SKU of theProduct object sent from the Hub. |
| update_product | Updates an ecommerce Product's corresponding ProductTemplate within SugarCRM. |
| add_shipment and update_shipment | Adds an ecommerce Shipment to SugarCRM as a note linked to the corresponding Opportunity. |

## Testing
Coming soon ...
