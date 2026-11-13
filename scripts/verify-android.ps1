param([string]$Device = 'emulator-5554')
$ErrorActionPreference = 'Stop'
$projectRoot = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'))
Set-Location -LiteralPath $projectRoot
$adbCommand = Get-Command adb -ErrorAction SilentlyContinue
$adbPath = if ($adbCommand) { $adbCommand.Source } else { Join-Path $env:LOCALAPPDATA 'Android\Sdk\platform-tools\adb.exe' }
$deviceSize = & $adbPath -s $Device shell wm size
$deviceDensity = & $adbPath -s $Device shell wm density
$overrideSize = [regex]::Match(($deviceSize -join "`n"), 'Override size: (\d+x\d+)').Groups[1].Value
$overrideDensity = [regex]::Match(($deviceDensity -join "`n"), 'Override density: (\d+)').Groups[1].Value
try {
    # Reuse the running device, temporarily use a standard phone viewport.
    & $adbPath -s $Device shell wm size 1080x2400
    & $adbPath -s $Device shell wm density 432
    flutter drive --driver=test_driver/screenshot_driver.dart --target=integration_test/app_test.dart -d $Device
    if ($LASTEXITCODE -ne 0) { throw 'Android integration verification failed.' }
} finally {
    if ($overrideSize) { & $adbPath -s $Device shell wm size $overrideSize }
    else { & $adbPath -s $Device shell wm size reset }
    if ($overrideDensity) { & $adbPath -s $Device shell wm density $overrideDensity }
    else { & $adbPath -s $Device shell wm density reset }
}
