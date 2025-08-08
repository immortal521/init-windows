[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$PSDefaultParameterValues['Out-File:Encoding'] = 'utf8'

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

# 设置用户环境变量
$setUserEnvScript = Join-Path $scriptDir "set-user-env.ps1"
& $setUserEnvScript

# 安装 scoop（普通权限即可）
$installScoopScript = Join-Path $scriptDir "install-scoop.ps1"
& $installScoopScript

$installAppsScript = Join-Path $scriptDir "install-scoop-apps.ps1"
& $installAppsScript

