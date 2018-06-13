function Remove-DockerContainer {
    param(
        # interactive
        [Parameter(Mandatory = $false)]
        [switch]
        $Interactive
    )

    if ($Interactive) {
        ConvertFrom-Docker $(docker ps -a)
    }
}
