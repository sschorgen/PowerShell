<#

    .SYNOPSIS
        DSC Script used to configure LCM (Local Configuration Manager) on a computer
    .DESCRIPTION
        DSC Script used to configure LCM (Local Configuration Manager) on a computer
    .PARAMETER MofFilePath
        The folder path of you MOF File directory
        This is a mandatory parameter
    .EXAMPLE
        ConfigureLCM -MofFilePath "C:\_DSC" -OutputPath "C:\_DSC"
        Set-DscLocalConfigurationManager -Force -Verbose -Path "C:\_DSC\ConfigureLCM"

    .NOTES
        Author : Sylver SCHORGEN
        Blog : http://microsofttouch.fr/default/b/sylver
        Created : 15 dec. 2016
        Twitter : @sylver_schorgen

#>

Configuration ConfigureLCM
{
    Node localhost
    {
        param
        (
            [Parameter(Mandatory=$True)][string]$MofFilePath
        )
        
        File DSCFolder
        {
            Type = 'Directory'
            DestinationPath = $MofFilePath
            Ensure = "Present"
        }
        
        LocalConfigurationManager            
        {            
            ActionAfterReboot = 'ContinueConfiguration'
            ConfigurationMode = 'ApplyOnly'
            RebootNodeIfNeeded = $true
        }

    }
}

<# EXECUTION EXAMPLE

    ConfigureLCM -MofFilePath "C:\_DSC" -OutputPath "C:\_DSC"
    Set-DscLocalConfigurationManager -Force -Verbose -Path "C:\_DSC\ConfigureLCM"

#>