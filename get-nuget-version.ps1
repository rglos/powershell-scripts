<#
.SYNOPSIS
    Traverse a directory structure to determine what versions of a NuGet library are being used.
.EXAMPLE
    ./get-nuget-version 
#>
[CmdletBinding()]
param(
    [string]$nugetPackagesConfigIdSearchString = "Microsoft.ApplicationInsights*"
    ,[string]$folderPathToSearchRecursively
)

# Get all the packages.config files in the directory and all subdirectories
$nugetPackageConfigFiles = Get-ChildItem $folderPathToSearchRecursively packages.config -recurse
foreach ($nugetPackageConfigFile in $nugetPackageConfigFiles)
{
    $xml = [xml](Get-Content $nugetPackageConfigFile.FullName)
    $packagesWithDesiredId = $xml.packages.package | Where-Object { 
        $_.id -like $nugetPackagesConfigIdSearchString
    }

    if ($packagesWithDesiredId.Count -gt 0) {
        Write-Information "Found package with search string"
        $nugetPackageConfigFile.DirectoryName
        $nugetPackageConfigFile.Directory
        $packagesWithDesiredId
    }
}