This is a mock Azure Landing Zone I have configured using Terraform for a company that is looking to migrate their infrastructure to Azure.
Landing Zones help organisations make governance, strategy and security decisions when adopting cloud frameworks.
The subscriptions within the landing zone are mostly empty, consisting of foundational Azure services / resources.


We can imagine that this company would have an a corporate-facing custom-built application and an internet-facing application.
This framework consists of 4 subscriptions:

Connectivity:
Contains the hub network and would provide connectivity to the company's on-premise network.
Foundational resources: hub network, firewall, VPN gateway and ddos plan.

Management:
Contains monitoring and logging services.
Foundational resources: automation account and log analytics workspace / solution set up ready for the company to implement Azure Sentinel.

Online Landing Zone:
This subscription would hold the company's internet-facing / online applications.
I have included a few resources in there such as an app service plan, but these are not foundational and this subscription could be left empty.

Corporate Landing Zone:
This subscription would hold the company's on-premise-facing application e.g. an invoice service.
