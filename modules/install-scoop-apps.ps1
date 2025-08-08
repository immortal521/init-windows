# 确保 Scoop 已安装
if (-not (Get-Command scoop -ErrorAction SilentlyContinue)) {
    Write-Warning "Scoop 未安装，请先安装 Scoop。"
    exit 1
}

# 1. 安装基础依赖
$baseApps = @("git", "7zip", "aria2")
foreach ($app in $baseApps) {
    if (-not (scoop list | Select-String "^$app")) {
        Write-Host "安装 $app ..."
        scoop install $app
    }
    else {
        Write-Host "$app 已安装，跳过。"
    }
}

$scoopConfigs = @{
    "aria2-enabled"         = "true"
    "aria2-warning-enabled" = "false"
    "scoop_repo"            = "https://github.com/ScoopInstaller/Scoop"
    "scoop_branch"          = "master"
    "proxy"                 = "localhost:10808"
}

foreach ($key in $scoopConfigs.Keys) {
    $value = $scoopConfigs[$key]
    Write-Host "设置 Scoop 配置 $key = $value"
    scoop config $key $value
}

# 2. 确保 bucket 已添加
$bucketsToAdd = @{
    "main"         = "https://github.com/ScoopInstaller/Main"
    "extras"       = "https://github.com/ScoopInstaller/Extras"
    "nonportable"  = "https://github.com/ScoopInstaller/Nonportable"
    "java"         = "https://github.com/ScoopInstaller/Java"
    "dorado"       = "https://github.com/chawyehsu/dorado"
    "ImmortBucket" = "https://github.com/immortal521/ImmortBucket"
}

# 获取当前已添加的 bucket 列表
$currentBuckets = scoop bucket list | Select-Object -Skip 1 | ForEach-Object { ($_ -split "\s+")[0] }

foreach ($bucketName in $bucketsToAdd.Keys) {
    if ($currentBuckets -notcontains $bucketName) {
        Write-Host "添加 bucket $bucketName ..."
        scoop bucket add $bucketName $bucketsToAdd[$bucketName]
    }
    else {
        Write-Host "bucket $bucketName 已存在，跳过。"
    }
}

# 3. 安装你想要的应用（示例）
$appList = @(
    "7ztm",
    "adb",
    "apifox",
    "bottom",
    "bun",
    "cmake",
    "curl",
    "dark",
    "fastfetch",
    "fd",
    "ffmpeg",
    "file",
    "fzf",
    "gcc",
    "gdb",
    "gdu",
    "ghostscript",
    "go",
    "gradle",
    "gzip",
    "icaros-np",
    "iconview",
    "imagemagick",
    "inkscape",
    "innounp",
    "jq",
    "lazygit",
    "localsend",
    "lua",
    "luarocks",
    "make",
    "maven",
    "minio",
    "minio-client",
    "mpv",
    "msys2",
    "music-player",
    "mysql",
    "neovide",
    "neovim",
    "nginx",
    "nodejs",
    "nu",
    "oh-my-posh",
    "ollama-full",
    "openjdk17",
    "poppler",
    "protobuf",
    "psutils",
    "putty",
    "python",
    "redis",
    "resource-hacker",
    "ripgrep",
    "rustup",
    "sqlite",
    "sqlitespy",
    "starship",
    "telnet",
    "tree-sitter",
    "vscode",
    "wezterm",
    "yazi",
    "yt-dlp",
    "zoxide"
)

foreach ($app in $appList) {
    if (-not (scoop list | Select-String "^$app")) {
        Write-Host "安装应用 $app ..."
        scoop install $app
    }
    else {
        Write-Host "应用 $app 已安装，跳过。"
    }
}

$targetDir = "$env:USERPROFILE\.config"

if (-Not (Test-Path $targetDir)) {
    Write-Host "正在克隆配置仓库到 $targetDir ..."
    git clone --recurse-submodules https://github.com/immortal521/config $targetDir
} else {
    Write-Host "$targetDir 已存在，跳过克隆。"
}

Write-Host "所有操作完成！"
