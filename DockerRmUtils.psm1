Import-Module "$PSScriptRoot/Utils.psm1"

function Show-ContainerList {
    param(
        # List
        [Parameter(Mandatory = $true)]
        [array]
        $List
    )
    $fieldFormat = "{0,13}"
    $valueFormat = "{0,-25}"
    foreach ($container in $List) {
        Write-ColorOutput $List.IndexOf($container) cyan -NoNewLine
        Write-ColorOutput " $($container.Names) " yellow -NoNewLine
        $statusColor = if ($container.Status.StartsWith('Exited')) {'red'} else {'green'}
        Write-ColorOutput $container.Status $statusColor
        Write-ColorOutput ($fieldFormat -f "Created: ") gray -NoNewLine
        Write-ColorOutput ($valueFormat -f $container.Created) white -NoNewLine
        Write-ColorOutput ($fieldFormat -f "Ports: ") gray -NoNewLine
        Write-ColorOutput ($valueFormat -f $container.Ports) white
        Write-ColorOutput ($fieldFormat -f "ContainerId: ") gray -NoNewLine
        Write-ColorOutput ($valueFormat -f $container.ContainerId) white -NoNewLine
        Write-ColorOutput ($fieldFormat -f "Image: ") gray -NoNewLine
        Write-ColorOutput ($valueFormat -f $container.Image) white
        Write-Output ""
    }
}

function Show-ImagesList {
    param(
        # List
        [Parameter(Mandatory = $true)]
        [array]
        $List
    )
    $fieldFormat = "{0,9}"
    $valueFormat = "{0,-25}"
    foreach ($image in $List) {
        Write-ColorOutput $List.IndexOf($image) cyan -NoNewLine
        $noTag = if ($image.Tag -eq '<none>') {'red'} else {'green'}
        Write-ColorOutput " $($image.Repository):$($image.Tag) " $noTag

        Write-ColorOutput ($fieldFormat -f "Size: ") gray -NoNewLine
        Write-ColorOutput ($valueFormat -f $image.Size) white -NoNewLine

        Write-ColorOutput ($fieldFormat -f "Created: ") gray -NoNewLine
        Write-ColorOutput ($valueFormat -f $image.Created) white -NoNewLine

        Write-ColorOutput ($fieldFormat -f "ImageId: ") gray -NoNewLine
        Write-ColorOutput ($valueFormat -f $image.ImageId) white
        Write-Output ""
    }
}

