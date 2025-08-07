[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$PSDefaultParameterValues['Out-File:Encoding'] = 'utf8'

$zipUrl = "https://github.com/immortal521/init-windows/archive/refs/heads/master.zip"
$tempDir = "$env:TEMP\gh-setup"
$zipPath = "$tempDir\scripts.zip"
$unzipPath = "$tempDir\unzipped"

# 确保临时目录存在
if (!(Test-Path $tempDir)) {
    New-Item -ItemType Directory -Path $tempDir | Out-Null
}

# 下载压缩包
Invoke-WebRequest -Uri $zipUrl -OutFile $zipPath

# 解压
Expand-Archive -LiteralPath $zipPath -DestinationPath $unzipPath -Force

# 执行主逻辑
$mainScript = Join-Path $unzipPath "init-windows-master\modules\main.ps1"
& $mainScript

# 清理
Remove-Item $tempDir -Recurse -Force
