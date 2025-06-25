$ErrorActionPreference = 'Stop'

$packageName = 'nx'
$version     = '21.2.1'
$toolsDir    = Split-Path -Parent $MyInvocation.MyCommand.Definition
$tgzUrl      = "https://registry.npmjs.org/$packageName/-/$packageName-$version.tgz"
$tgzFile     = Join-Path $toolsDir "$packageName-$version.tgz"
$checksum     = '6b07809bf959112ad9c6764e6366a8d13bb445dc7674239381249cd2fd6901d1'
$checksumType = 'sha256'

# 1. Download the tarball
Get-ChocolateyWebFile -PackageName $packageName `
                      -FileFullPath $tgzFile `
                      -Url $tgzUrl `
                      -Checksum $checksum `
                      -ChecksumType $checksumType

# 2. Locate npm.cmd reliably
$npm = (Get-Command npm.cmd -ErrorAction SilentlyContinue).Source 
if (-not $npm) {
  # fallback: Chocolatey always links npm here
  $npm = Join-Path $env:ChocolateyInstall 'bin\npm.cmd'
  if (-not (Test-Path $npm)) {
    throw 'npm.cmd not found on PATH'
  }
}

# 3. Install Nx into toolsDir (self‑contained)
$npmArgs = @"
install --prefix "`"$toolsDir`"" "`"$tgzFile`"" --omit=dev --loglevel error --no-audit --no-fund
"@

Write-Host "Running: `"$npm`" $npmArgs"

Start-ChocolateyProcessAsAdmin `
  -ExeToRun       $npm `
  -Statements     $npmArgs `
  -WorkingDirectory $toolsDir

# 4. Shim the wrapper npm just created
$wrapper = Join-Path $toolsDir 'node_modules\.bin\nx.cmd'
if (-not (Test-Path $wrapper)) {
  throw "Expected wrapper '$wrapper' was not created."
}
Install-BinFile -Name 'nx' -Path $wrapper

Write-Host "Nx $version installed successfully."


