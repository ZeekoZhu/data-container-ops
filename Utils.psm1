function Invoke-Cmd {
    param(
        # Command
        [Parameter(Mandatory = $true)]
        [string]
        $Command
    )
    $ErrorActionPreference = 'stop'
    $result = Invoke-Expression "& $Command"
    if ($LASTEXITCODE -ne 0) {
        Write-Error -Message ($result -join "`n")
    }
    return $result
}
