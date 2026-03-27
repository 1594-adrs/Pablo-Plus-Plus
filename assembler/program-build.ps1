param(
    [Parameter(Mandatory = $true)]
    [string]$AsmPath,
    [Parameter(Mandatory = $true)]
    [string]$RuntimePath,
    [Parameter(Mandatory = $true)]
    [string]$ExePath
)

$ErrorActionPreference = "Stop"
$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path

$localAppDataRoot = if ($env:LOCALAPPDATA) {
    $env:LOCALAPPDATA
} elseif ($env:USERPROFILE) {
    Join-Path $env:USERPROFILE "AppData\\Local"
} else {
    "C:\\Users\\andres.rincon2\\AppData\\Local"
}

function Find-Executable {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Name,
        [string[]]$CandidatePaths = @()
    )

    $command = Get-Command $Name -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($command) { return $command.Source }

    foreach ($candidate in $CandidatePaths) {
        if ([System.IO.File]::Exists($candidate)) {
            return $candidate
        }
    }

    return $null
}

function Resolve-CompilerPath {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    $resolved = Resolve-Path -LiteralPath $Path -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($resolved) {
        return $resolved.Path
    }

    $repoCandidate = Join-Path $repoRoot $Path
    $resolved = Resolve-Path -LiteralPath $repoCandidate -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($resolved) {
        return $resolved.Path
    }

    throw "No se encontro la ruta requerida: $Path"
}

$packageRoot = Join-Path $localAppDataRoot "Microsoft\WinGet\Packages"

$nasmPath = Find-Executable -Name "nasm" -CandidatePaths @(
    "C:\Users\andres.rincon2\AppData\Local\Microsoft\WinGet\Packages\BrechtSanders.WinLibs.POSIX.UCRT_Microsoft.Winget.Source_8wekyb3d8bbwe\mingw64\bin\nasm.exe",
    (Join-Path $packageRoot "BrechtSanders.WinLibs.POSIX.UCRT_Microsoft.Winget.Source_8wekyb3d8bbwe\mingw64\bin\nasm.exe"),
    "C:\Users\andres.rincon2\AppData\Local\Microsoft\WinGet\Packages\NASM.NASM_Microsoft.Winget.Source_8wekyb3d8bbwe\nasm.exe",
    "C:\Program Files\NASM\nasm.exe"
)
if (-not $nasmPath) { throw "No se encontro 'nasm'." }

$gccPath = Find-Executable -Name "gcc" -CandidatePaths @(
    "C:\Users\andres.rincon2\AppData\Local\Microsoft\WinGet\Packages\BrechtSanders.WinLibs.POSIX.UCRT_Microsoft.Winget.Source_8wekyb3d8bbwe\mingw64\bin\gcc.exe",
    "C:\Users\andres.rincon2\AppData\Local\Microsoft\WinGet\Packages\BrechtSanders.WinLibs.POSIX.UCRT_Microsoft.Winget.Source_8wekyb3d8bbwe\mingw64\bin\gcc.exe"
)
if (-not $gccPath) { throw "No se encontro 'gcc'." }

$asmResolved = Resolve-CompilerPath $AsmPath
$runtimeResolved = Resolve-CompilerPath $RuntimePath
$exeResolved = [System.IO.Path]::GetFullPath($ExePath)
$objDir = Split-Path -Parent $exeResolved
New-Item -ItemType Directory -Force -Path $objDir | Out-Null

$baseName = [System.IO.Path]::GetFileNameWithoutExtension($exeResolved)
if ([string]::IsNullOrWhiteSpace($baseName)) {
    $baseName = "program"
}

$programObj = Join-Path $objDir ($baseName + ".obj")
$runtimeObj = Join-Path $objDir ($baseName + ".runtime.obj")

& $nasmPath -f win64 -o $programObj $asmResolved
if ($LASTEXITCODE -ne 0) { throw "NASM fallo con el programa generado." }

& $nasmPath -f win64 -o $runtimeObj $runtimeResolved
if ($LASTEXITCODE -ne 0) { throw "NASM fallo con el runtime minimo." }

& $gccPath $programObj $runtimeObj -o $exeResolved
if ($LASTEXITCODE -ne 0) { throw "gcc fallo al linkear el ejecutable .exe." }
