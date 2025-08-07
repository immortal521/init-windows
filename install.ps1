$zipUrl = "https://github.com/immortal521/init-windows/archive/refs/heads/master.zip"
$tempDir = "$env:TEMP\gh-setup"
$zipPath = "$tempDir\scripts.zip"

# 确保临时目录存在
if (!(Test-Path $tempDir)) {
    New-Item -ItemType Directory -Path $tempDir | Out-Null
}

# 下载压缩包
Invoke-WebRequest -Uri $zipUrl -OutFile $zipPath

# 解压
Expand-Archive -LiteralPath $zipPath -DestinationPath $tempDir -Force

# 执行主逻辑（普通权限）
& "$tempDir\modules\main.ps1"

# 清理
Remove-Item $tempDir -Recurse -Force
