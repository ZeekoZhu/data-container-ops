Import-Module "$PSScriptRoot/Utils.psm1"
function Backup-DataContainer ($Config) {
    $backupContainer = "$($Config.container)-data"
    $volumeArgs = -join ($Config.volumes | ForEach-Object { "'-v' '/backup/$($_):$_' " })
    $cpCmds = -join ($Config.volumes | ForEach-Object { "'cp' '-Rf' '/backup/$_ $_'" })
    # backup data container's volumes
    Invoke-Cmd "'docker' 'run' '--volumes-from' '$($Config.container)' '--name' '$backupContainer' $volumeArgs 'alpine' $cpCmds"

    # commit backup to registry
    $remote = "$($Config.registry)$backupContainer"
    Invoke-Cmd "'docker' 'commit' '$backupContainer' '$remote'"

    Invoke-Cmd "'docker' 'push' '$registry'"
}

function Restore-DataContainer ($Config) {
    $backupContainer = "$($Config.container)-data"
    $remote = "$($Config.registry)$backupContainer"
    $volumeArgs = -join ($Config.volumes | ForEach-Object { "-v /backup/$($_):$_ " })
    Invoke-Cmd "'docker' 'run' $volumeArgs '--entrypoint' 'bin/sh' '--name' '$backupContainer' '$remote'"
}

function Backup-FromConfig {
    param(
        # ConfigFile
        [Parameter(Mandatory = $true)]
        [string]
        $ConfigFile
    )
    $ErrorActionPreference = 'stop'
    $configs = Get-Content $ConfigFile -Raw | ConvertFrom-Json

    foreach ($cfg in $configs) {
        Backup-DataContainer($cfg)
    }
}

function Restore-FromConfig {
    param(
        # ConfigFile
        [Parameter(Mandatory = $true)]
        [string]
        $ConfigFile
    )
    $ErrorActionPreference = 'stop'
    $configs = Get-Content $ConfigFile -Raw | ConvertFrom-Json

    foreach ($cfg in $configs) {
        Restore-DataContainer($cfg)
    }
}

function Get-DataContainerConfig {
    param(
        # ConfigFile
        [Parameter(Mandatory = $true)]
        [string]
        $ConfigFile
    )
    $ErrorActionPreference = 'stop'
    $configs = Get-Content $ConfigFile -Raw | ConvertFrom-Json
    foreach ($cfg in $configs) {
        Write-Output "$($cfg.container) >> $($cfg.registry)$($cfg.container)-data"
        foreach ($path in $cfg.volumes) {
            Write-Output "    $path"
        }
        Write-Output ""
    }
}

function Convert-VolumesJson {
    param(
        # JsonOutput
        [Parameter(Mandatory = $true)]
        [string]
        $JsonOutput
    )
    [string[]]$result = $JsonOutput | ConvertFrom-Json | Get-Member `
        | Where-Object { $_.MemberType -eq "NoteProperty"} `
        | ForEach-Object { $_.Name}
    if ($result -isnot [array]) {
        $result = @($result)
    }
    return $result
}

function New-BackupConfig {
    param(
        # ConfigFile
        [Parameter(Mandatory = $true)]
        [string]
        $ConfigFile,
        # Registry
        [Parameter(Mandatory = $true)]
        [string]
        $Registry
    )
    if (-not $Registry.EndsWith('/')) {
        $Registry += '/'
    }

    [array]$config = Invoke-Cmd "'docker' 'ps' '-a' '--format={{json .Names}}'" `
        | ForEach-Object { $_.Trim("`"") } `
        | ForEach-Object {
        $volumesJson = Invoke-Cmd "'docker' 'inspect' '$_' '--format={{json .Config.Volumes}}'"
        if ($volumesJson -eq 'null') {
            return $null
        }
        [string[]]$volumes = Convert-VolumesJson $volumesJson

        $res = @{
            registry  = $Registry;
            container = $_;
            volumes   = $volumes;
        }
        return $res
    } `
        | Where-Object {$_ -ne $null}
    ConvertTo-Json -InputObject $config | Out-File -FilePath $ConfigFile -Encoding utf8 -Force
}



Export-ModuleMember -Function Backup-FromConfig
Export-ModuleMember -Function Restore-FromConfig
Export-ModuleMember -Function Get-DataContainerConfig
Export-ModuleMember -Function New-BackupConfig
