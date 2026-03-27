param()

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

function Invoke-NativeCapture {
    param(
        [Parameter(Mandatory = $true)]
        [string]$FilePath,
        [string[]]$Arguments = @()
    )

    $previousErrorActionPreference = $ErrorActionPreference
    $nativePreference = Get-Variable -Name PSNativeCommandUseErrorActionPreference -ErrorAction SilentlyContinue

    if ($nativePreference) {
        $previousNativePreference = [bool]$nativePreference.Value
        $script:PSNativeCommandUseErrorActionPreference = $false
    }

    $ErrorActionPreference = "Continue"
    try {
        $output = (& $FilePath @Arguments 2>&1 | ForEach-Object { "$_" }) -join [Environment]::NewLine
        $exitCode = if ($null -ne $LASTEXITCODE) { [int]$LASTEXITCODE } else { 0 }
    }
    finally {
        $ErrorActionPreference = $previousErrorActionPreference

        if ($nativePreference) {
            $script:PSNativeCommandUseErrorActionPreference = $previousNativePreference
        }
    }

    return [pscustomobject]@{
        FilePath = $FilePath
        Arguments = $Arguments
        ExitCode = $exitCode
        Output = $output.TrimEnd()
    }
}

function Assert-ExitCode {
    param(
        [Parameter(Mandatory = $true)]
        [pscustomobject]$Result,
        [Parameter(Mandatory = $true)]
        [int]$Expected,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    if ($Result.ExitCode -ne $Expected) {
        throw "$Context fallo. Exit esperado: $Expected. Exit real: $($Result.ExitCode).`nSalida:`n$($Result.Output)"
    }
}

function Assert-NonZeroExit {
    param(
        [Parameter(Mandatory = $true)]
        [pscustomobject]$Result,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    if ($Result.ExitCode -eq 0) {
        throw "$Context debia fallar, pero devolvio 0.`nSalida:`n$($Result.Output)"
    }
}

function Assert-Contains {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Text,
        [Parameter(Mandatory = $true)]
        [string]$Needle,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    if (-not $Text.Contains($Needle)) {
        throw "$Context. No se encontro '$Needle'.`nSalida:`n$Text"
    }
}

function Assert-OutputEquals {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Actual,
        [Parameter(Mandatory = $true)]
        [string]$Expected,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    if ($Actual -ne $Expected) {
        throw "$Context. Salida esperada:`n$Expected`nSalida real:`n$Actual"
    }
}

function Assert-Exists {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    if (-not (Test-Path -LiteralPath $Path)) {
        throw "$Context. No existe: $Path"
    }
}

function Write-Step {
    param([string]$Message)
    Write-Host ""
    Write-Host "== $Message =="
}

$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$buildDir = Join-Path $repoRoot "build"
$verifyDir = Join-Path $buildDir "verify"
$pabloccExe = Join-Path $buildDir "pablocc.exe"
$programExe = Join-Path $buildDir "program.exe"
$nestedProgramExe = Join-Path $buildDir "build\program.exe"
$customExe = Join-Path $buildDir "custom.exe"
$spacedExe = Join-Path $buildDir "salida personalizada.exe"
$toolchainInvalidExe = ".\assembler\toolchain.asm\custom.exe"
$newline = [Environment]::NewLine

New-Item -ItemType Directory -Force -Path $verifyDir | Out-Null

Push-Location $repoRoot
try {
    Write-Step "Reconstruyendo pablocc"
    $build = Invoke-NativeCapture -FilePath "powershell.exe" -Arguments @(
        "-ExecutionPolicy", "Bypass",
        "-File", ".\assembler\build.ps1"
    )
    Assert-ExitCode -Result $build -Expected 0 -Context "assembler/build.ps1"
    Assert-Exists -Path $pabloccExe -Context "El build del compilador anfitrion no genero build/pablocc.exe"
    Write-Host $build.Output

    Write-Step "Validando dumps"
    $tokens = Invoke-NativeCapture -FilePath $pabloccExe -Arguments @(".\examples\historia-minima.p++", "-tokens")
    Assert-ExitCode -Result $tokens -Expected 0 -Context "historia-minima -tokens"
    Assert-Contains -Text $tokens.Output -Needle "[0] FUNCION" -Context "El dump de tokens no contiene el encabezado esperado"
    Assert-Contains -Text $tokens.Output -Needle "FIN_ARCHIVO" -Context "El dump de tokens no llego al EOF"

    $ast = Invoke-NativeCapture -FilePath $pabloccExe -Arguments @(".\examples\historia-minima.p++", "-ast")
    Assert-ExitCode -Result $ast -Expected 0 -Context "historia-minima -ast"
    Assert-Contains -Text $ast.Output -Needle "AST (5 nodos)" -Context "El dump AST no coincide con historia-minima"
    Assert-Contains -Text $ast.Output -Needle "FUNCION nombre=historiaPrincipal" -Context "El dump AST no incluye historiaPrincipal"

    $emitAsm = Invoke-NativeCapture -FilePath $pabloccExe -Arguments @(".\examples\historia-minima.p++", "-emit-asm")
    Assert-ExitCode -Result $emitAsm -Expected 0 -Context "historia-minima -emit-asm"
    Assert-Exists -Path (Join-Path $buildDir "program.asm") -Context "El modo -emit-asm no genero build/program.asm"

    Set-Content -LiteralPath (Join-Path $verifyDir "vacio-simple.p++") -Encoding ASCII -Value @'
funcion saludo() -> vacio {
    devolver;
}

funcion historiaPrincipal() -> entero32 {
    saludo();
    devolver 4;
}
'@

    Set-Content -LiteralPath (Join-Path $verifyDir "seis-args.p++") -Encoding ASCII -Value @'
funcion sumar6(a : entero32, b : entero32, c : entero32, d : entero32, e : entero32, f : entero32) -> entero32 {
    devolver a + b + c + d + e + f;
}

funcion historiaPrincipal() -> entero32 {
    devolver sumar6(1, 1, 1, 1, 1, 1);
}
'@

    Set-Content -LiteralPath (Join-Path $verifyDir "natural8-wrap.p++") -Encoding ASCII -Value @'
funcion historiaPrincipal() -> entero32 {
    sea x : natural8 = 255;
    x = x + 1;

    si (x == 0) {
        devolver 8;
    }

    devolver 0;
}
'@

    Set-Content -LiteralPath (Join-Path $verifyDir "imprimir-mixto.p++") -Encoding ASCII -Value @'
funcion contarSaltos(meta : entero32) -> entero32 {
    sea pasos : entero32 = 0;

    mientras (pasos < meta) {
        pasos = pasos + 1;
    }

    devolver pasos;
}

funcion historiaPrincipal() -> entero32 {
    imprimirEntero32(contarSaltos(5));
    imprimirLinea();
    devolver 0;
}
'@

    Set-Content -LiteralPath (Join-Path $verifyDir "imprimir-tipos.p++") -Encoding ASCII -Value @'
funcion historiaPrincipal() -> entero32 {
    imprimirEntero8(-5);
    imprimirLinea();
    imprimirEntero64(1234567890);
    imprimirLinea();
    imprimirNatural8(250);
    imprimirLinea();
    imprimirNatural64(1234567890);
    devolver 0;
}
'@

    Write-Step "Validando end-to-end"
    $positiveCases = @(
        @{
            Name = "historia-minima"
            CompileArgs = @(".\examples\historia-minima.p++")
            ExePath = $programExe
            ExpectedExit = 0
        },
        @{
            Name = "retorno-siete"
            CompileArgs = @(".\examples\retorno-siete.p++")
            ExePath = $programExe
            ExpectedExit = 7
        },
        @{
            Name = "aritmetica-basica"
            CompileArgs = @(".\examples\aritmetica-basica.p++")
            ExePath = $programExe
            ExpectedExit = 7
        },
        @{
            Name = "contar-saltos"
            CompileArgs = @(".\examples\contar-saltos.p++")
            ExePath = $programExe
            ExpectedExit = 5
        },
        @{
            Name = "contar-saltos-custom"
            CompileArgs = @(".\examples\contar-saltos.p++", "-o", ".\build\custom.exe")
            ExePath = $customExe
            ExpectedExit = 5
        },
        @{
            Name = "contar-saltos-espacios"
            CompileArgs = @(".\examples\contar-saltos.p++", "-o", ".\build\salida personalizada.exe")
            ExePath = $spacedExe
            ExpectedExit = 5
        },
        @{
            Name = "si-logico"
            CompileArgs = @(".\examples\si-logico.p++")
            ExePath = $programExe
            ExpectedExit = 1
        },
        @{
            Name = "vuelta-con-para"
            CompileArgs = @(".\examples\vuelta-con-para.p++")
            ExePath = $programExe
            ExpectedExit = 4
        },
        @{
            Name = "control-bucle"
            CompileArgs = @(".\examples\control-bucle.p++")
            ExePath = $programExe
            ExpectedExit = 5
        },
        @{
            Name = "externa-abs"
            CompileArgs = @(".\examples\externa-abs.p++")
            ExePath = $programExe
            ExpectedExit = 7
        },
        @{
            Name = "tipos-escalares"
            CompileArgs = @(".\examples\tipos-escalares.p++")
            ExePath = $programExe
            ExpectedExit = 9
        },
        @{
            Name = "funcion-vacio"
            CompileArgs = @(".\build\verify\vacio-simple.p++")
            ExePath = $programExe
            ExpectedExit = 4
        },
        @{
            Name = "seis-args"
            CompileArgs = @(".\build\verify\seis-args.p++")
            ExePath = $programExe
            ExpectedExit = 6
        },
        @{
            Name = "natural8-wrap"
            CompileArgs = @(".\build\verify\natural8-wrap.p++")
            ExePath = $programExe
            ExpectedExit = 8
        },
        @{
            Name = "imprimir-basico"
            CompileArgs = @(".\examples\imprimir-basico.p++")
            ExePath = $programExe
            ExpectedExit = 0
            ExpectedOutput = "7"
        },
        @{
            Name = "imprimir-logico"
            CompileArgs = @(".\examples\imprimir-logico.p++")
            ExePath = $programExe
            ExpectedExit = 0
            ExpectedOutput = "verdadero${newline}falso"
        },
        @{
            Name = "imprimir-mixto"
            CompileArgs = @(".\build\verify\imprimir-mixto.p++")
            ExePath = $programExe
            ExpectedExit = 0
            ExpectedOutput = "5"
        },
        @{
            Name = "imprimir-tipos"
            CompileArgs = @(".\build\verify\imprimir-tipos.p++")
            ExePath = $programExe
            ExpectedExit = 0
            ExpectedOutput = "-5${newline}1234567890${newline}250${newline}1234567890"
        }
    )

    foreach ($case in $positiveCases) {
        $compile = Invoke-NativeCapture -FilePath $pabloccExe -Arguments $case.CompileArgs
        Assert-ExitCode -Result $compile -Expected 0 -Context "$($case.Name) compilo con error"
        Assert-Exists -Path $case.ExePath -Context "$($case.Name) no genero el ejecutable esperado"

        $run = Invoke-NativeCapture -FilePath $case.ExePath
        Assert-ExitCode -Result $run -Expected $case.ExpectedExit -Context "$($case.Name) devolvio un codigo incorrecto"
        if ($case.ContainsKey("ExpectedOutput")) {
            Assert-OutputEquals -Actual $run.Output -Expected $case.ExpectedOutput -Context "$($case.Name) produjo una salida inesperada"
        }

        Write-Host ("{0}: compile=0 run={1}" -f $case.Name, $case.ExpectedExit)
    }

    $buildCwdCompile = Invoke-NativeCapture -FilePath "powershell.exe" -Arguments @(
        "-NoProfile",
        "-Command",
        "Set-Location -LiteralPath '$buildDir'; .\pablocc.exe ..\examples\imprimir-basico.p++"
    )
    Assert-ExitCode -Result $buildCwdCompile -Expected 0 -Context "imprimir-basico desde build/"
    Assert-Exists -Path $nestedProgramExe -Context "La compilacion desde build/ no genero build/build/program.exe"

    $buildCwdRun = Invoke-NativeCapture -FilePath $nestedProgramExe
    Assert-ExitCode -Result $buildCwdRun -Expected 0 -Context "El ejecutable generado desde build/ devolvio un codigo inesperado"
    Assert-OutputEquals -Actual $buildCwdRun.Output -Expected "7" -Context "El ejecutable generado desde build/ no imprimio la salida esperada"

    Write-Step "Generando casos negativos"
    Set-Content -LiteralPath (Join-Path $verifyDir "lexer-error.p++") -Encoding ASCII -Value @'
funcion historiaPrincipal() -> entero32 {
    devolver @;
}
'@

    Set-Content -LiteralPath (Join-Path $verifyDir "parser-error.p++") -Encoding ASCII -Value @'
funcion historiaPrincipal() -> entero32 {
    devolver 0
}
'@

    Set-Content -LiteralPath (Join-Path $verifyDir "semantic-error.p++") -Encoding ASCII -Value @'
funcion historiaPrincipal() -> entero32 {
    devolver fantasma;
}
'@

    Set-Content -LiteralPath (Join-Path $verifyDir "constante-assign-error.p++") -Encoding ASCII -Value @'
funcion historiaPrincipal() -> entero32 {
    constante meta : entero32 = 3;
    meta = 4;
    devolver meta;
}
'@

    Set-Content -LiteralPath (Join-Path $verifyDir "continue-error.p++") -Encoding ASCII -Value @'
funcion historiaPrincipal() -> entero32 {
    continuar;
}
'@

    Set-Content -LiteralPath (Join-Path $verifyDir "break-error.p++") -Encoding ASCII -Value @'
funcion historiaPrincipal() -> entero32 {
    romper;
}
'@

    Set-Content -LiteralPath (Join-Path $verifyDir "return-void-error.p++") -Encoding ASCII -Value @'
funcion hablar() -> vacio {
    devolver 1;
}

funcion historiaPrincipal() -> entero32 {
    devolver 0;
}
'@

    Set-Content -LiteralPath (Join-Path $verifyDir "return-nonvoid-error.p++") -Encoding ASCII -Value @'
funcion historiaPrincipal() -> entero32 {
    devolver;
}
'@

    Set-Content -LiteralPath (Join-Path $verifyDir "type-mismatch-error.p++") -Encoding ASCII -Value @'
funcion historiaPrincipal() -> entero32 {
    sea n : natural32 = 1;
    sea e : entero32 = n;
    devolver e;
}
'@

    Set-Content -LiteralPath (Join-Path $verifyDir "duplicate-externa-error.p++") -Encoding ASCII -Value @'
externa foo() -> entero32;

funcion foo() -> entero32 {
    devolver 0;
}

funcion historiaPrincipal() -> entero32 {
    devolver 0;
}
'@

    Set-Content -LiteralPath (Join-Path $verifyDir "builtin-duplicate-error.p++") -Encoding ASCII -Value @'
funcion imprimirEntero32(valor : entero32) -> vacio {
    devolver;
}

funcion historiaPrincipal() -> entero32 {
    devolver 0;
}
'@

    Set-Content -LiteralPath (Join-Path $verifyDir "builtin-externa-error.p++") -Encoding ASCII -Value @'
externa imprimirEntero32(valor : entero32) -> vacio;

funcion historiaPrincipal() -> entero32 {
    devolver 0;
}
'@

    Set-Content -LiteralPath (Join-Path $verifyDir "builtin-linea-arity-error.p++") -Encoding ASCII -Value @'
funcion historiaPrincipal() -> entero32 {
    imprimirLinea(1);
    devolver 0;
}
'@

    Set-Content -LiteralPath (Join-Path $verifyDir "builtin-entero-tipo-error.p++") -Encoding ASCII -Value @'
funcion historiaPrincipal() -> entero32 {
    imprimirEntero32(verdadero);
    devolver 0;
}
'@

    Set-Content -LiteralPath (Join-Path $verifyDir "builtin-logico-tipo-error.p++") -Encoding ASCII -Value @'
funcion historiaPrincipal() -> entero32 {
    imprimirLogico(1);
    devolver 0;
}
'@

    Write-Step "Validando diagnosticos utiles"
    $lexerError = Invoke-NativeCapture -FilePath $pabloccExe -Arguments @(".\build\verify\lexer-error.p++")
    Assert-NonZeroExit -Result $lexerError -Context "El caso de error lexico"
    Assert-Contains -Text $lexerError.Output -Needle "error[lexer:300]" -Context "El diagnostico lexico no contiene lexer:300"

    $parserError = Invoke-NativeCapture -FilePath $pabloccExe -Arguments @(".\build\verify\parser-error.p++")
    Assert-NonZeroExit -Result $parserError -Context "El caso de error parser"
    Assert-Contains -Text $parserError.Output -Needle "error[parser:400]" -Context "El diagnostico parser no contiene parser:400"

    $semanticError = Invoke-NativeCapture -FilePath $pabloccExe -Arguments @(".\build\verify\semantic-error.p++")
    Assert-NonZeroExit -Result $semanticError -Context "El caso de error semantico"
    Assert-Contains -Text $semanticError.Output -Needle "error[semantic:503]" -Context "El diagnostico semantico no contiene semantic:503"

    $constAssignError = Invoke-NativeCapture -FilePath $pabloccExe -Arguments @(".\build\verify\constante-assign-error.p++")
    Assert-NonZeroExit -Result $constAssignError -Context "El caso de asignacion a constante"
    Assert-Contains -Text $constAssignError.Output -Needle "error[semantic:507]" -Context "La asignacion a constante no devolvio semantic:507"

    $continueError = Invoke-NativeCapture -FilePath $pabloccExe -Arguments @(".\build\verify\continue-error.p++")
    Assert-NonZeroExit -Result $continueError -Context "El caso de continuar fuera de bucle"
    Assert-Contains -Text $continueError.Output -Needle "error[semantic:511]" -Context "El diagnostico de continuar fuera de bucle no contiene semantic:511"

    $breakError = Invoke-NativeCapture -FilePath $pabloccExe -Arguments @(".\build\verify\break-error.p++")
    Assert-NonZeroExit -Result $breakError -Context "El caso de romper fuera de bucle"
    Assert-Contains -Text $breakError.Output -Needle "error[semantic:511]" -Context "El diagnostico de romper fuera de bucle no contiene semantic:511"

    $returnVoidError = Invoke-NativeCapture -FilePath $pabloccExe -Arguments @(".\build\verify\return-void-error.p++")
    Assert-NonZeroExit -Result $returnVoidError -Context "El caso de devolver expresion en funcion vacio"
    Assert-Contains -Text $returnVoidError.Output -Needle "error[semantic:512]" -Context "El diagnostico de devolver expresion en funcion vacio no contiene semantic:512"

    $returnNonVoidError = Invoke-NativeCapture -FilePath $pabloccExe -Arguments @(".\build\verify\return-nonvoid-error.p++")
    Assert-NonZeroExit -Result $returnNonVoidError -Context "El caso de devolver sin expresion en funcion no vacia"
    Assert-Contains -Text $returnNonVoidError.Output -Needle "error[semantic:512]" -Context "El diagnostico de devolver sin expresion no contiene semantic:512"

    $mismatchError = Invoke-NativeCapture -FilePath $pabloccExe -Arguments @(".\build\verify\type-mismatch-error.p++")
    Assert-NonZeroExit -Result $mismatchError -Context "El caso de mismatch exacto de tipos"
    Assert-Contains -Text $mismatchError.Output -Needle "error[semantic:507]" -Context "El diagnostico de mismatch de tipos no contiene semantic:507"

    $duplicateExternaError = Invoke-NativeCapture -FilePath $pabloccExe -Arguments @(".\build\verify\duplicate-externa-error.p++")
    Assert-NonZeroExit -Result $duplicateExternaError -Context "El caso de declaracion externa duplicada"
    Assert-Contains -Text $duplicateExternaError.Output -Needle "error[semantic:500]" -Context "El diagnostico de declaracion externa duplicada no contiene semantic:500"

    $builtinDuplicateError = Invoke-NativeCapture -FilePath $pabloccExe -Arguments @(".\build\verify\builtin-duplicate-error.p++")
    Assert-NonZeroExit -Result $builtinDuplicateError -Context "El caso de redefinicion de builtin"
    Assert-Contains -Text $builtinDuplicateError.Output -Needle "error[semantic:500]" -Context "La redefinicion de builtin no devolvio semantic:500"

    $builtinExternaError = Invoke-NativeCapture -FilePath $pabloccExe -Arguments @(".\build\verify\builtin-externa-error.p++")
    Assert-NonZeroExit -Result $builtinExternaError -Context "El caso de declaracion externa de builtin"
    Assert-Contains -Text $builtinExternaError.Output -Needle "error[semantic:500]" -Context "La declaracion externa de builtin no devolvio semantic:500"

    $builtinLineaArityError = Invoke-NativeCapture -FilePath $pabloccExe -Arguments @(".\build\verify\builtin-linea-arity-error.p++")
    Assert-NonZeroExit -Result $builtinLineaArityError -Context "El caso de aridad invalida en imprimirLinea"
    Assert-Contains -Text $builtinLineaArityError.Output -Needle "error[semantic:505]" -Context "La aridad invalida de imprimirLinea no devolvio semantic:505"

    $builtinEnteroTipoError = Invoke-NativeCapture -FilePath $pabloccExe -Arguments @(".\build\verify\builtin-entero-tipo-error.p++")
    Assert-NonZeroExit -Result $builtinEnteroTipoError -Context "El caso de tipo invalido en imprimirEntero32"
    Assert-Contains -Text $builtinEnteroTipoError.Output -Needle "error[semantic:507]" -Context "El tipo invalido de imprimirEntero32 no devolvio semantic:507"

    $builtinLogicoTipoError = Invoke-NativeCapture -FilePath $pabloccExe -Arguments @(".\build\verify\builtin-logico-tipo-error.p++")
    Assert-NonZeroExit -Result $builtinLogicoTipoError -Context "El caso de tipo invalido en imprimirLogico"
    Assert-Contains -Text $builtinLogicoTipoError.Output -Needle "error[semantic:507]" -Context "El tipo invalido de imprimirLogico no devolvio semantic:507"

    $toolchainError = Invoke-NativeCapture -FilePath $pabloccExe -Arguments @(".\examples\historia-minima.p++", "-o", $toolchainInvalidExe)
    Assert-NonZeroExit -Result $toolchainError -Context "El caso de error toolchain"
    Assert-Contains -Text $toolchainError.Output -Needle "error[toolchain:700]" -Context "El diagnostico toolchain no contiene toolchain:700"
    Assert-Contains -Text $toolchainError.Output -Needle "program-build.ps1" -Context "El fallo toolchain no expuso la wrapper script"
    Assert-Contains -Text $toolchainError.Output -Needle "NASM fallo" -Context "El fallo toolchain no expuso el error de NASM"

    Write-Step "Resumen"
    Write-Host "Verificacion completa: OK"
}
finally {
    Pop-Location
}
