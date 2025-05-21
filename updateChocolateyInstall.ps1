param (
    [Parameter(Mandatory = $true)]
    [string]$NewVersion
)

# Define the path to the chocolateyInstall.ps1 file
$scriptPath = ".\packages\nx-chocolatey\tools\chocolateyInstall.ps1"

# Read the content of the chocolateyInstall.ps1 file
$scriptContent = Get-Content -Path $scriptPath -Raw

# Update the $version variable in the script
$scriptContent = $scriptContent -replace '(?<=\$version\s+=\s+[''"])(\d+\.\d+\.\d+)(?=[''"])', $NewVersion

# Define the package name and construct the URL for the tarball
$packageName = 'nx'
$tgzUrl = "https://registry.npmjs.org/$packageName/-/$packageName-$NewVersion.tgz"

# Download the tarball to a temporary location
$tempTgzFile = Join-Path -Path $env:TEMP -ChildPath "$packageName-$NewVersion.tgz"
Invoke-WebRequest -Uri $tgzUrl -OutFile $tempTgzFile

# Compute the SHA256 checksum of the downloaded tarball
$checksum = (Get-FileHash -Path $tempTgzFile -Algorithm SHA256 | Select-Object -ExpandProperty Hash).ToLower()

# Update the $checksum variable in the script
$scriptContent = $scriptContent -replace '(?<=\$checksum\s+=\s+[''"])[a-fA-F0-9]+(?=[''"])', $checksum

# Save the updated content back to the chocolateyInstall.ps1 file
Set-Content -Path $scriptPath -Value $scriptContent

# Clean up the temporary tarball file
Remove-Item -Path $tempTgzFile -Force

Write-Host "Updated chocolateyInstall.ps1 to version $NewVersion with checksum $checksum."