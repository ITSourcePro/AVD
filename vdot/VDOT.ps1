<#
    .SYNOPSIS
        Virtual Desktop Optimalization Tool (VDOT)
    .DESCRIPTION
        Download the Virtual Desktop Optimalization Tool (VDOT), creates a folder called optimize and runs VDOT tool.
        The VDOT tool determines OS version at run-time
    .NOTES
        Version:        1.0
        Author:         Ivo Beerens
                        info@ivobeerens.nl
        Creation Date:  13-02-2022
        Plattform:      Windows multi session
        Changelog:      
                        22-02-2022      1.0 - Initial script development
    .COMPONENT

    .LINK
        https://github.com/The-Virtual-Desktop-Team/Virtual-Desktop-Optimization-Tool
        https://docs.microsoft.com/en-us/windows-server/remote/remote-desktop-services/rds-vdi-recommendations-2004
    .Example
        Script needs to be run with PowerShell elevated
#>

# Variables
$verbosePreference = 'Continue'
$vdot = 'https://github.com/The-Virtual-Desktop-Team/Virtual-Desktop-Optimization-Tool/archive/refs/heads/main.zip' 
$vdot_location = 'c:\Optimize' 
$vdot_location_zip = 'c:\Optimize\vdot.zip'
$apppackages = 'https://raw.githubusercontent.com/ibeerens/AVD/main/vdot/AppxPackages.json'
$apppackages_location = 'C:\Optimize\AppxPackages.json'

# Enable TLS 1.2
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# Create Folder
$checkdir = Test-Path -Path $vdot_location
if ($checkdir -eq $false){
    Write-Verbose "Creating '$vdot_location' folder"
    New-Item -Path 'c:\' -Name 'Optimize' -ItemType 'directory' | Out-Null
}
else {
    Write-Verbose "Folder '$vdot_location' already exists."
}

# Download VDOT
Invoke-WebRequest -Uri $vdot -OutFile $vdot_location_zip

# Expand Archive
Expand-Archive $vdot_location_zip -DestinationPath $vdot_location -Verbose -Force

# Remove Archive
Remove-Item $vdot_location_zip

# Download AppPackages.json
Invoke-WebRequest -Uri $apppackages -OutFile $apppackages_location

# Copy the AppPackage file to all versions
Copy-Item $apppackages_location -Destination 'C:\Optimize\Virtual-Desktop-Optimization-Tool-main\1909\ConfigurationFiles\AppxPackages.json'
Copy-Item $apppackages_location -Destination 'C:\Optimize\Virtual-Desktop-Optimization-Tool-main\2004\ConfigurationFiles\AppxPackages.json'
Copy-Item $apppackages_location -Destination 'C:\Optimize\Virtual-Desktop-Optimization-Tool-main\2009\ConfigurationFiles\AppxPackages.json'

# Unblock all files
dir $vdot_location -Recurse | Unblock-File

# Change folder to VDOT folder
$vdot_folder = $vdot_location + '\Virtual-Desktop-Optimization-Tool-main' 
cd $vdot_folder

Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope Process -Force
.\Windows_VDOT.ps1 -Verbose -AcceptEULA

# Sleep 5 seconds
sleep 5

# Remove folder
cd \
Remove-Item $vdot_location -Recurse -Force
