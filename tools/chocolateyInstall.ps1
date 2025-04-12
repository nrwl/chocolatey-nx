$ErrorActionPreference = 'Stop'

$packageName = 'nx'
$version     = '20.7.2'
$toolsDir    = Split-Path -Parent $MyInvocation.MyCommand.Definition
$tgzUrl      = "https://registry.npmjs.org/$packageName/-/$packageName-$version.tgz"
$tgzFile     = Join-Path $toolsDir "$packageName-$version.tgz"

# Download tgz from npm registry
Get-ChocolateyWebFile -PackageName $packageName `
                      -FileFullPath $tgzFile `
                      -Url $tgzUrl
$pkgDir = Join-Path $toolsDir 'package'

# Install nx package
$npmArgs = @('--prefix', $toolsDir,
             'install', $tgzFile,
             '--omit=dev',
             '--loglevel','error','--no-audit','--no-fund')
Start-Process 'npm.cmd' -ArgumentList $npmArgs -NoNewWindow -Wait -PassThru
if ($proc.ExitCode) { throw "npm exited $($proc.ExitCode)" }

# Install binary wrapper
$wrapper = Join-Path $toolsDir 'node_modules\.bin\nx.cmd'
Install-BinFile -Name 'nx' -Path $wrapper
Write-Host "Nx $version installed successfully."