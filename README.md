# pearl-proxy-release

Public release repository for pearl-proxy binaries.

Source code is kept in the private `heishiqing/pearl-proxy` repository.

## Current Release Candidate

Release candidate assets are published through GitHub Releases:

- `pearl-proxy-linux-amd64`
- `pearl-proxy-windows-amd64.exe`
- `SHA256SUMS.txt`

## Usage

Create a deployment config from the private source template, inject the project
dev wallet at build time, and run:

```bash
./pearl-proxy-linux-amd64 -config config.json
```

The dashboard endpoint and pool ports are controlled by `config.json`.

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
