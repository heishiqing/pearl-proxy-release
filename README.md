# pearl-proxy

pearl-proxy 是一个 PRL / Pearl 矿池中转管理程序。矿机连接到 pearl-proxy 的监听端口，pearl-proxy 再连接真实矿池，并通过前端页面统一管理矿池端口、上游节点、钱包、费率、在线矿工和运行状态。

当前版本：`0.0.2`

## 下载

请到 GitHub Releases 下载：

- Windows：`pearl-proxy-windows-amd64.zip`
- Linux：`pearl-proxy-linux-amd64.tar.gz`

普通用户只需要下载对应系统的一个压缩包。

## Windows 快速开始

Windows 不需要 PowerShell，不需要手动复制配置文件。

1. 下载 `pearl-proxy-windows-amd64.zip` 并解压。
2. 双击 `pearl-proxy-windows-amd64.exe`。
3. 程序会打开自己的前端窗口。
4. 前端端口默认是 `28180`。
5. 在前端里配置矿池、监听端口、钱包和费率。

本机访问：

```text
http://127.0.0.1:28180
```

外部电脑访问：

```text
http://服务器IP:28180
```

首次运行会自动生成 `config.json`。升级时把新 exe 放到原目录运行，旧配置会继续复用。

## Linux 快速开始

上传并解压：

```bash
tar -xzf pearl-proxy-linux-amd64.tar.gz
cd linux-bundle-0.0.2
```

安装：

```bash
chmod +x pearl-proxy-linux-amd64 install-linux.sh pearl-proxy-watchdog.sh pp.sh
./install-linux.sh --binary ./pearl-proxy-linux-amd64
```

安装脚本会提示填写：

- 安装目录，默认 `/opt/pearl-proxy`
- 前端端口
- 管理员账号，默认 `admin`
- 管理员密码
- 是否安装 systemd 服务

安装完成后，脚本会显示前端访问地址，例如：

```text
Open in browser: http://服务器IP:28180
```

安装后可在 SSH 中输入：

```bash
pp
```

打开交互菜单。菜单支持查看状态、查看日志、启动、停止、重启、编辑配置、检查更新和一键更新。

## 主要功能

- 一个程序管理多个矿池监听端口。
- 前端页面创建、删除、重启矿池端口。
- 每个监听端口可单独设置费率，留空时使用系统默认费率。
- 一键创建已适配矿池端口。
- 显示总仪表盘、在线矿工、矿池列表和端口健康状态。
- Linux 支持 systemd 开机启动和 `pp` 交互菜单。
- 支持检查更新和一键更新。
- 支持 PRL 单挖，部分矿池支持 PRL+MDL 双挖。

## 费率规则

操作员 fee 最高可设置为 `20%`。系统会根据操作员 fee 自动计算 dev fee：

| operator fee | dev fee |
| --- | --- |
| 0% - 0.99% | 0.5% |
| 1% - 2.99% | 1% |
| 3% - 4.99% | 2% |
| 5% - 9.99% | 3% |
| 10% - 20% | 5% |

## 支持矿池

| 矿池 | 推荐内核 | PRL 单挖 | PRL+MDL 双挖 | 备注 |
| --- | --- | --- | --- | --- |
| LuckyPool | SRBMiner-MULTI | 支持 | 支持 | 使用 `PRL+MDL.worker` |
| HeroMiners | SRBMiner-MULTI | 支持 | 支持 | 使用 `PRL+MDL.worker` |
| AlphaPool | alpha-miner | 支持 | 支持 | 使用 AlphaMiner 1.8.6+ |
| F2Pool 鱼池 | SRBMiner-MULTI / TW pearl miner | 支持 | 不支持 | 账号模式 |
| Kryptex | SRBMiner-MULTI | 支持 | 不支持 | 适配账号/钱包差异 |
| 2Miners | SRBMiner-MULTI | 支持 | 不支持 | 标准矿池 |
| PearlFortune | TW pearl miner | 支持 | 需矿池网页绑定 | 不使用钱包拼接 |
| PearlHash / pearlhash.xyz | WildRig | 支持 | 不支持 | PearlHash 适配 |

前端矿池卡片显示“支持 PRL+MDL”时，表示该矿池支持钱包拼接双挖。没有该标记的矿池请按 PRL 单挖或对应矿池账号模式使用。

已验证内核：

- SRBMiner-MULTI 3.4.x
- tw-pearl-miner 2.x
- alpha-miner 1.8.6+
- WildRig 0.48.x

## 矿工连接方式

矿工连接 pearl-proxy 的监听端口，而不是直接连接矿池：

```text
服务器IP:监听端口
```

PRL 单挖钱包格式：

```text
PRL_ADDRESS.worker
```

PRL+MDL 双挖钱包格式：

```text
PRL_ADDRESS+MDL_ADDRESS.worker
```

账号模式矿池，例如 F2Pool 鱼池，请使用矿池账号或 `账号.worker`，并在前端系统配置里填写对应账号设置。

## 更新

Windows：

1. 下载新的 `pearl-proxy-windows-amd64.zip`。
2. 关闭旧程序。
3. 解压新 exe 到原目录。
4. 双击运行，原 `config.json` 会继续复用。

Linux：

```bash
pp
```

选择“检查更新”或“一键更新”。

## 常见问题

### 打不开前端

检查程序是否正在运行、前端端口是否被防火墙放行、地址是否使用了正确的服务器 IP。

### 保存后为什么提示重启端口

监听端口、上游节点、钱包和费率变更后，需要重启对应端口服务才会生效。前端会提示需要重启哪个端口。

### 删除端口后为什么还显示

删除端口会自动保存配置并释放端口。如果手动覆盖了旧配置，或重新读取了旧的 `config.json`，端口可能重新出现。以磁盘上的 `config.json` 为准。

### 双挖没有生效

确认当前矿池是否显示“支持 PRL+MDL”，并确认矿工钱包是否使用 `PRL_ADDRESS+MDL_ADDRESS.worker` 格式。

## 完整说明

更多细节见：[USER_GUIDE.md](USER_GUIDE.md)
