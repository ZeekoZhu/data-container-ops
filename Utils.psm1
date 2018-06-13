function Invoke-Cmd {
    param(
        # Command
        [Parameter(Mandatory = $true)]
        [string]
        $Command
    )
    $result = Invoke-Expression "& $Command"
    if ($LASTEXITCODE -ne 0) {
        Write-Error -Message $result
    }
    return $result
}
