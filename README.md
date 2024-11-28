# Photino.Development

This repository contains scripts and information that might be useful when contributing to Photino.

## Getting Started

Clone this repository and its submodules.

```powershell
git clone --recurse-submodules https://github.com/sinterdev/photino.Development.git
```

Alternatively, if you've already cloned the repository, ensure that your cloned repository has its submodules initialized.

```powershell
git submodule update --init --recursive
```

Edit `photino.Native\Photino.NET\Photino.NET.csproj` to use version `9999.0.0` of `Photino.Native`.

```xml
<!-- ... -->
<ItemGroup>
    <PackageReference Include="Photino.Native" Version="9999.0.0" />
</ItemGroup>
<!-- ... -->
```

Edit your sample project (i.e., the project in `photino.Samples`) to use version `9999.0.0` of `Photino.NET`.

```xml
<!-- ... -->
<ItemGroup>
    <PackageReference Include="Photino.NET" Version="9999.0.0" />
</ItemGroup>
<!-- ... -->
```

Build and publish `Photino.Native` and `Photino.NET` (currently only available on Windows).

```powershell
.\Publish.ps1
```

Run one of the samples from `Photino.Samples`.

```powershell
dotnet run --force --project .\photino.Samples\Photino.HelloPhotino.NET\HelloPhotino.NET.csproj
```

## Scripts

- `Publish.ps1` - Build and publish `Photino.Native` and `Photino.NET` to your local NuGet cache to speed up development on Windows.
- `premake5.lua` - Generate platform-specific build files for `Photino.Native`.

## Debugging

When adding features to `Photino.Native` or `Photino.NET`, you might want to symbolically debug your changes. See [Debug in mixed mode (C#, C++, Visual Basic)](https://learn.microsoft.com/en-us/visualstudio/debugger/how-to-debug-in-mixed-mode) for more information.