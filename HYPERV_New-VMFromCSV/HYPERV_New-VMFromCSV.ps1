<#
    .SYNOPSIS
        Create Hyper-V VM
    .DESCRIPTION
        Create Hyper-V VM with internal and external vSwitch
    .PARAMETER CSVPath
        Path of the CSV file containing all the VM to create
    .EXAMPLE
        .\HYPERV_New-VMFromCSV -CSVPath "C:\_\VmToCreate.csv"
    .NOTES
        Script tested on : Windows 10 Pro & Enterprise
        Author : Sylver SCHORGEN
        Blog : http://microsofttouch.fr/default/b/sylver
        Created : 22 dec. 2015
        @sylver_schorgen
#>

Param(
    [Parameter(Mandatory=$false)]
    [string]$CSVPath
)

#region Variable initialization

Write-Host
Write-Host
Write-Host "Setting up initial variables ... " -NoNewLine

$csvFile = Import-Csv -Path $CSVPath

Write-Host "Ok !" -ForeGroundColor Green
Write-Host

#endregion

#region Modules import

Import-Module Hyper-V

#endregion

#region VM creation

foreach($VM in $csvFile) {
    Write-Host "VM $($VM.VMName) CONFIGURATION"
    Write-Host " -- Creating Virtual Machine $($VM.VMName) ... " -NoNewLine
    
    #VM existance verification
    $VMExists = Get-VM -Name $VM.VMName -ErrorAction SilentlyContinue

    if($VMExists -eq $Null) {
        try {
            $VMMemory = "$($VM.VMMemoryMB)" + "MB"
            $VMMemory = $(Invoke-Expression -Command $VMMemory)
            
            #Size modification to be able to create the VMs
            $VHDSize = "$($VM.VHDSizeGB)" + "GB"
            $VHDSize = $(Invoke-Expression -Command $VHDSize)

            #VHD existance verification
            $VHDExists = Get-VHD -Path $VM.VHDPath -ErrorAction SilentlyContinue

            if($VHDExists -eq $Null) {
                
                #VM creation
                New-VM -Name $VM.VMName -MemoryStartupBytes $VMMemory -NewVHDPath $VM.VHDPath -NewVHDSizeBytes $VHDSize -Generation $VM.VMGeneration
                Set-VM -Name $VM.VMName -StaticMemory -ProcessorCount $VM.Processors
                
                if(($VM.ISOPath -ne $null) -and ($VM.ISOPath -ne "") -and ($VM.ISOPath -ne "")) {
                    Add-VMDvdDrive -VMName $VM.VMName -Path $VM.IsoPath
                }
                
                Write-Host "Ok !" -ForeGroundColor Green
           
                #Removal of the default network adapater                
                Get-VMNetworkAdapter -VMName $VM.VMName | Remove-VMNetworkAdapter

                #Adding external vSwitch if it exists
                if(($VM.ExternalvSwitchName -ne "") -and ($VM.ExternalvSwitchName -ne $null) -and ($VM.ExternalvSwitchName -ne " ")) {
                    Write-Host " -- Configuring Virtual Machine $($VM.VMName) external vSwitch ... " -NoNewLine
                    
                    if((Get-VMSwitch -Name $VM.ExternalvSwitchName -ErrorAction SilentlyContinue) -ne $Null) {
                        Add-VMNetworkAdapter –VMName $VM.VMName –Name "Internet"
                        Connect-VMNetworkAdapter -VMName $VM.VMName -Name "Internet" -SwitchName $VM.ExternalvSwitchName
                        
                        Write-Host "Ok !" -ForeGroundColor Green
                    } else {
                        Write-Host "The external vSwitch $($VM.ExternalvSwitchName) does not exist !" -ForegroundColor Yellow
                    }
                }
                
                #Adding internal vSwitch if it exists
                if(($VM.InternalvSwitchName -ne "") -and ($VM.InternalvSwitchName -ne $null) -and ($VM.InternalvSwitchName -ne " ")) {
                    Write-Host " -- Configuring Virtual Machine $($VM.VMName) internal vSwitch ... " -NoNewLine

                    if((Get-VMSwitch -Name $VM.InternalvSwitchName -ErrorAction SilentlyContinue) -ne $Null) {
                        Add-VMNetworkAdapter –VMName $VM.VMName –Name "Internal"
                        Connect-VMNetworkAdapter -VMName $VM.VMName -Name "Internal" -SwitchName $VM.InternalvSwitchName

                        Write-Host "Ok !" -ForegroundColor Green
                    } else {
                        Write-Host "The internal vSwitch $($VM.InternalvSwitchName) does not exist !" -ForegroundColor Yellow
                    }                                       
                }

                #Adding private vSwitch if it exists
                if(($VM.PrivatevSwitchName -ne "") -and ($VM.PrivatevSwitchName -ne $null) -and ($VM.PrivatevSwitchName -ne " ")) {
                    Write-Host " -- Configuring Virtual Machine $($VM.VMName) private vSwitch ... " -NoNewLine
                    
                    if((Get-VMSwitch -Name $VM.PrivatevSwitchName -ErrorAction SilentlyContinue) -ne $Null) {
                        Add-VMNetworkAdapter –VMName $VM.VMName –Name "Private"
                        Connect-VMNetworkAdapter -VMName $VM.VMName -Name "Private" -SwitchName $VM.PrivatevSwitchName

                        Write-Host "Ok !" -ForegroundColor Green
                    } else {
                        Write-Host "The private vSwitch $($VM.PrivatevSwitchName) does not exist !" -ForegroundColor Yellow
                    } 
                }

                Write-Host

            } else {
                Write-Host "VM does not exist but the VHD does ! Remove or rename the existing VHD first !" -ForeGroundColor Yellow
                Write-Host
            }

            

        } catch {
            Write-Host "An error occured ! Verify that the VM Name, VHD Path, VHD Size, VM Memory and VM Genaration parameters are correctly set !" -ForeGroundColor Red
            Write-Host
        }
    } else {
        Write-Host "Already exists !" -ForeGroundColor Yellow
        Write-Host
    }
}

#endregion