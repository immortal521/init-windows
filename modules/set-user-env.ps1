Write-Host "设置用户环境变量..."
# 获取当前用户名
$username = [Environment]::UserName

# 定义环境变量键值对
$envVars = @{
    "SCOOP"            = "C:\Apps\Scoop"
    "STARSHIP_CONFIG"  = "C:\Users\$username\.config\starship\starship.toml"
    "XDG_CONFIG_HOME"  = "C:\Users\$username\.config"
    "YAZI_CONFIG_HOME" = "C:\Users\$username\.config\yazi"
}

foreach ($key in $envVars.Keys) {
    $value = $envVars[$key]

    # 设置用户级环境变量（注册表）
    [Environment]::SetEnvironmentVariable($key, $value, [EnvironmentVariableTarget]::User)

    # 设置当前 PowerShell 会话变量（兼容语法）
    Set-Item -Path "Env:$key" -Value $value

    Write-Host "已设置环境变量 $key = $value（当前会话 + 用户注册表）"
}

Write-Host "`所有变量已设置完毕。"
