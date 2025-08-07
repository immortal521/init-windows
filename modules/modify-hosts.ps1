# 目标 hosts 文件路径
$hostsPath = "$env:SystemRoot\System32\drivers\etc\hosts"

# GitHub hosts 内容
$githubHosts = @"
# GitHub 加速 hosts 开始
140.82.114.4    github.com
140.82.114.3    api.github.com
140.82.114.3    assets-cdn.github.com
# GitHub 加速 hosts 结束
"@

# 检查管理员权限
function Test-IsAdministrator {
    $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
    return $principal.IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
}

if (-not (Test-IsAdministrator)) {
    Write-Warning "请以管理员权限运行此脚本以修改 hosts 文件。"
    exit 1
}

# 读取 hosts 内容
try {
    $hostsContent = Get-Content -Path $hostsPath -Raw -ErrorAction Stop
}
catch {
    Write-Warning "读取 hosts 文件失败：$($_.Exception.Message)"
    exit 1
}

# 备份 hosts 文件（覆盖旧备份）
$backupPath = "$hostsPath.bak"
Copy-Item -Path $hostsPath -Destination $backupPath -Force
Write-Host "已备份原 hosts 文件到 $backupPath（自动覆盖旧备份）"

# 正则匹配 GitHub hosts 段
$pattern = "# GitHub 加速 hosts 开始[\s\S]*# GitHub 加速 hosts 结束"

if ([string]::IsNullOrWhiteSpace($hostsContent)) {
    # 如果文件为空，直接写入 GitHub hosts
    $hostsContentNew = $githubHosts
}
else {
    # 如果文件不为空，先去掉旧的 GitHub hosts 段，然后追加新的
    $hostsContentCleaned = [regex]::Replace($hostsContent, $pattern, "", [Text.RegularExpressions.RegexOptions]::IgnoreCase).TrimEnd()
    # 注意先去除末尾空白，再追加内容时加换行保证格式
    $hostsContentNew = $hostsContentCleaned + "`r`n`r`n" + $githubHosts
}

# 写入新内容
Set-Content -Path $hostsPath -Value $hostsContentNew -Encoding ASCII

Write-Host "hosts 文件已成功更新，GitHub 连接优化已生效。"

Read-Host -Prompt "脚本执行完毕，按回车退出"
