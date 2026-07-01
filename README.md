# pearl-proxy

pearl-proxy 是一个 PRL / Pearl 矿池中转管理程序。矿机连接到 pearl-proxy 提供的本地监听端口，pearl-proxy 再连接真实矿池，并提供网页面板来管理矿池端口、钱包、fee、运行状态和服务重启。

当前版本：`0.0.2`

## 主要功能

- 一个程序管理多个矿池监听端口。
- 网页面板配置矿池、上游节点、监听端口和 fee。
- 支持每个监听端口单独设置 fee，留空时使用系统默认 fee。
- 支持一键创建已适配矿池端口。
- 支持 Windows 开机自启和后台守护。
- 支持 Linux systemd 开机自启、守护脚本和 `pp` 交互菜单。
- 支持在线矿工数、运行时间、端口健康状态、矿池列表和运行数据展示。
- 支持检查更新和一键更新。
- 支持 PRL 单挖，也支持部分矿池的 PRL + MDL 双挖。

## 支持的矿池和内核

| 矿池 | 推荐内核 | PRL 单挖 | PRL + MDL 双挖 |
| --- | --- | --- | --- |
| LuckyPool | SRBMiner-MULTI | 支持 | 支持 `PRL+MDL.worker` |
| HeroMiners | SRBMiner-MULTI | 支持 | 支持 `PRL+MDL.worker` |
| Kryptex | SRBMiner-MULTI | 支持 | 不支持 |
| 2Miners | SRBMiner-MULTI | 支持 | 不支持 |
| PearlFortune | TW pearl miner | 支持 | 需要矿池网页绑定 |
| AlphaPool | alpha-miner | 支持 | 支持 AlphaMiner 1.8.6+ 的 `PRL+MDL` 地址 |
| P 池 / pearlhash.xyz | WildRig | 支持 | 不支持 |

前端矿池卡片上出现“支持 PRL+MDL”标识时，表示该矿池支持钱包拼接双挖。当前会标识 LuckyPool、HeroMiners 和 AlphaPool。PearlFortune 的 MDL 需要在矿池网页绑定，不属于钱包拼接双挖。

已验证内核：

- SRBMiner-MULTI 3.4.2
- tw-pearl-miner 2.2.1
- alpha-miner 1.8.6
- WildRig 0.48.9

## 下载

请在 GitHub Releases 下载当前版本：

- Windows：`pearl-proxy-windows-amd64.zip`
- Linux：`pearl-proxy-linux-amd64`
- 校验文件：`SHA256SUMS.txt`

Windows 压缩包内包含：

- `pearl-proxy-windows-amd64.exe`
- `config.example.json`
- `install-windows-watchdog.ps1`
- `pearl-proxy-watchdog.ps1`
- `README-WINDOWS.txt`

Linux 发布文件通常包含：

- `pearl-proxy-linux-amd64`
- `install-linux.sh`
- `pearl-proxy-watchdog.sh`
- `pp.sh`
- `config.example.json`

## Windows 快速开始

1. 解压 `pearl-proxy-windows-amd64.zip`。
2. 以管理员身份打开 PowerShell。
3. 在解压目录运行：

```powershell
Set-ExecutionPolicy -Scope Process Bypass
.\install-windows-watchdog.ps1 -Action Install
```

安装脚本会：

- 复制程序到 `C:\ProgramData\pearl-proxy`
- 复制默认配置
- 创建开机自启任务
- 启动后台守护服务
- 打印前端面板地址

常用命令：

```powershell
.\install-windows-watchdog.ps1 -Action Status
.\install-windows-watchdog.ps1 -Action Restart
.\install-windows-watchdog.ps1 -Action Stop
.\install-windows-watchdog.ps1 -Action Start
.\install-windows-watchdog.ps1 -Action Uninstall
```

升级时直接用新压缩包再次运行安装命令即可。已有配置会继续复用 `C:\ProgramData\pearl-proxy\config.json`，除非手动加 `-Force`。

