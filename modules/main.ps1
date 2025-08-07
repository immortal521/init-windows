[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$PSDefaultParameterValues['Out-File:Encoding'] = 'utf8'

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

# 修改 hosts（需要管理员权限）
$modifyHostsScript = Join-Path $scriptDir "modify-hosts.ps1"

# 检查当前权限，如果不是管理员，则重新以管理员权限执行 modify-hosts.ps1
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltinRole] "Administrator")) {
    Write-Host "当前不是管理员，尝试以管理员权限运行修改hosts脚本..."
    Start-Process -FilePath "powershell.exe" -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$modifyHostsScript`"" -Verb RunAs -Wait
}
else {
    # 已是管理员，直接执行
    & $modifyHostsScript
}

# 设置用户环境变量
$setUserEnvScript = Join-Path $scriptDir "set-user-env.ps1"
& $setUserEnvScript

# 安装 scoop（普通权限即可）
$installScoopScript = Join-Path $scriptDir "install-scoop.ps1"
& $installScoopScript
