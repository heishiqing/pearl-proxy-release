# pearl-proxy 用户操作说明

适用版本：`0.0.2`

本文面向安装和使用 pearl-proxy 的用户，说明如何安装、打开前端、创建矿池端口、配置钱包和费率、使用 PRL+MDL 双挖、升级和排查常见问题。

## 1. 软件用途

pearl-proxy 是 PRL / Pearl 矿池中转管理程序。矿工内核连接 pearl-proxy 的监听端口，pearl-proxy 再连接真实矿池。

典型结构：

```text
矿工内核 -> pearl-proxy 监听端口 -> 上游矿池节点
```

一个监听端口对应一个矿池节点。例如：

```text
39000 -> LuckyPool HK
39001 -> HeroMiners HK
39006 -> PearlHash TCP
```

## 2. 支持范围

### 2.1 支持矿池

| 矿池 | 推荐内核 | PRL 单挖 | PRL+MDL 双挖 | 备注 |
| --- | --- | --- | --- | --- |
| LuckyPool | SRBMiner-MULTI | 支持 | 支持 | 使用 `PRL+MDL.worker` |
| HeroMiners | SRBMiner-MULTI | 支持 | 支持 | 使用 `PRL+MDL.worker` |
| AlphaPool | alpha-miner | 支持 | 支持 | 使用 AlphaMiner 1.8.6+ |
| F2Pool 鱼池 | SRBMiner-MULTI / TW pearl miner | 支持 | 不支持 | 账号模式 |
| Kryptex | SRBMiner-MULTI | 支持 | 不支持 | 适配账号/钱包差异 |
| 2Miners | SRBMiner-MULTI | 支持 | 不支持 | 标准矿池 |
| PearlFortune | tw-pearl-miner | 支持 | 需矿池网页绑定 | 不使用钱包拼接 |
| PearlHash / pearlhash.xyz | WildRig | 支持 | 不支持 | PearlHash 适配 |

前端卡片显示“支持 PRL+MDL”时，表示该矿池支持钱包拼接双挖。没有该标记的矿池请按 PRL 单挖或对应矿池账号模式使用。

### 2.2 已验证内核

- SRBMiner-MULTI 3.4.x
- tw-pearl-miner 2.x
- alpha-miner 1.8.6+
- WildRig 0.48.x

## 3. Windows 安装

Windows 版本按普通软件使用即可。

1. 下载 `pearl-proxy-windows-amd64.zip`。
2. 解压到一个固定目录。
3. 双击 `pearl-proxy-windows-amd64.exe`。
4. 程序会打开自己的前端窗口。
5. 前端端口默认 `28180`。

本机浏览器访问：

```text
http://127.0.0.1:28180
```

外部电脑访问：

```text
http://服务器IP:28180
```

首次运行会自动生成 `config.json`。升级时关闭旧程序，把新 exe 放到原目录，再双击运行即可。

## 4. Linux 安装

上传并解压：

```bash
tar -xzf pearl-proxy-linux-amd64.tar.gz
cd linux-bundle-0.0.2
```

运行安装：

```bash
chmod +x pearl-proxy-linux-amd64 install-linux.sh pearl-proxy-watchdog.sh pp.sh
./install-linux.sh --binary ./pearl-proxy-linux-amd64
```

安装脚本会询问：

- 安装目录，默认 `/opt/pearl-proxy`
- 前端端口
- 管理员账号，默认 `admin`
- 管理员密码
- 是否安装 systemd 服务

安装完成后会显示访问地址：

```text
Open in browser: http://服务器IP:端口
```

## 5. Linux 交互菜单

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
- 显示前端访问地址

## 6. 前端页面使用

### 6.1 总仪表盘

总仪表盘显示：

- 当前矿工数
- 运行时间
- 接受份额
- 拒绝份额
- 已打开的监听端口概览
- 每个矿池的在线矿工数和健康状态

### 6.2 系统配置

系统配置用于填写全局参数，例如：

- 操作员 PRL 钱包
- 操作员 MDL 钱包
- 默认费率
- 前端监听地址
- 管理员账号和密码
- 安全限制参数

