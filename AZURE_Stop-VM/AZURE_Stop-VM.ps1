<#
    .SYNOPSIS
        Script used for Azure Automation to stop all virtual machines
    .PARAMETER ResourceGroupName
        The Name of your resource group. In this case, you only have one resource group for all your VMs
    .DESCRIPTION
        Script used for Azure Automation to stop all virtual machines. You can configure it to launch every night at 10PM for exemple.
    .NOTES
        Author : Sylver SCHORGEN
        Blog : http://microsofttouch.fr/default/b/sylver
        Created : 10 aug. 2016
        Contact : contactme[at]schorgen.com
        @sylver_schorgen
#>


$ResourceGroupName = "ResourceGroupName"

try {
    $Conn = Get-AutomationConnection -Name AzureRunAsConnection
    Add-AzureRMAccount -ServicePrincipal -Tenant $Conn.TenantID -ApplicationId $Conn.ApplicationID -CertificateThumbprint $Conn.CertificateThumbprint | Out-Null
    Write-Output "Getting Azure Automation Account ... Done ! "
}
catch {
    Write-Error "Getting Azure Automation Error ... Could not get the Azure Account !"
    Exit
}

try {

    $VMS = Get-AzureRMVM
    Write-Output "Getting all Virtual Machines ... Done !"

    foreach($VM in $VMS) {

        $CurrentVM = (Get-AzureRMVM -Name $VM.Name -ResourceGroupName $ResourceGroupName -status).Statuses
        
        if($CurrentVM.DisplayStatus -eq "VM Running") {
            Write-Output "$($VM.Name) is on!"
            Stop-AzureRMVM -Name $VM.Name -ResourceGroupName $ResourceGroupName -Force | Out-Null
            Write-Output "$($VM.Name) has been shutdown !"
        }
        else {
            Write-Output "$($VM.Name) is already shutdown !"
        }

    }
}
catch {
    Write-Error "Getting all Virtual Machines ... Error while getting Virtual Machines !"
}

