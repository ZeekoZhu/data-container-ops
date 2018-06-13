@{
    # If authoring a script module, the RootModule is the name of your .psm1 file
    RootModule           = 'DataContainer-Utils.psm1'

    Author               = 'Zeeko Zhu <vaezt@outlook.com>'

    CompanyName          = 'Unknown'

    ModuleVersion        = '0.2.13'

    # Use the New-Guid command to generate a GUID, and copy/paste into the next line
    GUID                 = '4e2868ab-e830-4b97-99df-8c77f3f4a137'

    Copyright            = '(c) 2018 Zeeko. All rights reserved.'

    Description          = 'Some utils for docker operations'

    # Minimum PowerShell version supported by this module (optional, recommended)
    PowerShellVersion    = '5.1'

    # Which PowerShell Editions does this module work with? (Core, Desktop)
    CompatiblePSEditions = @('Desktop', 'Core')

    # Which PowerShell functions are exported from your module? (eg. Get-CoolObject)
    FunctionsToExport    = @('Restore-FromConfig', 'Backup-FromConfig', 'Get-DataContainerConfig', 'New-BackupConfig')

    # Which PowerShell aliases are exported from your module? (eg. gco)
    AliasesToExport      = @('')

    # Which PowerShell variables are exported from your module? (eg. Fruits, Vegetables)
    VariablesToExport    = @('')

    # PowerShell Gallery: Define your module's metadata
    PrivateData          = @{
        PSData = @{
            # What keywords represent your PowerShell module? (eg. cloud, tools, framework, vendor)
            Tags         = @('docker', 'docker-volumes', 'backup', 'utils')

            # What software license is your code being released under? (see https://opensource.org/licenses)
            LicenseUri   = ''

            # What is the URL to your project's website?
            ProjectUri   = 'https://github.com/ZeekoZhu/data-container-ops'

            # What is the URI to a custom icon file for your project? (optional)
            IconUri      = ''

            # What new features, bug fixes, or deprecated features, are part of this release?
            ReleaseNotes = @'
'@
        }
    }

    # If your module supports updateable help, what is the URI to the help archive? (optional)
    # HelpInfoURI = ''
}
