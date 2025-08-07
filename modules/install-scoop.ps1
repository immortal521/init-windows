if (Get-Command scoop -ErrorAction SilentlyContinue) {
    Write-Host "Scoop 已经安装，跳过安装步骤。"
} else {
    Write-Host "正在安装 Scoop..."

    # 设置执行策略，允许执行远程脚本
    Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force

    # 下载并执行 Scoop 安装脚本
    Invoke-Expression (New-Object System.Net.WebClient).DownloadString('https://get.scoop.sh')

    # 验证是否安装成功
    if (Get-Command scoop -ErrorAction SilentlyContinue) {
        Write-Host "Scoop 安装成功！"
    } else {
        Write-Warning "Scoop 安装失败，请检查网络和权限。"
    }
}