function Get-ImagesRelatedContainerIds {
    param(
        # ImageIds
        [Parameter(Mandatory = $true)]
        [string[]]
        $ImageIds,
        # Containers
        [Parameter(Mandatory = $true)]
        [array]
        $Containers
    )
    if ($Containers -eq $null -or $ImageIds -eq $null) {
        return $null
    }
    $containerArg = ($Containers | ForEach-Object {"'$($_.ContainerId)'"}) -join " "
    [array]$inspection = Invoke-Cmd "'docker' 'inspect' $containerArg" | ConvertFrom-Json
    $related = $inspection | Where-Object {
        $imageId = $_.Image.Substring(7, 12)
        return $ImageIds -contains $imageId
    } `
        | ForEach-Object {
        $id = $_.Id.Substring(0, 12)
        return $Containers | Where-Object {$_.Id -eq $id} | Select-Object -First
    }
    return $related
}

function Remove-ContainersInteractively {
    param(
        # Targets
        [Parameter(Mandatory = $true)]
        [array]
        $Targets
    )
    Write-Output "These containers will be removed:"
    Show-ContainerList $Targets
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
        foreach ($con in $Targets) {
            Invoke-Cmd "'docker' 'rm' '$force' '$($con.Names)'"
        }
    }
}


function Remove-DockerImages {
    param(
        # Filter
        [Parameter(Mandatory = $false)]
        [scriptblock]
        $Filter,
        # Force
        [Parameter(Mandatory = $false)]
        [switch]
        $Force,
        # Clear
        [Parameter(Mandatory = $false)]
        [switch]
        $Clear,
        # interactive
        [Parameter(Mandatory = $false)]
        [switch]
        $Interactive,
        # Cascade
        [Parameter(Mandatory = $false)]
        [switch]
        $Cascade
    )
    $ErrorActionPreference = 'stop'
    $images = ConvertFrom-Docker $(Invoke-Cmd "'docker' 'images'")
    if ($images -eq $null) {
        return
    }
    if ($Cascade) {
        Write-Warning "Cascade removal is enabled, when you try to remove a image, all containers that use it will be removed."
    }
    if ($Interactive) {
        Show-ImagesList $images
        $inputs = Read-Host -Prompt "Images to remove (eg: 1 2 3)"
        $targets = $inputs -split ' ' `
            | ForEach-Object { $images[$_] }
        Write-Output "These images will be removed:"
        Show-ImagesList $targets
        $confrim = Read-Host -Prompt "Confrim? Press: y(yes)/f(force)/n(no)"
        $yes = $false
        $forceArg = ''
        if ($confrim -eq 'y') {
            $yes = $true
        }
        if ($confrim -eq 'f') {
            $yes = $true
            $forceArg = '-f'
        }
        if ($yes) {
            $containers = ConvertFrom-Docker $(docker ps -a)
            foreach ($img in $targets) {
                if ($Cascade) {
                    if ($containers -ne $null) {
                        $relatedContainers = Get-ImagesRelatedContainers @($img.ImageId) $containers
                        Remove-ContainersInteractively $relatedContainers
                    }
                }
                Invoke-Cmd "'docker' 'rmi' '$forceArg' '$($img.ImageId)'"
            }
        }
    }
    else {
        $targets = $images | Where-Object $Filter
        $forceArg = if ($Force) {"-f"}else {""}
        foreach ($img in $targets) {
            Invoke-Cmd "'docker' 'rmi' '$forceArg' '$($img.ImageId)'"
        }
    }
}

<#
.SYNOPSIS
    Remove specific containers
.DESCRIPTION
    Long description
.EXAMPLE
    PS C:\> Remove-DockerContainer -Interactive
    Remove containers interactively
    PS C:\> Remove-DockerContainer -Filter { $_.Names -eq '<none>' }
    Remove containers by filter
.INPUTS
    Inputs (if any)
.OUTPUTS
    Output (if any)
.NOTES
    General notes
#>
function Remove-DockerContainer {
    param(
        # Filter
        [Parameter(Mandatory = $false)]
        [scriptblock]
        $Filter,
        # Force
        [Alias('f')]
        [Parameter(Mandatory = $false)]
        [switch]
        $Force,
        [Alias('i')]
        # interactive
        [Parameter(Mandatory = $false)]
        [switch]
        $Interactive
    )
    $ErrorActionPreference = 'stop'
    $containers = ConvertFrom-Docker $(docker ps -a)
    if ($containers -eq $null) {
        return
    }
    if ($Interactive) {
        Show-ContainerList $containers
        $inputs = Read-Host -Prompt "Containers to remove (eg: 1 2 3)"
        $targets = $inputs -split ' ' `
            | ForEach-Object { $containers[$_] }
        Remove-ContainersInteractively $targets
    }
    else {
        $targets = $containers | Where-Object $Filter
        $forceArg = if ($Force) {"-f"}else {""}
        foreach ($con in $targets) {
            Invoke-Cmd "'docker' 'rm' '$forceArg' '$($con.Names)'"
        }
    }
}

function Show-AllContainers {
    $res = ConvertFrom-Docker $(docker ps -a)
    if ($res -ne $null) {
        Show-ContainerList $res
    }
}
function Show-Containers {
    $res = ConvertFrom-Docker $(docker ps)
    if ($res -ne $null) {
        Show-ContainerList $res
    }
}
function Show-AllImages {
    $res = ConvertFrom-Docker $(docker images)
    if ($res -ne $null) {
        Show-ImagesList $res
    }
}
New-Alias dockerps Show-Containers
New-Alias dockerpsa Show-AllContainers
New-Alias dockeri Show-AllImages
