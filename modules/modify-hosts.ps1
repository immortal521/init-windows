# 目标 hosts 文件路径
$hostsPath = "$env:SystemRoot\System32\drivers\etc\hosts"

# 你想添加的 GitHub 相关 hosts 内容
$githubHosts = @"
# GitHub 加速 hosts 开始
140.82.114.4    github.com
140.82.114.3    api.github.com
140.82.114.3    assets-cdn.github.com
# GitHub 加速 hosts 结束
"@

# 以管理员权限执行此脚本
function Test-IsAdministrator {
    $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
    return $principal.IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
}

if (-not (Is-Administrator)) {
    Write-Warning "请以管理员权限运行此脚本以修改 hosts 文件。"
    exit 1
}

# 读取原hosts内容
$hostsContent = Get-Content -Path $hostsPath -Raw

# 移除旧的 GitHub hosts 段（如果存在）
$pattern = "# GitHub 加速 hosts 开始[\s\S]*# GitHub 加速 hosts 结束"
$hostsContentCleaned = [regex]::Replace($hostsContent, $pattern, "", [Text.RegularExpressions.RegexOptions]::IgnoreCase).Trim()

# 添加新的 GitHub hosts 内容
$hostsContentNew = $hostsContentCleaned + "`r`n`r`n" + $githubHosts

# 备份原 hosts 文件
$backupPath = "$hostsPath.bak_$(Get-Date -Format 'yyyyMMddHHmmss')"
Copy-Item -Path $hostsPath -Destination $backupPath -Force
Write-Host "已备份原 hosts 文件到 $backupPath"

# 写入新内容
Set-Content -Path $hostsPath -Value $hostsContentNew -Encoding ASCII

Write-Host "hosts 文件已成功更新，GitHub 连接优化已生效。"
