$ErrorActionPreference = "Stop"

# -----------------------------------------------------------------------------
# Initialize Visual Studio environment variables.
# -----------------------------------------------------------------------------

$VSInstallationPath = .\bin\vswhere.exe `
    -latest `
    -nologo `
    -property installationpath

if ($LASTEXITCODE -ne 0) {
    Write-Error "$VSInstallationPath"
    Exit 1;
}

Import-Module "$VSInstallationPath\Common7\Tools\Microsoft.VisualStudio.DevShell.dll"

Enter-VsDevShell `
    -SkipAutomaticLocation `
    -VsInstallPath $VSInstallationPath

# -----------------------------------------------------------------------------
# Generate Photino.Native build files with premake.
# -----------------------------------------------------------------------------

premake5 vs2022

if ($LASTEXITCODE -ne 0) {
    Exit 1;
}

# -----------------------------------------------------------------------------
# Build Photino.Native.
# -----------------------------------------------------------------------------

nuget restore build

if ($LASTEXITCODE -ne 0) {
    Exit 1;
}

MSBuild.exe build/Photino.Native.vcxproj /p:Platform=x64

if ($LASTEXITCODE -ne 0) {
    Exit 1;
}

# -----------------------------------------------------------------------------
# Package and publish Photino.Native to NuGet cache.
# -----------------------------------------------------------------------------

nuget pack `
    -OutputDirectory photino.Native\Photino.Native `
    -Version 9999.0 `
    photino.Native.nuspec

if ($LASTEXITCODE -ne 0) {
    Exit 1;
}

dotnet nuget delete `
    --non-interactive `
    --source "${env:UserProfile}\.nuget\packages" `
    Photino.Native 9999.0.0

dotnet nuget push `
    --source "${env:UserProfile}\.nuget\packages" `
    photino.Native\Photino.Native\Photino.Native.9999.0.0.nupkg

if ($LASTEXITCODE -ne 0) {
    Exit 1;
}

# -----------------------------------------------------------------------------
# Package and publish Photino.NET to NuGet cache.
# -----------------------------------------------------------------------------

dotnet pack `
    -c debug `
    -p:Version=9999.0.0 `
    photino.NET\Photino.NET

if ($LASTEXITCODE -ne 0) {
    Exit 1;
}

dotnet nuget delete `
    --non-interactive `
    --source "${env:UserProfile}\.nuget\packages" `
    Photino.NET 9999.0.0

dotnet nuget push `
    --source "${env:UserProfile}\.nuget\packages" `
    photino.NET\Photino.NET\bin\Debug\Photino.NET.9999.0.0.nupkg

if ($LASTEXITCODE -ne 0) {
    Exit 1;
}