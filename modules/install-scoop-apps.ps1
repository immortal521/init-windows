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

Write-Host "正在克隆配置仓库到 $targetDir ..."
"$env:SCOOP\shims\git.exe" clone --recurse-submodules https://github.com/immortal521/config $targetDir

$homeDir = $env:USERPROFILE

# npm 相关路径变量
$npmGlobal = Join-Path $homeDir ".repo\npm\npm_global"
$npmCache = Join-Path $homeDir ".repo\npm\npm_cache"

# pnpm 相关路径变量
$pnpmGlobal = Join-Path $homeDir ".repo\pnpm\pnpm_global"
$pnpmBin = Join-Path $homeDir ".repo\pnpm\pnpm_global\bin"
$pnpmCache = Join-Path $homeDir ".repo\pnpm\pnpm_cache"
$pnpmStore = Join-Path $homeDir ".repo\pnpm\pnpm_store"
$pnpmState = Join-Path $homeDir ".repo\pnpm\pnpm_state"

# yarn 相关路径变量
$yarnGlobal = Join-Path $homeDir ".repo\yarn\yarn_global"
$yarnCache = Join-Path $homeDir ".repo\yarn\yarn_cache"

# 将所有路径放入一个数组中，以便于循环创建目录
$allPaths = @(
    $npmGlobal,
    $npmCache,
    $pnpmGlobal,
    $pnpmBin,
    $pnpmCache,
    $pnpmStore,
    $pnpmState,
    $yarnGlobal,
    $yarnCache
)

foreach ($path in $allPaths) {
    if (-not (Test-Path $path)) {
        Write-Host "创建目录：$path"
        New-Item -ItemType Directory -Path $path | Out-Null
    } else {
        Write-Host "目录已存在：$path"
    }
}
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
