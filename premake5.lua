-------------------------------------------------------------------------------
-- Configuration
-------------------------------------------------------------------------------

workspace "Photino.Native"
    location "build"

    configurations {
        "Debug",
        "Release"
    }

    platforms {
        "x86",
        "x86_64",
        "ARM64"
    }

    project "Photino.Native"
        cppdialect "C++11"
        kind "SharedLib"
        language "C++"
        targetdir "photino.Native/Photino.Native/bin"

        files {
            "photino.Native/Photino.Native/Exports.cpp",
            "photino.Native/Photino.Native/Photino.Errors.cpp",
            "photino.Native/Photino.Native/Photino.Errors.h"
        }

        filter "x86"
            architecture "x86"

        filter "x86_64"
            architecture "x86_64"

        filter "ARM64"
            architecture "ARM64"

        filter "configurations:Debug"
            defines { "DEBUG" }
            symbols "On"

        filter "configurations:Release"
            defines { "NDEBUG" }
            optimize "On"

        filter { "system:Windows", "platforms:x86" }
            targetdir "photino.Native/Photino.Native/win32"

        filter { "system:Windows", "platforms:x86_64" }
            targetdir "photino.Native/Photino.Native/x64"

        filter { "system:Windows", "platforms:ARM64" }
            targetdir "photino.Native/Photino.Native/arm64"

        filter "system:Windows"
            atl "Static"

            nuget {
                "Microsoft.Web.WebView2:1.0.1462.37",
                "Microsoft.Windows.ImplementationLibrary:1.0.220914.1"
            }

            files {
                "photino.Native/Photino.Native/Dependencies/wintoastlib.cpp",
                "photino.Native/Photino.Native/Photino.Windows**.cpp",
                "photino.Native/Photino.Native/Photino.Windows**.h"
            }

-------------------------------------------------------------------------------
-- Extensions
-------------------------------------------------------------------------------

require('vstudio')

local nugettargets = {
    ["Microsoft.Web.WebView2"] = path.translate("build/native/Microsoft.Web.WebView2.targets")
}

local p = premake
local vstudio = premake.vstudio

local function nuGetTargetsFile(prj, package, extension)
    local packageAPIInfo = vstudio.nuget2010.packageAPIInfo(prj, package)

    if not packageAPIInfo.packageEntries then
        return nil
    end

    -- There is currently a bug with `nuget` in premake that selects the first
    -- `.targets` file from the nuget package. We want to select a particular
    -- `.targets` file as shown in the `nugettargets` table above. So, we loop
    -- through the package entries (i.e., files inside of the package archive)
    -- and return the matching path if `nugettargets` contains one. Most of
    -- this code was copied from the following.
    -- https://github.com/premake/premake-core/blob/ffcb7790f013bdceacc14ba5fda1c5cd107aac08/modules/vstudio/vs2010_vcxproj.lua#L2360-L2384

    for _, entry in ipairs(packageAPIInfo.packageEntries) do
        print(nugettargets[vstudio.nuget2010.packageId(package)], entry)
        if entry == nugettargets[vstudio.nuget2010.packageId(package)] then
            local packageRootPath = p.filename(prj.workspace, string.format("packages\\%s.%s\\", vstudio.nuget2010.packageId(package), packageAPIInfo.verbatimVersion or packageAPIInfo.version))
            return p.vstudio.path(prj, path.join(packageRootPath, entry))
        end
    end

    for _, entry in ipairs(packageAPIInfo.packageEntries) do
        if path.getextension(entry) == extension then
            local packageRootPath = p.filename(prj.workspace, string.format("packages\\%s.%s\\", vstudio.nuget2010.packageId(package), packageAPIInfo.verbatimVersion or packageAPIInfo.version))
            return p.vstudio.path(prj, path.join(packageRootPath, entry))
        end
    end

    return nil
end

premake.override(premake.vstudio.vc2010, "importNuGetTargets", function(base, prj)
    if not vstudio.nuget2010.supportsPackageReferences(prj) then
        for i = 1, #prj.nuget do
            local targetsFile = nuGetTargetsFile(prj, prj.nuget[i], ".targets")
            if targetsFile then
                p.x('<Import Project="%s" Condition="Exists(\'%s\')" />', targetsFile, targetsFile)
            end
        end
    end
end)

-- We append the `WebView2LoaderPreference` property here so that we can support AOT.
-- For more information, see...
-- https://learn.microsoft.com/en-us/microsoft-edge/webview2/how-to/static
premake.override(premake.vstudio.vc2010.elements, "globals", function(base, prj)
    local calls = base(prj)

    table.insert(calls, function(prj)
        p.w('<WebView2LoaderPreference>Dynamic</WebView2LoaderPreference>')
    end)

    return calls
end)