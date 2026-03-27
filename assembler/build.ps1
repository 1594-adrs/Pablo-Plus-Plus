param(
    [string]$OutDir = "build",
    [string]$ExeName = "pablocc.exe"
)

$ErrorActionPreference = "Stop"

function Find-Executable {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Name,

        [string[]]$FallbackGlobs = @()
    )

    $command = Get-Command $Name -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($command) {
        return $command.Source
    }

    foreach ($glob in $FallbackGlobs) {
        $candidate = Get-ChildItem -Path $glob -ErrorAction SilentlyContinue | Select-Object -First 1
        if ($candidate) {
            return $candidate.FullName
        }
    }

    return $null
}

$repoRoot = Resolve-Path (Join-Path $PSScriptRoot "..")
$includeDir = Join-Path $repoRoot "include"
$buildDir = Join-Path $repoRoot $OutDir

$asmFiles = @(
    "common.asm",
    "pablocc.asm",
    "pipeline.asm",
    "lexer.asm",
    "parser.asm",
    "ast.asm",
    "semantic.asm",
    "codegen.asm",
    "toolchain.asm"
)

$nasmPath = Find-Executable -Name "nasm" -FallbackGlobs @(
    (Join-Path $env:LOCALAPPDATA "Microsoft\WinGet\Packages\*\mingw64\bin\nasm.exe"),
    "C:\Program Files\NASM\nasm.exe"
)
if (-not $nasmPath) {
    throw "No se encontro 'nasm' en PATH. Revisa docs/toolchain-windows.md para instalarlo."
}

$gccPath = Find-Executable -Name "gcc" -FallbackGlobs @(
    (Join-Path $env:LOCALAPPDATA "Microsoft\WinGet\Packages\*\mingw64\bin\gcc.exe")
)
if (-not $gccPath) {
    throw "No se encontro 'gcc' en PATH. Revisa docs/toolchain-windows.md para instalar MinGW-w64 o MSYS2."
}

New-Item -ItemType Directory -Force -Path $buildDir | Out-Null

$objectFiles = New-Object System.Collections.Generic.List[string]

foreach ($file in $asmFiles) {
    $sourcePath = Join-Path $PSScriptRoot $file
    $objectPath = Join-Path $buildDir (($file -replace "\.asm$", ".obj"))

    & $nasmPath -f win64 -i "$includeDir\" -o $objectPath $sourcePath
    if ($LASTEXITCODE -ne 0) {
        throw "NASM fallo al ensamblar $file."
    }

    [void]$objectFiles.Add($objectPath)
}

$exePath = Join-Path $buildDir $ExeName
& $gccPath @($objectFiles.ToArray()) "-o" $exePath
if ($LASTEXITCODE -ne 0) {
    throw "gcc fallo durante el link final."
}

$toolchainWrapper = Join-Path $repoRoot "program-build.ps1"
if (Test-Path -LiteralPath $toolchainWrapper) {
    Copy-Item -LiteralPath $toolchainWrapper -Destination (Join-Path $buildDir "program-build.ps1") -Force
}

Write-Host "NASM: $nasmPath"
Write-Host "GCC:  $gccPath"
Write-Host "Compilador generado en: $exePath"
