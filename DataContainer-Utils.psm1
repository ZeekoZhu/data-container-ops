$ErrorActionPreference = 'stop'
Import-Module "$PSScriptRoot/Utils.psm1"
function Backup-DataContainer ($Config) {
    $ErrorActionPreference = 'stop'
    $backupImage = "$($Config.remoteName)-data"
    # $volumeArgs = ($Config.volumes | ForEach-Object { "'-v' '$_'" }) -join " "
    $cpCmds = ($Config.volumes | ForEach-Object { "mkdir -p /backup$_ && cp -vRf $_ /backup$_" }) -join " && "
    Write-Output "Backup local container $($Config.container)'s volumes to ops-backup-$backupImage"
    Write-Output "Invoking: 'docker' 'run' '--volumes-from' '$($Config.container):ro' '--name' 'ops-backup-$backupImage' 'alpine' 'sh' -c '$cpCmds'"
    # backup data container's volumes
    Invoke-Cmd "'docker' 'run' '--volumes-from' '$($Config.container):ro' '--name' 'ops-backup-$backupImage' 'alpine' 'sh' -c '$cpCmds'"

    # commit backup to registry
    $remote = "$($Config.registry)$backupImage"
    $date = Get-Date -Format "yyyy-MM-dd-HH-mm-ss"
    Invoke-Cmd "'docker' 'commit' 'ops-backup-$backupImage' '$($remote):$date'"
    Invoke-Cmd "docker tag '$($remote):$date' '$($remote):latest'"
    Write-Output "Pushing: '$($remote):$date'"
    Invoke-Cmd "'docker' 'push' '$($remote):$date'"
    Invoke-Cmd "'docker' 'push' '$($remote):latest'"
    Invoke-Cmd "docker rm -f 'ops-backup-$backupImage'"
}

function Restore-DataContainer ($Config) {
    $backupImage = "$($Config.remoteName)-data"
    $remote = "$($Config.registry)$backupImage"
    $volumeArgs = ($Config.volumes | ForEach-Object { "-v $_" }) -join " "
    $cpCmds = ($Config.volumes | ForEach-Object { "mkdir -p /backup/$_ && mv -v /backup$_ $_" }) -join " && "
    Write-Output "Restore $remote to local container $backupContainer"
    Write-Output "Invoking: 'docker' 'run' $volumeArgs'--name' '$backupContainer' '$remote' 'sh' -c '$cpCmds'"
    Invoke-Cmd "'docker' 'run' $volumeArgs '--name' '$backupContainer' '$remote' 'sh' -c '$cpCmds'"
}

function Backup-FromConfig {
    param(
        # ConfigFile
        [Parameter(Mandatory = $true)]
        [ValidateScript( {Test-Path $_} )]
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
        [ValidateScript( {Test-Path $_} )]
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
        [ValidateScript( {Test-Path $_} )]
        [string]
        $ConfigFile
    )
    $ErrorActionPreference = 'stop'
    $configs = Get-Content $ConfigFile -Raw | ConvertFrom-Json
    foreach ($cfg in $configs) {
        Write-Output "$($cfg.container) >> $($cfg.registry)$($cfg.remoteName)-data"
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
            registry   = $Registry;
            container  = $_;
            volumes    = $volumes;
            remoteName = $_.ToLower();
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
