# PC-Remote-Restart

This repo houses references and a guide for how to remotely restart workstations in the Vogeler Lab at NREL.

## GUIDE

### 1. Setup AMT on clients (machines you want to remotely control)

This section of the guide will focus on how to enable AMT on relatively recent releases of enterprise HP workstations.

- Bring up the Startup Menu (for many HP workstations, this menu is accessed by powering on the machine and repeatedly pressing ESC or F10)
- Select "BIOS Setup"
- Go to the "Advanced" tab
- Select "Remote Management Options"
- Check the "Intel Active Management Technology (AMT)" box
- Exit BIOS and save changes
- Wait for the machine to finish power cycling several times (I believe this is it enabling features)
- After the machine fully boots, shut it down
- Bring up the Startup Menu again
- There will be a new entry now that says "ME Setup" (select it)
- Enter the current Intel ME Password, which is "admin", then set a new password
- Under "Redirection features", make sure "SOL" and "Storage Redirection" are disabled
- Under "User Consent" set "User Opt-in" to "ALL"
- "Network Access State" should be "Active"
- Exit and save changes

---

### 2. Setup and Use MeshCentral Server Host (machine you will use to control the clients)

#### 2.1 Install MeshCentral on Windows 11 host

[MeshCentral](https://github.com/Ylianst/MeshCentral) is software that allows for remote control of compatible and correctly configured hardware. It can be run in a Docker (Podman) container, which is the route this guide will take.

Create container:

```powershell
# PowerShell
winget install podman
# **REBOOT MACHINE**
podman machine init
podman machine start
podman create --name meshcentral --interactive --tty --publish 8888:80 --publish 4444:443 --publish 4433:4433 --restart unless-stopped ghcr.io/vogelerlab/remote-restart:latest
```

Port 8888 (on host running the container) will be available for HTTP connection to MeshCentral, port 4444 for HTTPS connection, and port 4433 will be used by MeshCentral to send AMT (power control) commands to other PCs.

Run container:

```powershell
podman start meshcentral
```

NOTE: If you run into issues installing/using MeshCentral via containers, you can install MeshCentral directly on the Windows host using the installer found on the MeshCentral website. In that case, simply replace 'https://localhost:4444/' with 'https://localhost:443/' for the remainder of this guide.

#### 2.2 List Client IP Addresses

Ping the DNS name of the clients (Windows PCs you want to perform out-of-band management on) to get their IP addresses:

```powershell
'HOSTNAME1','HOSTNAME2','HOSTNAME3' | ForEach-Object { Resolve-DnsName -Name "$_" -ErrorAction SilentlyContinue }
# Replace HOSTNAME1, etc... with the machines' hostnames
```

NOTE: In order for MeshCentral to control the client, it must be on the same subnet as the MeshCentral server. Given IP address of format `AAA.BBB.CCC.DDD`, two machines are on the same subnet if the `AAA.BBB.CCC.` part of their IP addresses match.

#### 2.3 Configure MeshCentral

- Go to https://localhost:4444/
- Click "Create account" and then create one

#### 2.4 Add a Client

NOTE: The computer running MeshCentral and the remote running AMT must be on same subnet in order to see eachother.

- Go to https://localhost:4444/ and login (if not done already)
- Click "click here to create a device group", then enter:
  - Name: main (doesn't matter)
  - Type: Intel AMT only, no agent
  - Click "OK"
- Click "Scan Network" and enter the IP address of the Windows computer you want to control into the "IP Range" box, then click "Scan"
- Click "Select All"
- Click "OK"
- Click on the new machine entry
- Click on the little blue pencil next to the entry's title and set a memorable name
- Click "Intel AMT" tab
- Click the "Connect" button
- When prompted, enter AMT password

Repeat these steps for each machine of interest.

#### 2.5 Send Power Command

NOTE: The computer running MeshCentral and the remote running AMT must be on same subnet in order to see eachother.

- Go to https://localhost:4444/ and login
- Click on the entry for the machine of interest
- Click "Intel AMT" tab
- Click the "Connect" button
- Click "Power Actions..." button
- Select the desired Power Action, then click "OK"
