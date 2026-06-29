# pearl-proxy-release

Public release repository for pearl-proxy binaries.

Source code is kept in the private `heishiqing/pearl-proxy` repository.

## Current Release Candidate

Release candidate assets are published through GitHub Releases:

- `pearl-proxy-linux-amd64`
- `pearl-proxy-windows-amd64.exe`
- `install-linux.sh`
- `SHA256SUMS.txt`

## Linux First-Time Install

Download `pearl-proxy-linux-amd64` and `install-linux.sh` from the release,
then run:

```bash
chmod +x pearl-proxy-linux-amd64 install-linux.sh
./install-linux.sh
```

The installer interactively sets the dashboard bind address, admin port, admin
user, and admin password. Pool, wallet, and fee settings can be changed later in
the web dashboard or by editing `config.json` on the server.

## Supported Profiles

- LuckyPool with SRBMiner
- HeroMiners with SRBMiner
- Kryptex with SRBMiner
- 2Miners with SRBMiner
- PearlFortune with tw-pearl-miner
- AlphaPool with alpha-miner
- P pool / pearlhash.xyz with WildRig PearlHash opaque mode

P-pool deployments require operator/dev opaque login frames generated with
`opaque-login-capture` from the private toolchain.
