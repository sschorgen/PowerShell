<#
    .SYNOPSIS
        Create Hyper-V VM
    .DESCRIPTION
        Create Hyper-V VM with internal and external vSwitch
    .PARAMETER VMName
        Specify the name of the VM (exemple : "VM-Test")
    .PARAMETER VHDPath
        Specify the name and path of the VHD (exemple : "D:\VHD\MyVHD.vhd")
    .PARAMETER VHDSize
        Specify the size of the VHD (exemple : 10GB)
    .PARAMETER VMMemory
        Specify the VM memory (exemple : 2048MB)
    .PARAMETER VMGeneration
        Specify the VM generation you want to create. Value can only be 1 or 2. Default value is 2.
    .PARAMETER Processor
        Specify the number of processor for the VM (exemple : 8)
    .PARAMETER IsoPath
        Specify the path of the ISO that will be used to install the OS (exemple : "D:\ISO\MyISO.iso")
    .PARAMETER InternalvSwitchName
        Specify the name and internal vSwitch to connect to the VM (exemple : "My Internal vSwitch")
    .PARAMETER PrivatevSwitchName
        Specify the name and private vSwitch to connect to the VM (exemple : "My Private vSwitch")
    .PARAMETER ExternalvSwitchName
        Specify the name and external vSwitch to connect to the VM (exemple : "My External vSwitch")
    .EXAMPLE
        .\HYPERV_New-VM -CSVPath -VMName "SRV-TEST" -VHDPath "D:\Hyperv\VHD\test.vhdx" -VHDSize 30GB -VMMemory 2048MB -VMGeneration 2
        This example create a VM with the name "SRV-TEST". The VHD is stored in D:\Hyperv\VHD\test.vhd and has a size of 30GB. The virtual memory is 2GB.
        This is a second generation Hyper-V VM (default value).
    .EXAMPLE
        .\HYPERV_New-VM -CSVPath -VMName "SRV-TEST" -VHDPath "D:\Hyperv\VHD\test.vhdx" -VHDSize 30GB -VMMemory 2048MB -VMGeneration 2 -IsoPath "D:\iso\myiso.iso"
        This example create a VM with the name "SRV-TEST". The VHD is stored in D:\Hyperv\VHD\test.vhd and has a size of 30GB. The virtual memory is 2GB.
        This is a second generation Hyper-V VM (default value) and the ISO myiso.iso is mounted.
    .EXAMPLE
        .\HYPERV_New-VM -CSVPath -VMName "SRV-TEST" -VHDPath "D:\Hyperv\VHD\test.vhdx" -VHDSize 30GB -VMMemory 2048MB -VMGeneration 2 -Processor 2 -ExternalvSwitchName "Ext"
        This example create a VM with the name "SRV-TEST". The VHD is stored in D:\Hyperv\VHD\test.vhd and has a size of 30GB. The virtual memory is 2GB.
        This is a second generation Hyper-V VM (default value). There is 2 processors and the external vSwitch called "ext" is connected to the VM.
    .NOTES
        Script tested on : Windows 10 Pro & Enterprise
        Author : Sylver SCHORGEN
        Blog : http://microsofttouch.fr/default/b/sylver
        Created : 22 dec. 2015
        @sylver_schorgen
#>


Param(
    [Parameter(Mandatory=$true)]
    [string]$VMName,
    [Parameter(Mandatory=$true)]
    [string]$VHDPath,
    [Parameter(Mandatory=$true)]
    [int64]$VHDSize,
    [Parameter(Mandatory=$true)]
    [int64]$VMMemory,
    [Parameter(Mandatory=$true)]
    [ValidateRange(1,2)]
    [int]$VMGeneration = 2,
    [Parameter(Mandatory=$false)]
    [int]$Processor,
    [Parameter(Mandatory=$false)]
    [string]$IsoPath,
    [Parameter(Mandatory=$false)]
    [string]$InternalvSwitchName,
    [Parameter(Mandatory=$false)]
    [string]$PrivatevSwitchName,
    [Parameter(Mandatory=$false)]
    [string]$ExternalvSwitchName
    
)

Write-Host
Write-Host
Write-Host "Setting up initial variables ... " -NoNewLine

