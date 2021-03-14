# dex

## Init project

After clone repo please also install git submodule with smart contracts

```bash
git submodule init
git submodule update
```

## DEV setup

```bash
docker-compose up
```

### Login inside container

```bash
 docker-compose exec node /bin/bash
```

### Install deps

```bash
npm i
```

### Deploy TIP3

```bash
node deployTIP3.js
```

### Works with TONOS-CLI

Tonos-cli exists in node container

```bash
tonos-cli
```

### Access compilers

```bash
docker-compose exec compiler /bin/bash
```
