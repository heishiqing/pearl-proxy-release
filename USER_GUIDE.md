# pearl-proxy 用户操作说明书

适用版本：`0.0.2`

本文档面向安装和使用 pearl-proxy 的用户，重点说明如何安装、打开前端、配置矿池端口、设置 fee、使用双挖、升级和排查问题。

## 1. 软件说明

pearl-proxy 是 PRL / Pearl 挖矿中转管理程序。矿工不直接连接矿池，而是连接 pearl-proxy 的监听端口。pearl-proxy 再连接真实矿池，并通过网页面板统一管理多个矿池端口。

典型结构：

```text
矿工内核 -> pearl-proxy 监听端口 -> 上游矿池节点
```

每个监听端口对应一个矿池节点。例如：

```text
19360 -> LuckyPool HK
19361 -> HeroMiners HK
19365 -> AlphaPool SG
```

## 2. 支持范围

### 2.1 支持矿池

| 矿池 | 协议类型 | 推荐内核 | MDL 双挖 |
| --- | --- | --- | --- |
| LuckyPool | 标准矿池 | SRBMiner-MULTI | 支持 |
| HeroMiners | 标准矿池 | SRBMiner-MULTI | 支持 |
| Kryptex | 标准矿池 | SRBMiner-MULTI | 不支持 |
| 2Miners | 标准矿池 | SRBMiner-MULTI | 不支持 |
| PearlFortune | TW 路径 | tw-pearl-miner | 需要网页绑定 |
| AlphaPool | Alpha 适配 | alpha-miner | 支持 |
| P 池 / pearlhash.xyz | WildRig opaque | WildRig | 不支持 |

面板里的矿池卡片如果显示“支持 PRL+MDL”，表示该矿池支持钱包拼接双挖。当前支持标识会出现在 LuckyPool、HeroMiners 和 AlphaPool。PearlFortune 需要在矿池网页绑定 MDL，不会显示这个钱包拼接双挖标识。

### 2.2 已验证内核

- SRBMiner-MULTI 3.4.2
- tw-pearl-miner 2.2.1
- alpha-miner 1.8.6
- WildRig 0.48.9

## 3. 下载文件说明

发布页通常包含这些文件：

```text
pearl-proxy-windows-amd64.zip
pearl-proxy-windows-amd64.exe
pearl-proxy-linux-amd64
install-linux.sh
pearl-proxy-watchdog.sh
pp.sh
config.example.json
SHA256SUMS.txt
```

Windows 用户下载：

```text
pearl-proxy-windows-amd64.zip
```

也可以只下载单文件：

```text
pearl-proxy-windows-amd64.exe
```

Linux 用户至少需要：

```text
pearl-proxy-linux-amd64
install-linux.sh
pearl-proxy-watchdog.sh
pp.sh
```

## 4. Windows 使用

Windows 端按普通软件使用即可，不需要 PowerShell，不需要复制配置文件。

1. 下载 `pearl-proxy-windows-amd64.exe`，或下载 zip 后解压。
2. 双击 `pearl-proxy-windows-amd64.exe`。
3. exe 会打开自己的 pearl-proxy 前端窗口。
4. 第一次打开时，窗口里会显示前端端口输入框，默认 `28180`。
5. 窗口里会显示两个访问地址：

```text
本机访问地址：http://127.0.0.1:28180
外部电脑访问：http://服务器IP:28180
```

后续矿池端口、钱包、fee、重启端口服务都在前端页面里操作。

首次运行会自动生成同目录下的 `config.json`。升级时把新 exe 放到原目录运行，旧配置会继续复用。

## 5. Linux 安装

### 5.1 首次安装

把下面文件放到服务器同一个目录：

```text
pearl-proxy-linux-amd64
install-linux.sh
pearl-proxy-watchdog.sh
pp.sh
```

运行：

