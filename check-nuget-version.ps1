<#
.SYNOPSIS
    Use this script to search for packages.config files that need to be updated for a given NuGet package id
    and desired version.  If it does not match the version, a warning will display for that directory.

.EXAMPLE
    ./check-nuget-version.ps1 -folderPathToSearchRecursively "C:\source\vsts\Hotfix-15384\Portals"

.NOTES
    Longer term, we may be able to take this a step further and perform the actual NuGet update allowing it to 
    do it's thing and update dependencies, etc.
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)][string]$folderPathToSearchRecursively
)

# TODO: make these parameters
$nugetPackagesConfigIdSearchString = "Nvoicepay.Telemetry*"
$nugetPackagesConfigDesiredVersion = "8.0.1734501"

# Get all the packages.config files in the directory and all subdirectories
$nugetPackageConfigFiles = Get-ChildItem $folderPathToSearchRecursively packages.config -recurse

# Loop through each files
$listOfSolutionDirectories = New-Object System.Collections.ArrayList
foreach ($nugetPackageConfigFile in $nugetPackageConfigFiles)
{
    # Here we get the file content as XML and then search it
    $xml = [xml](Get-Content $nugetPackageConfigFile.FullName)
    $packagesNotMeetingDesiredVersion = $xml.packages.package | Where-Object { 
        $_.id -like $nugetPackagesConfigIdSearchString -and $_.version -ne $nugetPackagesConfigDesiredVersion 
    }
    
    # The count above should be zero - if not, we have an old NuGet package version being used
    if ($packagesNotMeetingDesiredVersion.Count -gt 0)
    {
        # This isn't doing anything fancy atm, just regurgitating information to the screen... we could enhance this by building up some kind of objec to report on at the end or Out-GridView or something...
        Write-Warning ("Found packages.config that doesn't have desired version of '{0}'" -f $nugetPackagesConfigDesiredVersion)
        $nugetPackageConfigFile.DirectoryName
        $nugetPackageConfigFile.Directory
        $packagesNotMeetingDesiredVersion

        # Let's add the parent directory, that conventionally contains the solution, to a list and we can output that list after all is done
        # We assume the parent directory contains the solution - .sln (we could check for this...)
        $parentDirectory = $nugetPackageConfigFile.Directory.Parent
        if ($listOfSolutionDirectories.Contains($parentDirectory.FullName) -ne $true) {
            $listOfSolutionDirectories.Add($parentDirectory.FullName)
        }

    }
}

if ($listOfSolutionDirectories.Count -gt 0)
{
    Write-Warning ("The following solution directories should be loaded and updated manually...")
    $listOfSolutionDirectories
}

# Temp code for debugging - this can be deleted if desired
#
# #$xmlFile = "C:\source\vsts\Hotfix-15384\Apis\Campaign\Nvoicepay.Api.Campaign\packages.config"
# $xmlFile = "C:\source\vsts\Hotfix-15384\Apis\Core\Core\packages.config"
#
# $xml = [xml](Get-Content $xmlFile)
# $packagesNotMeetingDesiredVersion = $xml.packages.package | Where-Object { 
#     $_.id -like $nugetPackagesConfigIdSearchString -and $_.version -ne $nugetPackagesConfigDesiredVersion 
# }