Import-Module Hyper-V

#VM & VHD existance verification
$VMExists = Get-VM -Name $VMName -ErrorAction SilentlyContinue
$VHDExists = Get-VHD -Path $VHDPath -ErrorAction SilentlyContinue

Write-Host "Ok !" -ForeGroundColor Green
Write-Host

Write-Host "CONFIGURING VM $VMName"
Write-Host " -- Creating VM $VMName ... " -NoNewLine

#Creating VM
if(($VMExists -eq $null) -and ($VHDExists -eq $null)) {
    New-VM -Name $VMName -NewVHDPath $VHDPath -NewVHDSizeBytes $VHDSize -MemoryStartupBytes $VMMemory -Generation $VMGeneration
    Set-VM -Name $VMName -StaticMemory
    Get-VMNetworkAdapter -VMName $VMName | Remove-VMNetworkAdapter

    Write-Host "Ok !" -ForeGroundColor Green

    #Adding ISO if the parmeter is set
    if(($IsoPath -ne "") -and ($IsoPath -ne " ") -and ($IsoPath -ne $null)) {
        Write-Host " -- Adding the ISO in the virtual DVD ... " -NoNewLine
        Add-VMDvdDrive -VMName $VMName -Path $IsoPath
        Write-Host "Ok !" -ForeGroundColor Green
    }
    #Configuring processors if the parameter is set
    if(($Processor -ne "") -and ($Processor -ne " ") -and ($Processor -ne $null)) {
        Write-Host " -- Setting up processors ... " -NoNewLine
        Set-VM -Name $VMName -ProcessorCount $Processor
        Write-Host "Ok !" -ForeGroundColor Green
    }
    #Adding internal vSwitch if the parameter is set
    if(($InternalvSwitchName -ne "") -and ($InternalvSwitchName -ne " ") -and ($InternalvSwitchName -ne $null)) {
        if((Get-VMSwitch -Name $InternalvSwitchName -ErrorAction SilentlyContinue) -ne $Null) {
            Write-Host " -- Setting up internal vSwitch ... " -NoNewLine
    
            Add-VMNetworkAdapter –VMName $VMName –Name "Internal"
            Connect-VMNetworkAdapter -VMName $VMName -Name "Internal" -SwitchName $InternalvSwitchName

            Write-Host "Ok !" -ForeGroundColor Green
        } else {
            Write-Host "The internal vSwitch does not exist !" -ForegroundColor Yellow
        }
    }
    #Adding private vSwitch if the parameter is set
    if(($PrivatevSwitchName -ne "") -and ($PrivatevSwitchName -ne " ") -and ($PrivatevSwitchName -ne $null)) {
        if((Get-VMSwitch -Name $PrivatevSwitchName -ErrorAction SilentlyContinue) -ne $Null) {
            Write-Host " -- Setting up private vSwitch ... " -NoNewLine
    
            Add-VMNetworkAdapter –VMName $VMName –Name "Private"
            Connect-VMNetworkAdapter -VMName $VMName -Name "Private" -SwitchName $PrivatevSwitchName

            Write-Host "Ok !" -ForeGroundColor Green
        } else {
            Write-Host "The private vSwitch does not exist !" -ForegroundColor Yellow
        }
    }
    #Addings external vSwitch if the parameter is set
    if(($ExternalvSwitchName -ne "") -and ($ExternalvSwitchName -ne " ") -and ($ExternalvSwitchName -ne $null)) {
        if((Get-VMSwitch -Name $ExternalvSwitchName -ErrorAction SilentlyContinue) -ne $Null) {
            Write-Host " -- Setting up external vSwitch ... " -NoNewLine
    
            Add-VMNetworkAdapter –VMName $VMName –Name "Internet"
            Connect-VMNetworkAdapter -VMName $VMName -Name "Internet" -SwitchName $ExternalvSwitchName

            Write-Host "Ok !" -ForeGroundColor Green
        } else {
            Write-Host "The external vSwitch does not exist !" -ForegroundColor Yellow
        }
    }

    Write-Host

} else {
    Write-Host "The VM or the VHD already exist !" -ForeGroundColor Yellow
    Write-Host
}