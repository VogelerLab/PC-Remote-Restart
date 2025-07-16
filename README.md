# PC-Remote-Restart

This repo houses references and a guide for how to remotely restart workstations in the Vogeler Lab at NREL.

## GUIDE

### 1. Setup AMT

TODO

### 2. Install MeshCentral

[MeshCentral](https://github.com/Ylianst/MeshCentral) is software that allows for remote control of compatible and correctly configured hardware. It can be run in a Docker (Podman) container, which is the route this guide will take.

TODO add instructions for installing podman on Windows

Create container:

```sh
podman create --name meshcentral --interactive --tty --port 8888:80 --port 4444:443 --port 4433:4433 --restart unless-stopped ghcr.io/vogelerlab/remote-restart:latest
```

Port 8888 (on host running the container) will be avilable for HTTP connection to MeshCentral, port 4433 for HTTPS connection, and port 4433 will be used by MeshCentral to send AMT (power control) commands to other PCs.

Run container:

```sh
podman start meshcentral
```

### 3. Configure MeshCentral

TODO
```
https://localhost:4444/

*Create account

*click here to create a device group
  Name: main (doesn't matter)
  Type: Intel AMT only, no agent
  *OK
*Scan Network
  IP Range: <HOST-IP>
  *Scan
  *Select All
  *OK
- Click machine entry
- Click "Intel AMT" tab
- If prompted, enter AMT password
- Click "Power Actions..." button
- Select desired Power Action, then click "OK"
```
