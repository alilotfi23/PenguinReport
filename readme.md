# 🐧 PenguinReport

PenguinReport is a lightweight, zero-dependency shell script designed to generate a comprehensive JSON snapshot of a Linux system’s state. It provides valuable insights into hardware, OS, network configuration, installed packages, and more — making it an essential tool for DevOps, system administrators, and compliance auditors.

---

## 📌 About the Name

The name **PenguinReport** pays homage to the Linux mascot, Tux the Penguin 🐧. Just like a penguin dives deep and resurfaces with food, PenguinReport dives deep into your Linux system and resurfaces with structured, digestible system information. It’s fast, simple, elegant — and pure Linux.

---

## 💡 Project Goals

- Provide a **uniform and portable** system audit script for all major Linux distributions.
- Output data in **JSON format** to facilitate automation, integration with monitoring tools, or use in configuration management pipelines.
- Require **no external dependencies** — just POSIX-compliant tools and logic.
- Make it easy to **debug**, **document**, and **monitor** Linux infrastructure at scale.

---

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

Example Output (truncated):

```json
{
  "hostname": "myserver",
  "os": {
    "name": "Ubuntu",
    "version": "22.04",
    "kernel": "6.2.0-32-generic",
    "architecture": "x86_64"
  },
  "cpu": {
    "model": "Intel(R) Core(TM) i7-8750H",
    "cores": 12
  }
}
```

---

## 🐧 Supported Operating Systems

PenguinReport works on **most Linux distributions** with little or no modification, including:

| Distribution     | Status     |
|------------------|------------|
| Ubuntu (16.04+)  | ✅ Tested   |
| Debian (9+)      | ✅ Tested   |
| CentOS (7, 8)    | ✅ Tested   |
| Fedora (35+)     | ✅ Tested   |
| AlmaLinux / Rocky Linux | ✅ Tested |
| Arch Linux       | ✅ Tested   |
| Amazon Linux     | ✅ Tested   |
| Alpine Linux     | ⚠️ Partial Support (BusyBox limitations) |
| Kali Linux       | ✅ Tested   |
| RHEL (7/8/9)     | ✅ Tested   |

> ℹ️ If you're using a custom or minimal distribution, ensure basic tools like `uname`, `lscpu`, `lsblk`, and your system's package manager (e.g., `dpkg`, `rpm`, or `apk`) are installed.

---

## 🚀 Usage

```bash
curl -sSL https://raw.githubusercontent.com/your-org/penguinreport/main/penguinreport.sh | bash
```

Or clone the repo and run manually:

```bash
git clone https://github.com/your-org/penguinreport.git
cd penguinreport
chmod +x penguinreport.sh
./penguinreport.sh
```

> Output will be saved to `penguinreport.json` in the current directory.

---

## 🔒 Security & Privacy

- No data is transmitted anywhere. All information stays local unless you choose to upload it.
- The script runs as a regular user by default; root permissions may be required for full disk/network/package visibility.

---

## 🛠️ Integration Ideas

- 📊 Pipe the output into your monitoring or audit dashboards (e.g., Grafana, ELK, Splunk)
- 📁 Archive JSON reports periodically for system change tracking
- 🔄 Feed it into your config drift detection or incident response tools

---

## 📦 Contributing

Contributions are welcome! Please:
- Submit issues for bugs or unsupported distros
- Create pull requests for added compatibility or new system metrics
- Keep it POSIX-compliant where possible!

---

## 📄 License

MIT License. See [LICENSE](./LICENSE) for details.

---

## 🌍 Acknowledgments

Special thanks to the Linux community and the developers of core GNU utilities that make tools like PenguinReport possible.

---

Stay light. Stay Linux. Stay penguin. 🐧
