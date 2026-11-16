# NetPulse



A lightweight terminal-based network monitoring dashboard for PowerShell.



NetPulse provides a live overview of network activity, active connections, traffic statistics, protocol distribution, hostname resolution, and historical trend data, all within a fixed terminal layout.



> ⚠️ NetPulse is currently in an early prototype stage. Functionality, layout, data collection methods, and module structure may change significantly between releases.



---



## Screenshot



![NetPulse Dashboard](assets/netpulse-dashboard.png)



---



## Features



### Traffic Monitoring



- Live inbound traffic monitoring

- Live outbound traffic monitoring

- Packets-per-second tracking

- Historical traffic trend graphs



### Connection Monitoring



- Active TCP connection statistics

- UDP endpoint tracking

- Connection state monitoring

- Active flow overview



### Host Resolution



- Reverse DNS lookups

- Cached hostname resolution

- Friendly service name mapping

- Basic destination identification



### Dashboard Interface



- Fixed terminal layout

- Live refresh updates

- Historical trend visualization

- Modular architecture for future expansion



---



## Project Structure

```text
NetPulse
│
├── README.md
├── NetPulse.ps1
│
├── Assets
│   └── netpulse-dashboard.png
│
├── Config
│   └── Settings.ps1
│
└── Modules
    ├── Core
    │   ├── Collector.psm1
    │   ├── History.psm1
    │   └── Resolver.psm1
    │
    ├── Network
    │   ├── Connections.psm1
    │   ├── Traffic.psm1
    │   ├── Protocols.psm1
    │   └── TopTalkers.psm1
    │
    └── UI
        ├── Colors.psm1
        ├── Layout.psm1
        └── Rendering.psm1
```


## Requirements



- Windows PowerShell 5.1 or newer

- Administrator privileges recommended

- Windows networking cmdlets available



---



## Running NetPulse

Launch PowerShell, navigate to the project directory, and run:

```powershell
.\NetPulse.ps1
```

If script execution is restricted:

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
```

Then run:

```powershell
.\NetPulse.ps1
```


## Current Status



The current prototype focuses on:



- Modular architecture

- Real-time data collection

- Dashboard rendering

- Hostname resolution

- Historical statistics



Areas currently under development include:



- Dashboard layout refinement

- Improved hostname identification

- Better traffic attribution

- Bandwidth-based top talkers

- Enhanced protocol statistics

- Additional historical views



---



## Roadmap



Planned improvements:



- Better panel spacing and layout

- Usage bars and visual indicators

- Improved DNS and service identification

- Connection history tracking

- Interface selection

- Export and logging options

- Alerting and anomaly detection



---



## License



MIT License



---



NetPulse was created as an experimental PowerShell network monitoring project focused on providing quick, at-a-glance network visibility directly from the terminal.