```bash
chmod +x pearl-proxy-linux-amd64 install-linux.sh pearl-proxy-watchdog.sh pp.sh
./install-linux.sh --binary ./pearl-proxy-linux-amd64
```

安装脚本会询问：

- 安装目录，默认 `/opt/pearl-proxy`
- 管理面板端口，默认 `8080`
- 管理员账号
- 管理员密码
- 是否安装 systemd 服务

安装结束后会显示：

```text
Open in browser: http://SERVER_IP:PORT
```

### 5.2 Linux 管理菜单

安装后，在 SSH 中输入：

```bash
pp
```

菜单功能：

- 查看服务状态
- 查看实时日志
- 启动服务
- 停止服务
- 重启服务
- 编辑配置文件
- 检查 GitHub 更新
- 一键更新
- 显示面板地址

### 5.3 Linux systemd 命令

如果安装时启用了 systemd：

```bash
systemctl status pearl-proxy
systemctl restart pearl-proxy
systemctl stop pearl-proxy
journalctl -u pearl-proxy -f
```

默认目录：

```text
/opt/pearl-proxy
/opt/pearl-proxy/config.json
/opt/pearl-proxy/logs
```

## 6. 打开前端面板

安装脚本会打印前端地址。

如果忘记地址：

Windows：

双击 `pearl-proxy-windows-amd64.exe` 后，程序会打开自己的 pearl-proxy 前端窗口；默认地址是 `http://127.0.0.1:28180`。

Linux：

```bash
pp
```

或查看配置：

```text
dashboard.listen
```

如果配置是：

```json
"dashboard": {
  "listen": "0.0.0.0:8080"
}
```

浏览器打开：

```text
http://服务器IP:8080
```

## 7. 前端页面说明

### 7.1 总仪表盘

显示：

- 当前矿工数
- 运行时间
- 分支 accepted / rejected
- 已打开监听端口
- 矿池缩略数据

### 7.2 新增端口

用于创建一个矿池监听端口。

需要选择：

- 矿池
- 节点 / 端口
- 本地监听端口

保存后按提示重启对应端口服务。

### 7.3 一键创建所有矿池

在新增端口窗口中可以一键创建所有已适配矿池。

规则：

- 按亚洲、美洲、欧洲顺序选择节点。
- 已经存在的矿池不会重复创建。
- 监听端口使用高位未占用端口。
- fee 使用系统默认 fee。
- 创建后需要确认并重启生成的端口服务。

### 7.4 系统配置

可设置：

- 操作员 PRL 钱包
- 操作员 MDL 钱包
- 默认 fee 率
- 管理面板监听地址
- 管理员账号
- 管理员密码
- 安全限制

默认 fee 为 `1%`。

### 7.5 矿池列表

显示所有已配置的矿池端口。

点击矿池卡片后，会打开配置窗口，可修改：

- 名称
- 监听端口
- 上游矿池节点
- 该端口 fee
- 协议适配类型

修改后保存，并按提示重启端口服务。

### 7.6 在线矿工

显示当前连接中的矿工数量和连接状态。

## 8. fee 设置

### 8.1 默认 fee

系统配置中的默认 fee 作用于所有未单独设置 fee 的端口。

默认值：

```text
1%
```

### 8.2 单端口 fee

每个监听端口都可以单独设置 fee。

如果端口 fee 留空：

```text
使用系统默认 fee
```

如果端口 fee 填写数值：

```text
仅该端口使用这个 fee
```

### 8.3 保存后为什么要重启

监听端口、上游节点、钱包、fee 等变更都需要重启端口服务后生效。

面板会根据修改范围提示：

- 重启此端口服务
- 重启全部端口服务

## 9. 矿工连接方式

矿工连接 pearl-proxy 的服务器 IP 和监听端口。

示例：

```text
45.200.49.80:19360
```

### 9.1 PRL 单挖

钱包格式：

```text
PRL_ADDRESS.worker
```

### 9.2 PRL + MDL 双挖

支持钱包拼接双挖的矿池使用：

