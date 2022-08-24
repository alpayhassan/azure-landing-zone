# azure-landing-zone

This is a landing zone I have configured using Terraform for a company that is looking to migrate their infrastructure to Azure.
The subscriptions within the landing zone are supposed to be mostly empty with the exception that it consists of foundational Azure services and resources. 

It consists of 4 subscriptions: 

1. Connectivity
 - Contains the hub network and would provide connectivity to the company's on-premise network.
 - Foundational resources: hub network, firewall, VPN gateway and ddos plan.
 
2. Management
 - Contains monitoring and logging services.
 - Foundational resources: automation account and log analytics workspace / solution set up ready for the company to implement Azure Sentinel.
 
3. Online Landing Zone
 - This subscription would hold the company's internet-facing / online applications.
 - I have included a few resources in there such as an app service plan, but these are not foundational and this subscription could be left empty.
 
4. Corporate Landing Zone
 - This subscription would hold the company's on-premise-facing application e.g. an invoice service.
