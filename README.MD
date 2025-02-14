# **🚀 Linux Process Monitor**

### **Program developed by Gustavo Wydler Azuaga - 2025-02-14**

## **📌 Description**

The **Linux Process Monitor** is a command-line interface (CLI) tool designed to simplify the management and monitoring of system processes. This interactive script allows users to view, sort, find, and manage running processes efficiently, helping to optimize system performance and resource usage.

---

## **🔥 Features**

- 🟢 Show real-time system process reports  
- 🔥 Auto-refresh mode for continuous monitoring  
- 📊 Display top 10 processes sorted by CPU, memory, or start time  
- 🔍 Find a process using regular expressions (without spawning new processes)  
- ❌ Kill a process with a confirmation prompt  
- 🚀 Advanced interactive sorting menu 

---

## **📜 Menu Options**

| Option | Description |
|--------|-------------|
| 1️⃣ | Run a one-time **Processes Report** |
| 2️⃣ | Enable **Auto-Refresh Mode** |
| 3️⃣ | Show **Top 10 Processes by CPU Usage** |
| 4️⃣ | Show **Top 10 Processes by Memory Usage** |
| 5️⃣ | Show **Top 10 Processes by Start Time** |
| 6️⃣ | **Find a Process** by Regex (No Extra Process Spawned) |
| 7️⃣ | **Kill a Process** with Confirmation |
| 8️⃣ | **Advanced Interactive Sorting Menu** |
| 9️⃣ | **Exit the Program** |

---

## **🛠 Requirements**

The **Linux Process Monitor** requires basic Linux utilities to function properly.  
Ensure that your system has the following installed:

- **`ps`** – Process status command  
- **`awk`** – Text processing tool  
- **`grep`** – Pattern search utility  
- **`kill`** – Process termination command  

If these tools are missing, install them with:

```bash
# Debian-based systems (Ubuntu, Debian, etc.)
sudo apt update && sudo apt install procps gawk grep -y

# RHEL-based systems (CentOS, AlmaLinux, Rocky Linux)
sudo yum install procps-ng gawk grep -y
```
## **🚀 How to Run the Program**

- **Download the script**:  
    ```bash
    git clone https://github.com/kurogane13/linux_process_monitor.git
    cd linux_process_monitor
    ```

- **Make the script executable**:  
    ```bash
    chmod +x process_monitor.sh
    ```

- **Run the script**:  
    ```bash
    cd linux_process_monitor
    ./process_monitor.sh
    ```

