<#
    .SYNOPSIS
        Configure Hyper-V VSwitch
    .DESCRIPTION
        Configure 1 external card (wifi or etherne) and, optionally, 1 internal and/or 1 private card
    .PARAMETER NetworkAdapaterName
        Specify your network adapater name. If your wifi card is named "wifi", specify "wifi" with this parameter
    .PARAMETER InternalVSwitch
        Specify if you want to have an internal vSwitch or not. $True for "Yes" or $False for "No". The name of the vSwitch will be "InternalvSwitch"
    .PARAMETER PrivateVSwitch
        Specify if you want to have an private vSwitch or not. $True for "Yes" or $False for "No". The name of the vSwitch will be "PrivatevSwitch"
    .EXAMPLE
        .\HYPERV_Add-HypervSwitch -NetworkAdapterName "wifi" -InternalVSwitch $True -ExternalVSwitch $True
        This example will create an external switch based on the wifi card, an internal switch and a private one
    .EXAMPLE
        .\HYPERV_Add-HypervSwitch -NetworkAdapterName "wifi"
        This example will create an external switch based on the wifi card
    .EXAMPLE
        .\HYPERV_Add-HypervSwitch -NetworkAdapterName "wifi" -InternalVSwitch $True
        This example will create an external switch based on the wifi card and an internal switch
    .EXAMPLE
        .\HYPERV_Add-HypervSwitch -NetworkAdapterName "wifi" -InternalVSwitch $True -ExternalVSwitch $False
        This example will create an external switch based on the wifi card, an internal switch and a private one
    .EXAMPLE
        .\HYPERV_Add-HypervSwitch -NetworkAdapterName "wifi" -InternalVSwitch $False -ExternalVSwitch $True
        This example will create an external switch based on the wifi card and a private one
    .EXAMPLE
        .\HYPERV_Add-HypervSwitch -NetworkAdapterName "wifi" -ExternalVSwitch $True
        This example will create an external switch based on the wifi card and a private one
    .NOTES
        Script tested on : Windows 10 Pro & Enterprise
        Author : Sylver SCHORGEN
        Blog : http://microsofttouch.fr/default/b/sylver
        Created : 21 dec. 2015
        @sylver_schorgen
#>

Param(
    [Parameter(Mandatory=$false)]
    [string]$NetworkAdapterName,
    [Parameter(Mandatory=$false)]
    [boolean]$InternalVSwitch,
    [Parameter(Mandatory=$false)]
    [boolean]$PrivateVSwitch
)

#region Module Import
Import-Module Hyper-V
#endregion

#region Variable initialization
Write-Host
Write-Host
Write-Host "Setting up initial variables ... " -NoNewLine

$InternalVSwitchName = "Internal vSwitch"
$PrivateVSwitchName = "Private vSwitch"
$ExternalVSwitchName = "External vSwitch"

Write-Host "Ok !" -ForeGroundColor Green
Write-Host
#endregion

#region Internal vSwitch creation
if($InternalVSwitch -eq $True) {
    $vSwitch = Get-VMSwitch -SwitchType Internal -Name $InternalVSwitchName -ErrorAction SilentlyContinue
    if($vSwitch -eq $null) {
        Write-Host "Creating Internal vSwitch ... " -NoNewLine
        
        New-VMSwitch -Name $InternalVSwitchName -SwitchType Internal -Notes "vSwitch used to communicate between VM and the parent operating system" | Out-Null
        
        Write-Host "Ok !" -ForegroundColor Green
        Write-Host
    }
    else {
        Write-Host "The internal vSwitch already exists !" -ForegroundColor Yellow
        Write-Host
    }
}
else {
    Write-Host "No Internal vSwitch was created because the parameter -InternalVSwitch is set to $False or is not set" -ForegroundColor Yellow
}
#endregion

#region Private vSwitch creation
if($PrivateVSwitch -eq $True) {
    $vSwitch = Get-VMSwitch -SwitchType Private -Name $PrivateVSwitchName -ErrorAction SilentlyContinue
    if($vSwitch -eq $null) {
        Write-Host "Creating Private vSwitch ... " -NoNewLine
        
        New-VMSwitch -Name $PrivateVSwitchName -SwitchType Private -Notes "vSwitch used to communicate between VM only" | Out-Null
        
        Write-Host "Ok !" -ForegroundColor Green
        Write-Host
    }
    else {
        Write-Host "The private vSwitch already exists !" -ForegroundColor Yellow
        Write-Host
    }
}
else {
    Write-Host "No Private vSwitch was created because the parameter -PrivateVSwitch is set to $False or is not set" -ForegroundColor Yellow
    Write-Host
}
#endregion

#region External vSwitch creation
$ExternalvSwitch = Get-VMSwitch -SwitchType External -Name $ExternalVSwitchName -ErrorAction SilentlyContinue

if($ExternalvSwitch -eq $null) {
    Write-Host "Creating External vSwitch ... " -NoNewLine
        
    New-VMSwitch -Name "External vSwitch" -NetAdapterName $NetworkAdapterName -Notes "OS Parent, VM et Internet" | Out-Null
        
    Write-Host "Ok !" -ForegroundColor Green
    Write-Host
    Write-Host
}
else {
    Write-Host "The external vSwitch already exists !" -ForegroundColor Yellow
    Write-Host
    Write-Host
}
#endregion