   <# 
.SYNOPSIS 
    Copy a production database to a staging database in Azure. 
 
.DESCRIPTION 
    This runbook is designed to copy a database and log to Application Insights for audit purposes. A runbook like 
    this might be implemented to regularly keep staging or testing environment database synced with a live production database.
    
    An Azure "RunAsAccount" needs to be created for the Automation account. Documentation can be found here
    https://docs.microsoft.com/en-us/azure/automation/manage-runas-account#create-a-run-as-account-in-the-portal
    
    Finally, to log to Applications Insights, the Custom Events Module ("ApplicationInsightsCustomEvents.zip") must 
    be imported in the Automation account under the "Modules" pane. The zip file can be found here:
    https://gallery.technet.microsoft.com/scriptcenter/Log-Custom-Events-into-847900d7
 
.PARAMETER SourceServer 
    String name of the source SQL Server you want to copy from
 
.PARAMETER SourceResourceGroup 
    String name of Azure resource group the SourceServer is contained in
    
.PARAMETER SourceDatabase 
    String name of the source Azure Database to be copied
 
.PARAMETER CopyDatabase
    String name of the new copy of the Azure SourceDatabase  

.PARAMETER CopyResourceGroup
    String name of Azure resource group the CopyDatabase is contained in

.PARAMETER CopyServer
    String name of the destination SQL Server you want to copy to

.PARAMETER InstrumentationKey
    Instrumentation key of application insights account to which logs will be stored
 
.EXAMPLE 
    Use-SqlCommandSample -SourceServer "SourceServername" -SourceResourceGroup "SourceResourceGroupName" -SourceDatabase "SourceDatabaseName" -CopyDatabase "CopyDatabaseName" -$CopyResourceGroup "CopyResourceGroupName" -$CopyServer "$CopyServerName" -InstrumentationKey "123-***234"
   
#> 

param( 
    [parameter(Mandatory=$True)] 
    [string] $SourceServer, 
     
    [parameter(Mandatory=$True)] 
    [string] $SourceResourceGroup, 

    [parameter(Mandatory=$True)] 
    [string] $SourceDatabase, 

    [parameter(Mandatory=$True)] 
    [string] $CopyDatabase, 
     
    [parameter(Mandatory=$False)] 
    [string] $CopyResourceGroup = $SourceResourceGroup,

    [parameter(Mandatory=$False)] 
    [string] $CopyServer = $SourceServer,

    [parameter(Mandatory=$False)]
    [string] $InstrumentationKey
)

    #Function to log to Applications Insight
    function LogAppInsight ([string]$message) 
    {
        $dictionary = New-Object 'System.Collections.Generic.Dictionary[string,string]' 
        $dictionary.Add('Message',"$message") | Out-Null 
        Log-ApplicationInsightsEvent -InstrumentationKey $InstrumentationKey -EventName "Azure Automation" -EventDictionary $dictionary
    }

    #Azure Authentication
    function Login() 
    { 
        $connectionName = "AzureRunAsConnection" 
        try {
            $servicePrincipalConnection = Get-AutomationConnection -Name $connectionName

            Write-Verbose "Logging in to Azure..." -Verbose
            
            Add-AzureRmAccount `
                -ServicePrincipal `
                -TenantId $servicePrincipalConnection.TenantId `
                -ApplicationId $servicePrincipalConnection.ApplicationId `
                -CertificateThumbprint $servicePrincipalConnection.CertificateThumbprint | Out-Null 
        }catch { 
            if (!$servicePrincipalConnection) 
            {
                $ErrorMessage = "Connection $connectionName not found."
                throw $ErrorMessage 
            } else{ 
                Write-Error -Message $_.Exception 
                throw $_.Exception 
                } 
            } 
    }

    Login

    try{

        Write-Output "Removing old copy..."
        Remove-AzureRmSqlDatabase -ResourceGroupName $CopyResourceGroup -ServerName $CopyServerName -DatabaseName $CopyDatabaseName -Force

        Write-Output "Start Copy... Please wait ... "
        New-AzureRmSqlDatabaseCopy -ResourceGroupName $SourceResourceGroup `
            -ServerName $SourceServer `
            -DatabaseName $SourceDatabase `
            -CopyResourceGroupName $CopyResourceGroup `
            -CopyServerName $CopyServer `
            -CopyDatabaseName $CopyDatabase
        
        if($InstrumentationKey)
        {
            LogAppInsight "Success, database copied: $CopyDatabase"
        }
        Write-Output "Success, database copied: $CopyDatabase"

    }catch {
        $ErrorMessage = $_.Exception.Message
        if($InstrumentationKey)
        {
            LogAppInsight "Failed: $ErrorMessage"
        }
        Write-Output "Failed: $Errormessage"
    }