## Linux 快速开始

把这些文件放在同一个目录：

- `pearl-proxy-linux-amd64`
- `install-linux.sh`
- `pearl-proxy-watchdog.sh`
- `pp.sh`

运行：

```bash
chmod +x pearl-proxy-linux-amd64 install-linux.sh pearl-proxy-watchdog.sh pp.sh
./install-linux.sh --binary ./pearl-proxy-linux-amd64
```

安装脚本会交互询问：

- 安装目录，默认 `/opt/pearl-proxy`
- 管理面板端口
- 管理员账号
- 管理员密码
- 是否安装 systemd 服务

安装完成后，脚本会打印类似下面的地址：

```text
Open in browser: http://SERVER_IP:8080
```

Linux 安装后可以通过 SSH 输入：

```bash
pp
```

进入交互菜单。菜单包含状态查看、日志查看、启动、停止、重启、编辑配置、检查更新和一键更新。

## 使用面板

打开安装脚本打印的前端地址后，可以在面板中完成主要操作：

1. 点击“系统配置”，填写操作员 PRL 钱包、操作员 MDL 钱包和默认 fee。
2. 点击“新增端口”，选择矿池和节点，设置监听端口。
3. 也可以点击“一键创建所有矿池”，自动创建已适配矿池端口。
4. 保存配置。
5. 根据提示点击“重启此端口服务”或“重启全部端口服务”。

按钮含义：

- 重新读取配置：从磁盘重新读取 `config.json`。
- 保存：把当前面板配置写入 `config.json`。
- 重启此端口服务：只重启当前矿池监听端口。
- 重启全部端口服务：重启所有监听端口。
- 删除：删除当前监听端口，保存配置并释放该端口。

## 矿工连接方式

矿工连接 pearl-proxy 的监听端口，而不是直接连接矿池。

示例：

```text
服务器IP:监听端口
```

PRL 单挖钱包格式：

```text
PRL_ADDRESS.worker
```

PRL + MDL 双挖钱包格式：

```text
PRL_ADDRESS+MDL_ADDRESS.worker
```

如果矿池不支持钱包拼接双挖，使用 `PRL+MDL.worker` 会被矿池拒绝，请按面板里的矿池适配类型使用。

## 默认端口和默认 fee

默认配置中的监听端口从 `19360` 开始。你也可以在面板里改成任意未占用端口。

系统默认 fee 为 `1%`。每个监听端口可以单独设置 fee；端口 fee 留空时使用系统默认 fee。

## 更新

Linux：

```bash
pp
```

选择“检查更新”或“一键更新”。

Windows：

1. 下载新的 `pearl-proxy-windows-amd64.zip`。
2. 解压。
3. 以管理员身份运行：

```powershell
Set-ExecutionPolicy -Scope Process Bypass
.\install-windows-watchdog.ps1 -Action Install
```

已有配置默认保留。

## 常见问题

### 打不开面板

检查：

- 程序是否运行。
- 面板端口是否被防火墙放行。
- 地址是否使用了服务器真实 IP。
- Windows 是否以管理员身份安装了计划任务。

### 保存后为什么提示重启

监听端口、上游节点、钱包和 fee 变更需要重启对应端口服务后生效。面板会在保存后提示需要重启哪个服务。

### 删除端口后为什么还回来

删除端口会写入配置并释放端口。如果手动覆盖了旧配置，或者点击了“重新读取配置”读取到旧文件，端口可能重新出现。以磁盘上的 `config.json` 为准。

### 双挖没有生效

检查：

- 当前矿池是否支持钱包拼接双挖。
- 矿工钱包是否使用 `PRL_ADDRESS+MDL_ADDRESS.worker`。
- AlphaPool 是否使用 AlphaMiner 1.8.6 或更新版本。
- PearlFortune 的 MDL 需要在矿池网页绑定，不走钱包拼接。

## 完整说明

完整操作说明见：

- [USER_GUIDE.md](USER_GUIDE.md)
