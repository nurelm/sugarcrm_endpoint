# SugarCRM Integration

## Overview

[SugarCRM](http://www.sugarcrm.com/) is a popular customer relationship management system.

This is a fully hosted and supported integration for use with the [Wombat](http://wombat.co) product. With this integration you can perform the following functions:

* Send product information to SugarCRM whenever products are created or updated.
* Send customer and order information to SugarCRM whenever orders are created or updated.

## Connection Parameters

The following parameters must be setup within Wombat:

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

[Wombat](http://wombat.co) allows you to connect to your own custom integrations.  Feel free to modify the source code and host your own version of the integration - or beter yet, help to make the official integration better by submitting a pull request!

![Wombat Logo](http://spreecommerce.com/images/wombat_logo.png)

This integration is 100% open source an licensed under the terms of the New BSD License.
