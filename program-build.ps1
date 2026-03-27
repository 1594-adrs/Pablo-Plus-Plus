param(
    [Parameter(Mandatory = $true)]
    [string]$AsmPath,
    [Parameter(Mandatory = $true)]
    [string]$RuntimePath,
    [Parameter(Mandatory = $true)]
    [string]$ExePath
)

$ErrorActionPreference = "Stop"

$candidateInPlace = Join-Path $PSScriptRoot "assembler\program-build.ps1"
$candidateInParent = Join-Path $PSScriptRoot "..\assembler\program-build.ps1"

if (Test-Path -LiteralPath $candidateInPlace) {
    $realScript = (Resolve-Path -LiteralPath $candidateInPlace).Path
} elseif (Test-Path -LiteralPath $candidateInParent) {
    $realScript = (Resolve-Path -LiteralPath $candidateInParent).Path
} else {
    throw "No se encontro assembler/program-build.ps1 desde $PSScriptRoot."
}

& $realScript -AsmPath $AsmPath -RuntimePath $RuntimePath -ExePath $ExePath
exit $LASTEXITCODE
