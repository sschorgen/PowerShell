<#

    .SYNOPSIS
        DSC Script used to configure a computer Name and network configuration
    .DESCRIPTION
        DSC Script used to configure a computer Name and network configuration
    .PARAMETER ComputerName
        The new name you want to configure for your computer
        This is a mandatory parameter
    .PARAMETER MofFilePath
        The folder path of you MOF File directory
        This is a mandatory parameter
    .EXAMPLE
        ConfigureComputer -ComputerName "SRV-16-DEMO" -MofFilePath "C:\_DSC" -ConfigurationData $MyData -OutputPath "C:\_DSC"
        Start-DscConfiguration -Wait -Force -Verbose -Path "C:\_DSC\ConfigureComputer"

    .NOTES
        Author : Sylver SCHORGEN
        Blog : http://microsofttouch.fr/default/b/sylver
        Created : 15 dec. 2016
        Twitter : @sylver_schorgen

#>

Configuration ConfigureComputer
{
    param
    (
        [Parameter(Mandatory=$True)][string]$ComputerName,
        [Parameter(Mandatory=$True)][string]$MofFilePath
    )

    # DSC Resources import

    Import-DscResource -Module xNetworking
    Import-DscResource -module xComputerManagement
 
    Node $AllNodes.Nodename
    {
        
        LocalConfigurationManager            
        {            
            ActionAfterReboot = 'ContinueConfiguration'
            ConfigurationMode = 'ApplyOnly'
            RebootNodeIfNeeded = $true
        }
        
        File DSCFolder
        {
            Type = 'Directory'
            DestinationPath = $MofFilePath
            Ensure = "Present"
        }

        xComputer NewNameAndWorkgroup
        {
            Name           = $ComputerName
        }

        xIPAddress IPAddress
        {
            IPAddress      = $Node.IpAddress
            InterfaceAlias = $Node.Interface
            PrefixLength   = $Node.IPPrefix
            AddressFamily  = $Node.IPAddressFamily
        }
        
        xDnsServerAddress DnsServer
        {
            InterfaceAlias = $Node.Interface
            AddressFamily  = $Node.IPAddressFamily
            Address        = $Node.DnsServers
        }
        
        xDefaultGatewayAddress DefaultGtw
        {
            InterfaceAlias = $Node.Interface
            AddressFamily  = $Node.IPAddressFamily
            Address        = $Node.Gateway
        }
    }
}

$MyData = 
@{
    AllNodes = @(
        @{
            NodeName        = 'localhost'
            IpAddress       = '192.168.200.10'
            Interface       = 'Ethernet'
            IPPrefix        = 24
            IPAddressFamily = 'IPV4'
            DnsServers      = '8.8.8.8','8.8.4.4'
            Gateway         = '192.168.200.254'
        }
    )  
}


<# EXECUTION EXAMPLE

    ConfigureComputer -ComputerName "SRV-16-DEMO" -MofFilePath "C:\_DSC" -ConfigurationData $MyData -OutputPath "C:\_DSC"
    Start-DscConfiguration -Wait -Force -Verbose -Path "C:\_DSC\ConfigureComputer"

#>