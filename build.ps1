# Script de Compilación Oficial con JDK 22 para IslandZones (Minecraft 1.21.1)
$ErrorActionPreference = "Stop"

$JdkBin = "C:\Program Files\Java\jdk-22\bin"
if (-not (Test-Path $JdkBin)) {
    if ($env:JAVA_HOME -and (Test-Path (Join-Path $env:JAVA_HOME "bin"))) {
        $JdkBin = Join-Path $env:JAVA_HOME "bin"
    } else {
        throw "No se encontró el JDK en $JdkBin ni en JAVA_HOME."
    }
}

$Javac = Join-Path $JdkBin "javac.exe"
$Jar = Join-Path $JdkBin "jar.exe"

$LibDir = Join-Path $PSScriptRoot "libs"
$AllJars = Get-ChildItem -Path $LibDir -Filter "*.jar" -Recurse | Select-Object -ExpandProperty FullName
$CP = $AllJars -join ";"

$BuildDir = Join-Path $PSScriptRoot "build\classes"
if (Test-Path $BuildDir) { Remove-Item -Recurse -Force $BuildDir }
New-Item -ItemType Directory -Path $BuildDir | Out-Null

$Sources = Get-ChildItem -Path (Join-Path $PSScriptRoot "src\main\java") -Filter "*.java" -Recurse | Select-Object -ExpandProperty FullName
$SourcesFile = Join-Path $PSScriptRoot "sources.txt"
$Sources | Out-File -FilePath $SourcesFile -Encoding ASCII

Write-Host "Compilando clases Java con javac (Target: Java 21)..." -ForegroundColor Cyan
& $Javac -encoding UTF-8 --release 21 -proc:none -cp "$CP" -d "$BuildDir" "@$SourcesFile"
Remove-Item -Force $SourcesFile

Write-Host "Copiando recursos (plugin.yml, config.yml)..." -ForegroundColor Cyan
$ResourcesDir = Join-Path $PSScriptRoot "src\main\resources"
Copy-Item -Path "$ResourcesDir\*" -Destination $BuildDir -Recurse -Force

$OutputJar = Join-Path $PSScriptRoot "IslandZones-1.0.0.jar"
if (Test-Path $OutputJar) { Remove-Item -Force $OutputJar }

Write-Host "Empaquetando con jar.exe oficial..." -ForegroundColor Cyan
& $Jar --create --file "$OutputJar" -C "$BuildDir" .

$ServerPluginsDir = "C:\Users\aitor\Desktop\Arclight\plugins"
if (Test-Path $ServerPluginsDir) {
    Write-Host "Copiando automáticamente a la carpeta de plugins del servidor: $ServerPluginsDir..." -ForegroundColor Green
    Copy-Item -Path $OutputJar -Destination (Join-Path $ServerPluginsDir "IslandZones-1.0.0.jar") -Force
}

Write-Host "=================================================" -ForegroundColor Green
Write-Host " JAR DE ISLANDZONES GENERADO CON ÉXITO!" -ForegroundColor Green
Write-Host " Ubicación: $OutputJar" -ForegroundColor White
if (Test-Path $ServerPluginsDir) {
    Write-Host " Instalado en: $ServerPluginsDir\IslandZones-1.0.0.jar" -ForegroundColor White
}
Write-Host "=================================================" -ForegroundColor Green
