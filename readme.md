
# 🐧 PenguinReport

PenguinReport is a lightweight, modular shell script designed to generate a comprehensive JSON snapshot of a Linux system’s state. It dives deep into your system and resurfaces with structured, digestible information—perfect for DevOps, SREs, and auditors.

## 💡 Project Goals

* **Uniformity:** A portable audit script for all major Linux distributions.
* **Automation-Ready:** Pure JSON output for easy integration with ELK, Splunk, or custom dashboards.
* **Zero-Dependency:** Runs on standard POSIX tools (optional `jq` for pretty-printing).

## 🧰 Execution Modes

| Mode | Modules Included | Speed |
| --- | --- | --- |
| **Light** | CPU, Memory, Disk, Network, System | ⚡ Near Instant |
| **Full** | Everything in Light + Packages, Services, Users, Security, Kernel, Hardware | 🐢 5-15 Seconds |

## 🧰 What It Does

PenguinReport collects and outputs the following information in structured JSON:
- ✅ OS Details (Distro, Kernel, Architecture)
- ✅ CPU and Memory Info
- ✅ Disk Devices and Mounted Filesystems
- ✅ Network Interfaces and IP Assignments
- ✅ Installed Packages (using available package manager)
- ✅ Logged-In Users and Sessions
- ✅ System Uptime
- ✅ Running Processes Summary
- ✅ SELinux/AppArmor Status (if applicable)
---

## 🛠 Project Structure & Modular Architecture

This agent utilizes a decoupled architecture, separating the core execution logic from specific data collection tasks. This makes the agent lightweight, easy to debug, and simple to extend.

```text
agent/
├── agent.sh           # Main entry point; orchestrates module execution
├── lib/
│   └── json.sh        # Shared helper functions (JSON escaping, formatting)
└── modules/           # Individual data collection scripts
    ├── cpu.sh             # Processor specs and topology
    ├── datetime.sh        # System uptime and synchronization
    ├── disk.sh            # Physical disk health and I/O
    ├── environment.sh     # Shell environment and exported variables
    ├── filesystem.sh      # Mount points and usage (df -hPT)
    ├── hardware.sh        # DMI, PCI, and USB device inventory
    ├── kernel_modules.sh  # Loaded LKM (Linux Kernel Modules)
    ├── memory.sh          # RAM/Swap breakdown via /proc/meminfo
    ├── network.sh         # Interfaces, IP addresses, and routing
    ├── packages.sh        # Installed package count and updates
    ├── performance.sh     # Real-time CPU/Mem load and process counts
    ├── security.sh        # SSH, Sudoers, and MAC (SELinux/AppArmor)
    ├── services.sh        # Systemd/Upstart service status
    ├── system.sh          # OS, Kernel version, and Hostname
    └── users.sh           # Human users and UID tracking

```

### 🚀 How it Works

1. **`agent.sh`** initializes the output file and sources the library helpers.
2. It dynamically loops through or explicitly calls functions defined in the **`modules/*.sh`** files.
3. Each module writes its specific key-pair to the global `OUTPUT_FILE`.
4. The final output is a single, valid JSON object ready for ingestion by ELK, Grafana, or a custom API.

### ➕ Adding New Modules

To add a new data category (e.g., `gpu.sh` or `docker.sh`):

1. Create a new `.sh` file in the `modules/` directory.
2. Define your collection function.
3. Call the function in `agent.sh`.
4. Ensure you use the `escape_json` helper from `lib/json.sh` for any string data to prevent breaking the JSON structure.

---

Example Output :

```json
{
  "agent": {
    "version": "1.0.0",
    "mode": "light"
  },
  "system": {
    "hostname": "Test_Server",
    "operating_system": "GNU/Linux",
    "kernel_name": "Linux",
    "kernel_release": "6.8.0-94-generic",
    "kernel_version": "#96-Ubuntu SMP PREEMPT_DYNAMIC Fri Jan  9 20:36:55 UTC 2026",
    "architecture": "x86_64",
    "uptime": "1 hour, 5 minutes",
    "last_boot": "02.03.2026 17:10:05"
  },
  "cpu": {
    "model": "Intel(R) Core(TM) i7-10700 CPU @ 2.90GHz",
    "cores": "2",
    "threads_per_core": "1",
    "sockets": "2",
    "cpu_mhz": "2900"
  }
}
```

---


## 🛠️ Usage

### Quick Run (Default Light Mode)

```bash
./agent.sh

```

### Deep Audit

```bash
./agent.sh --full

```

### Installation

```bash
git clone https://github.com/alilotfi23/penguinreport.git
cd penguinreport
chmod +x agent.sh
./agent.sh --light

```

## 📂 Output Format

Output is saved to the current directory using a sortable professional naming convention:
`"${TIMESTAMP}_${HOST}_${MODE}_v${VERSION}.json"`

## 🐧 Supported Operating Systems

| Distribution | Status |
| --- | --- |
| Ubuntu / Debian | ✅ Tested |
| CentOS / RHEL / Alma / Rocky | ✅ Tested |
| Fedora | ✅ Tested |
| Arch Linux | ✅ Tested |
| macOS | ✅ Supported (Limited info) |

## ⚙️ Requirements

* **Bash 4.0+**
* **Standard Utils:** `sed`, `grep`, `hostname`, `date`.
* **jq (Optional):** If installed, the script will automatically validate and pretty-print your JSON output.

## 🔒 Security & Privacy

* **Local Only:** No data is transmitted. All information stays on your machine.
* **Privilege:** Runs as a regular user, though `sudo` is recommended for full hardware and package visibility.

## 📦 Contributing

Contributions are welcome! Please:
- Submit issues for bugs or unsupported distros
- Create pull requests for added compatibility or new system metrics
- Keep it POSIX-compliant where possible!

---

## 📄 License

MIT License. See `LICENSE` for details.

**Stay light. Stay Linux. Stay penguin. 🐧**

