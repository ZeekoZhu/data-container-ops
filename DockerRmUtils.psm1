Import-Module "$PSScriptRoot/Utils.psm1"

function Show-ContainerList {
    param(
        # List
        [Parameter(Mandatory = $true)]
        [array]
        $List
    )
    foreach ($container in $List) {
        Write-ColorOutput $List.IndexOf($container) cyan -NoNewLine
        Write-ColorOutput " $($container.Names) " yellow -NoNewLine
        $statusColor = if ($container.Status.StartsWith('Exited')) {'red'} else {'greed'}
        Write-ColorOutput $container.Status $statusColor
        Write-ColorOutput "    Created: " gray -NoNewLine
        Write-ColorOutput $($container.Created) white
        Write-ColorOutput "    Ports: " gray -NoNewLine
        Write-ColorOutput $($container.Ports) white
        Write-ColorOutput "    ContainerId: " gray -NoNewLine
        Write-ColorOutput $($container.ContainerId) white
        Write-ColorOutput "    Image: " gray -NoNewLine
        Write-ColorOutput $($container.Image) white
        Write-Output ""
    }
}

function Remove-DockerContainer {
    param(
        # interactive
        [Parameter(Mandatory = $false)]
        [switch]
        $Interactive
    )
    $ErrorActionPreference = 'stop'
    if ($Interactive) {
        $containers = ConvertFrom-Docker $(docker ps -a)
        Show-ContainerList $containers
        $inputs = Read-Host -Prompt "Containers to remove (eg: 1 2 3)"
        $targets = $inputs -split ' ' `
            | ForEach-Object { $containers[$_] }
        Write-Output $targets
        Write-Output "These containers will be removed:"
        Show-ContainerList $targets
        $confrim = Read-Host -Prompt "Confrim? Press: y(yes)/f(force)/n(no)"
        $yes = $false
        $force = ''
        if ($confrim -eq 'y') {
            $yes = $true
        }
        if ($confrim -eq 'f') {
            $yes = $true
            $force = '-f'
        }
        if ($yes) {
            foreach ($con in $targets) {
                Invoke-Cmd "'docker' 'rm' '$force' '$($con.Name)'"
            }
        }
    }
}
