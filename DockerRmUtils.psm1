function Show-ContainerList {
    param(
        # List
        [Parameter(Mandatory = $true)]
        [array]
        $List
    )
    
}

function Remove-DockerContainer {
    param(
        # interactive
        [Parameter(Mandatory = $false)]
        [switch]
        $Interactive
    )

    if ($Interactive) {
        $containers = ConvertFrom-Docker $(docker ps -a)
    }
}
