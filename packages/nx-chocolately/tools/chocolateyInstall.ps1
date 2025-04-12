$ErrorActionPreference = 'Stop'

$packageName = 'nx'
$version     = '20.7.2'
$toolsDir    = Split-Path -Parent $MyInvocation.MyCommand.Definition
$tgzUrl      = "https://registry.npmjs.org/$packageName/-/$packageName-$version.tgz"
$tgzFile     = Join-Path $toolsDir "$packageName-$version.tgz"
$checksum     = 'f08ea793607013911604bd9854584eacb684f1abce8588cc722e0e7c339827e7'
$checksumType = 'sha256'

# 1. Download the tarball
Get-ChocolateyWebFile -PackageName $packageName `
                      -FileFullPath $tgzFile `
                      -Url $tgzUrl `
                      -Checksum $checksum `
                      -ChecksumType $checksumType

# 2. Locate npm.cmd reliably
$npm = Get-Command npm.cmd -ErrorAction SilentlyContinue |
       Select-Object -ExpandProperty Source -First 1
if (-not $npm) {
  # fallback: Chocolatey always links npm here
  $npm = Join-Path $env:ChocolateyInstall 'bin\npm.cmd'
  if (-not (Test-Path $npm)) {
    throw 'npm.cmd not found on PATH'
  }
}

# 3. Install Nx into toolsDir (self‑contained)
$npmArgs = @(
  '--prefix', $toolsDir,
  'install',  $tgzFile,
  '--omit=dev',
  '--loglevel','error','--no-audit','--no-fund'
)
$proc = Start-Process -FilePath $npm `
                      -ArgumentList $npmArgs `
                      -NoNewWindow -Wait -PassThru
if ($proc.ExitCode -ne 0) {
  throw "npm exited with code $($proc.ExitCode)"
}

# 4. Shim the wrapper npm just created
$wrapper = Join-Path $toolsDir 'node_modules\.bin\nx.cmd'
if (-not (Test-Path $wrapper)) {
  throw "Expected wrapper '$wrapper' was not created."
}
Install-BinFile -Name 'nx' -Path $wrapper

Write-Host "Nx $version installed successfully."
