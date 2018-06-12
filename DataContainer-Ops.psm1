function Backup-DataContainer ($Config) {
    $backupContainer = "${Config.container}-data"
    $volumeArgs = -join ($Config.volumes | ForEach-Object { "-v /backup/${_}:${_} " })
    $cpCmds = -join ($Config.volumes | ForEach-Object { "cp -Rf /backup/${_} ${_}" })
    # backup data container's volumes
    docker "run --volumes-from ${Config.container} --name $backupContainer $volumeArgs alpine $cpCmds"
    if ($LASTEXITCODE -ne 0) {
        exit $LASTEXITCODE
    }

    # commit backup to registry
    $remote = "${Config.registry}$backupContainer"
    docker commit $backupContainer $remote
    if ($LASTEXITCODE -ne 0) {
        exit $LASTEXITCODE
    }

    docker push $registry
    if ($LASTEXITCODE -ne 0) {
        exit $LASTEXITCODE
    }
}

function Restore-DataContainer ($Config) {
    $backupContainer = "${Config.container}-data"
    $remote = "${Config.registry}$backupContainer"
    $volumeArgs = -join ($Config.volumes | ForEach-Object { "-v /backup/${_}:${_} " })
    docker "run $volumeArgs --entrypoint "bin/sh" --name $backupContainer $remote"
    if ($LASTEXITCODE -ne 0) {
        exit $LASTEXITCODE
    }
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
    foreach ($cfg in $configs) {
        Write-Output "${cfg.container} >> ${cfg.registry}${cfg.container}-data"
        foreach ($path in $cfg.volumes) {
            Write-Output "    $path"
        }
        Write-Output ""
    }
}



Export-ModuleMember -Function Backup-FromConfig
Export-ModuleMember -Function Restore-FromConfig
Export-ModuleMember -Function Get-DataContainerConfig
