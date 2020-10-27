Clone Azure SQL Database and Log to Application Insights
========================================================

            

**Description**


This runbook is designed to copy a database and log to Application Insights for audit purposes. A runbook like this might be implemented to regularly keep staging or testing environment database synced with a live production database.


**Requirements**


An Azure 'RunAsAccount' needs to be created for the Automation account. Documentation can be found [here](https://docs.microsoft.com/en-us/azure/automation/manage-runas-account#create-a-run-as-account-in-the-portal)


Finally, to log to Applications Insights, the Custom Events Module ('ApplicationInsightsCustomEvents.zip') must be imported in the Automation account under the 'Modules' pane. The zip file can be found [here](https://gallery.technet.microsoft.com/scriptcenter/Log-Custom-Events-into-847900d7)


**Runbook Content**


The runbook contents are displayed below

[ ](https://gallery.technet.microsoft.com/scriptcenter/Log-Custom-Events-into-847900d7)

        
    
TechNet gallery is retiring! This script was migrated from TechNet script center to GitHub by Microsoft Azure Automation product group. All the Script Center fields like Rating, RatingCount and DownloadCount have been carried over to Github as-is for the migrated scripts only. Note : The Script Center fields will not be applicable for the new repositories created in Github & hence those fields will not show up for new Github repositories.