系统默认费率用于新建端口。每个端口也可以单独设置费率。

### 6.3 新增端口

点击“新增端口”后：

1. 选择矿池。
2. 选择节点。
3. 填写监听端口。
4. 点击添加。
5. 根据提示重启此端口服务。

程序会检查端口是否已被占用，避免冲突。

### 6.4 一键创建所有矿池

“一键创建所有矿池”会自动为已适配矿池创建监听端口。

规则：

- 已经存在的矿池不会重复创建。
- 端口使用高位未占用端口。
- 节点优先按亚洲、美洲、欧洲顺序选择。
- 费率使用系统默认费率。
- 创建完成后按提示重启生成的端口服务。

### 6.5 矿池列表

矿池列表展示已配置的监听端口。点击矿池卡片可查看或修改该端口配置。

卡片内容包括：

- 矿池名称和节点缩写
- 在线矿工数
- 监听端口
- 健康状态
- 费率
- 是否支持 PRL+MDL

## 7. 钱包和账号格式

### 7.1 标准 PRL 单挖

```text
PRL_ADDRESS.worker
```

### 7.2 PRL+MDL 双挖

仅用于前端标记“支持 PRL+MDL”的矿池：

```text
PRL_ADDRESS+MDL_ADDRESS.worker
```

如果矿池不支持钱包拼接双挖，使用这种格式可能会被矿池拒绝。

### 7.3 账号模式矿池

F2Pool 鱼池等账号模式矿池使用矿池账号或 `账号.worker`。请在前端系统配置中填写对应账号设置，不要和普通 PRL 钱包模式混用。

## 8. 矿工连接示例

假设服务器 IP 是 `1.2.3.4`，前端创建的监听端口是 `39000`。

矿工连接地址：

```text
1.2.3.4:39000
```

钱包或账号填写方式按矿池类型决定：

```text
PRL_ADDRESS.worker
PRL_ADDRESS+MDL_ADDRESS.worker
account.worker
```

## 9. 费率规则

操作员 fee 最高可设置为 `20%`。系统会根据操作员 fee 自动计算 dev fee：

| operator fee | dev fee |
| --- | --- |
| 0% - 0.99% | 0.5% |
| 1% - 2.99% | 1% |
| 3% - 4.99% | 2% |
| 5% - 9.99% | 3% |
| 10% - 20% | 5% |

系统默认费率用于新建端口。每个监听端口也可以单独设置 fee，端口 fee 留空时使用系统默认 fee。

## 10. 更新

### Windows

1. 下载新的 `pearl-proxy-windows-amd64.zip`。
2. 关闭旧程序。
3. 解压新 exe 到原目录。
4. 双击运行。

原来的 `config.json` 会继续复用。

### Linux

SSH 输入：

```bash
pp
```

选择“检查更新”或“一键更新”。

## 11. 常见问题

### 前端打不开

检查：

- 程序是否正在运行。
- 前端端口是否被防火墙放行。
- 外部电脑访问时是否使用服务器真实 IP。
- 端口是否被其他程序占用。

### 保存后为什么提示重启

监听端口、上游节点、钱包、账号或费率变更后，需要重启对应端口服务才会生效。

### 删除端口后为什么还出现

删除端口会自动保存配置并释放端口。如果重新读取到了旧配置，端口可能重新出现。请确认正在使用的 `config.json` 是最新文件。

### 矿池卡片为什么显示“不支持 PRL+MDL”

表示该矿池不支持钱包拼接双挖，或需要在矿池网页中单独绑定。请按该矿池的普通 PRL 单挖或账号模式使用。

### 端口创建失败

常见原因：

- 端口已被占用。
- 端口被防火墙拦截。
- 监听地址填写错误。
- 没有权限监听该端口。

### 份额被拒绝

常见原因：

- 钱包或账号格式错误。
- 使用了矿池不支持的双挖格式。
- 矿池难度变化导致 stale。
- 网络延迟过高。
- 矿池节点临时异常。

可以先更换同矿池其他节点，或查看前端中的端口健康状态。