```text
PRL_ADDRESS+MDL_ADDRESS.worker
```

示例：

```text
prl1xxxx+mdl1yyyy.rig01
```

注意：

- LuckyPool 支持。
- HeroMiners 支持。
- AlphaPool 需要 alpha-miner 1.8.6 或更新版本。
- Kryptex 和 2Miners 不支持钱包拼接双挖。
- PearlFortune 需要在矿池网页绑定 MDL，不使用 `PRL+MDL.worker`。

在总仪表盘和矿池列表中，支持钱包拼接双挖的卡片会显示“支持 PRL+MDL”徽标，方便区分单挖矿池和双挖矿池。

## 10. 支持的默认矿池端口

默认配置通常从 `19360` 开始：

| 默认端口 | 矿池 |
| --- | --- |
| 19360 | LuckyPool |
| 19361 | HeroMiners |
| 19362 | Kryptex |
| 19363 | 2Miners |
| 19364 | PearlFortune |
| 19365 | AlphaPool |
| 19366 | P 池 / pearlhash.xyz |

可以在前端修改端口。创建端口时程序会检查端口占用，避免冲突。

## 11. 更新

### 11.1 Linux 更新

运行：

```bash
pp
```

选择：

```text
检查更新
```

或：

```text
一键更新
```

更新会尽量保留现有配置。

### 11.2 Windows 更新

关闭正在运行的旧程序，把新版 `pearl-proxy-windows-amd64.exe` 放到原目录，再双击启动。

同目录下的 `config.json` 会继续复用。

## 12. 日志

### 12.1 Windows 日志

普通双击运行时，日志显示在程序窗口里。排查问题时不要先关闭窗口，直接查看窗口里最后几行错误。

### 12.2 Linux 日志

```text
/opt/pearl-proxy/logs
```

或：

```bash
journalctl -u pearl-proxy -f
```

## 13. 常见问题

### 13.1 面板打不开

检查：

- 服务是否已启动。
- 防火墙是否放行面板端口。
- 是否使用了正确服务器 IP。
- 管理面板是否监听 `127.0.0.1`。如果是，只能本机访问。
- Windows 是否用管理员权限安装。

### 13.2 矿工连不上

检查：

- 矿工连接的是 pearl-proxy 的监听端口。
- 监听端口是否被防火墙放行。
- 端口是否已经启动。
- 上游矿池节点是否健康。
- 钱包格式是否正确。

### 13.3 保存配置后没有变化

保存只是写入配置文件。监听端口、上游、钱包、fee 等变更需要重启服务。

在面板中点击：

```text
重启此端口服务
```

或：

```text
重启全部端口服务
```

### 13.4 删除端口后又出现

以磁盘上的 `config.json` 为准。

如果删除后没有保存成功，或者重新读取了旧配置，端口会回来。删除端口后正常会自动保存并释放端口。

### 13.5 双挖 rejected

优先检查：

- 当前矿池是否支持 `PRL+MDL.worker`。
- 钱包中间是否是英文 `+`。
- worker 名是否放在最后。
- AlphaPool 是否使用 alpha-miner 1.8.6+。
- PearlFortune 是否已在矿池网页绑定 MDL。

### 13.6 配置文件手动编辑后启动失败

检查 JSON 格式。

常见问题：

- 少了逗号。
- 多了注释。
- 引号不完整。
- 端口写成了已占用端口。

从 `0.0.2` 起，程序可读取带 UTF-8 BOM 的配置文件。

## 14. 配置文件位置

Windows：

```text
exe 同目录\config.json
```

Linux：

```text
/opt/pearl-proxy/config.json
```

## 15. 发布前检查清单

发布或升级前建议确认：

- 已备份 `config.json`。
- 新版本 SHA256 校验正确。
- 面板可以打开。
- 端口没有冲突。
- 至少一个矿工能连接并产生 accepted。
- 修改 fee 或上游后已重启对应端口服务。
