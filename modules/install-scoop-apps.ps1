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

$home = $env:USERPROFILE

$dirs = @(
    @{ Name = "npm_global"; Path = Join-Path $home ".repo\npm\npm_global" },
    @{ Name = "npm_cache"; Path = Join-Path $home ".repo\npm\npm_cache" },
    @{ Name = "pnpm_global"; Path = Join-Path $home ".repo\pnpm\pnpm_global" },
    @{ Name = "pnpm_bin"; Path = Join-Path $home ".repo\pnpm\pnpm_global\bin" },
    @{ Name = "pnpm_cache"; Path = Join-Path $home ".repo\pnpm\pnpm_cache" },
    @{ Name = "pnpm_store"; Path = Join-Path $home ".repo\pnpm\pnpm_store" },
    @{ Name = "pnpm_state"; Path = Join-Path $home ".repo\pnpm\npm_state" },
    @{ Name = "yarn_global"; Path = Join-Path $home ".repo\yarn\yarn_global" },
    @{ Name = "yarn_cache"; Path = Join-Path $home ".repo\yarn\yarn_cache" }
)

foreach ($dir in $dirs) {
    if (-not (Test-Path $dir.Path)) {
        Write-Host "创建目录 [$($dir.Name)] 路径： $($dir.Path)"
        New-Item -ItemType Directory -Path $dir.Path | Out-Null
    } else {
        Write-Host "目录 [$($dir.Name)] 已存在，路径： $($dir.Path)"
    }
}

# npm 相关路径变量
$npmPrefix = $dirs | Where-Object { $_.Name -eq "npm_global" } | Select-Object -ExpandProperty Path
$npmCache = $dirs | Where-Object { $_.Name -eq "npm_cache" } | Select-Object -ExpandProperty Path

# pnpm 相关路径变量
$pnpmGlobal = $dirs | Where-Object { $_.Name -eq "pnpm_global" } | Select-Object -ExpandProperty Path
$pnpmBin = $dirs | Where-Object { $_.Name -eq "pnpm_bin" } | Select-Object -ExpandProperty Path
$pnpmCache = $dirs | Where-Object { $_.Name -eq "pnpm_cache" } | Select-Object -ExpandProperty Path
$pnpmStore = $dirs | Where-Object { $_.Name -eq "pnpm_store" } | Select-Object -ExpandProperty Path
$pnpmState = $dirs | Where-Object { $_.Name -eq "pnpm_state" } | Select-Object -ExpandProperty Path

# yarn 相关路径变量
$yarnGlobal = $dirs | Where-Object { $_.Name -eq "yarn_global" } | Select-Object -ExpandProperty Path
$yarnCache = $dirs | Where-Object { $_.Name -eq "yarn_cache" } | Select-Object -ExpandProperty Path

Write-Host "配置 npm ..."
npm config set registry https://registry.npmmirror.com/
npm config set prefix $npmPrefix
npm config set cache $npmCache

Write-Host "全局安装 pnpm 和 yarn ..."
npm install -g pnpm yarn

Write-Host "配置 yarn ..."
yarn config set global-folder $yarnGlobal
yarn config set cache-folder $yarnCache
yarn config set prefix $yarnGlobal

Write-Host "配置 pnpm ..."
pnpm config set global-bin-dir $pnpmBin
pnpm config set global-dir $pnpmGlobal
pnpm config set store-dir $pnpmStore
pnpm config set cache-dir $pnpmCache
pnpm config set state-dir $pnpmState

# 获取当前用户 PATH 环境变量
$currentPath = [Environment]::GetEnvironmentVariable("Path", "User")

# 要添加的路径，pnpm 的 bin 目录优先于 yarn 全局目录
$newPaths = @($pnpmBin, $yarnGlobal)

foreach ($p in $newPaths) {
    if (-not $currentPath.Split(';') -contains $p) {
        $currentPath = "$p;$currentPath"
        Write-Host "添加 $p 到 PATH"
    } else {
        Write-Host "$p 已在 PATH 中，跳过"
    }
}

# 设置新的 PATH
[Environment]::SetEnvironmentVariable("Path", $currentPath, "User")

Write-Host "所有操作完成！"
