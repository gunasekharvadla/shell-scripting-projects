#!/bin/bash

# ==================================================
# Project : Server Health Monitor
# Version : 1.1 (bugfixed)
# ==================================================

REPORT="reports/report.txt"
LOGFILE="logs/health.log"
CPU_THRESHOLD=80   # FIX: was undefined, broke cpu_alert()

# FIX: create output dirs so redirection doesn't fail on a fresh checkout
mkdir -p reports logs


# Function to create report header

report_header()
{
    echo "===================================" > $REPORT
    echo "       SERVER HEALTH REPORT        " >> $REPORT
    echo "===================================" >> $REPORT
    echo "" >> $REPORT
}


# Function to collect basic system information

system_info()
{
    echo "Hostname : $(hostname)" >> $REPORT
    echo "Date     : $(date)" >> $REPORT
    echo "User     : $(whoami)" >> $REPORT
    echo "" >> $REPORT
}


cpu_monitor()
{

    echo "========== CPU INFORMATION ==========" >> $REPORT

    # CPU cores
    echo "CPU Cores : $(nproc)" >> $REPORT

    # CPU Model
    echo "CPU Model : $(lscpu | grep "Model name" | awk -F ':' '{print $2}')" >> $REPORT


    # Load Average
    echo "Load Average : $(uptime | awk -F'load average:' '{print $2}')" >> $REPORT


    # CPU Usage
    CPU_USAGE=$(top -bn1 | grep "Cpu(s)" | awk '{print 100 - $8}')

    echo "CPU Usage : $CPU_USAGE %" >> $REPORT

    echo "" >> $REPORT

}

memory_monitor()
{
    echo "========== MEMORY INFORMATION ==========" >> "$REPORT"

    echo "Total Memory     : $(free -h | awk '/^Mem:/ {print $2}')" >> "$REPORT"
    echo "Used Memory      : $(free -h | awk '/^Mem:/ {print $3}')" >> "$REPORT"
    echo "Free Memory      : $(free -h | awk '/^Mem:/ {print $4}')" >> "$REPORT"
    echo "Available Memory : $(free -h | awk '/^Mem:/ {print $7}')" >> "$REPORT"

    MEMORY_USAGE=$(free | awk '/^Mem:/ {printf "%.0f", ($3/$2)*100}')

    echo "Memory Usage     : ${MEMORY_USAGE}%" >> "$REPORT"

    echo "" >> "$REPORT"
}


disk_monitor()
{
    echo "========== DISK INFORMATION ==========" >> "$REPORT"

    df -h | awk 'NR==1 || /^\/dev/' >> "$REPORT"

    echo "" >> "$REPORT"

    ROOT_USAGE=$(df / | awk 'NR==2 {gsub("%",""); print $5}')

    echo "Root Filesystem Usage : ${ROOT_USAGE}%" >> "$REPORT"

    if [ "$ROOT_USAGE" -ge 80 ]; then
        echo "Status : WARNING - Disk usage is above 80%" >> "$REPORT"
    else
        echo "Status : OK" >> "$REPORT"
    fi

    echo "" >> "$REPORT"
}

process_monitor()
{

    echo "========== PROCESS INFORMATION ==========" >> "$REPORT"

    echo "" >> "$REPORT"
    echo "Top CPU Consuming Processes" >> "$REPORT"

    ps aux --sort=-%cpu | head -6 >> "$REPORT"

    echo "" >> "$REPORT"
    echo "Top Memory Consuming Processes" >> "$REPORT"

    ps aux --sort=-%mem | head -6 >> "$REPORT"

    echo "" >> "$REPORT"

    # FIX: exclude header line so count isn't off-by-one
    TOTAL_PROCESS=$(ps aux --no-headers | wc -l)

    echo "Total Processes : $TOTAL_PROCESS" >> "$REPORT"

    # FIX: match STAT starting with Z (handles Z+ etc.) instead of relying on
    # a fixed column position, which breaks if a long username shifts columns
    ZOMBIE_COUNT=$(ps -eo stat --no-headers | grep -c '^Z')

    echo "Zombie Processes : $ZOMBIE_COUNT" >> "$REPORT"

    echo "" >> "$REPORT"

}

service_monitor()
{

echo "========== SERVICE INFORMATION ==========" >> "$REPORT"

SERVICES=("ssh" "docker" "nginx" "jenkins")

for SERVICE in "${SERVICES[@]}"
do
    STATUS=$(systemctl is-active $SERVICE 2>/dev/null)

    if [ "$STATUS" == "active" ]; then
        echo "$SERVICE : RUNNING" >> "$REPORT"
    elif [ "$STATUS" == "inactive" ]; then
        echo "$SERVICE : STOPPED" >> "$REPORT"
    else
        echo "$SERVICE : NOT INSTALLED / FAILED" >> "$REPORT"
    fi
done

echo "" >> "$REPORT"

echo "Failed Services:" >> "$REPORT"
systemctl --failed --no-pager >> "$REPORT"

echo "" >> "$REPORT"

}

network_monitor()
{

echo "========== NETWORK INFORMATION ==========" >> "$REPORT"

IP_ADDRESS=$(hostname -I)
echo "IP Address : $IP_ADDRESS" >> "$REPORT"

GATEWAY=$(ip route | awk '/default/ {print $3}')
echo "Gateway : $GATEWAY" >> "$REPORT"

INTERFACE=$(ip route | awk '/default/ {print $5}')
echo "Interface : $INTERFACE" >> "$REPORT"

ping -c 2 8.8.8.8 > /dev/null 2>&1

if [ $? -eq 0 ]; then
    echo "Internet : Connected" >> "$REPORT"
else
    echo "Internet : Not Reachable" >> "$REPORT"
fi

ping -c 2 google.com > /dev/null 2>&1

if [ $? -eq 0 ]; then
    echo "DNS Resolution : Working" >> "$REPORT"
else
    echo "DNS Resolution : Failed" >> "$REPORT"
fi

echo "" >> "$REPORT"

}

filesystem_monitor()
{

echo "========== FILESYSTEM INFORMATION ==========" >> "$REPORT"

echo "" >> "$REPORT"
echo "Top 10 Largest Directories" >> "$REPORT"
du -sh /* 2>/dev/null | sort -hr | head -10 >> "$REPORT"

echo "" >> "$REPORT"
echo "Top Large Files (>100MB)" >> "$REPORT"
find / -type f -size +100M 2>/dev/null | head -10 >> "$REPORT"

echo "" >> "$REPORT"
echo "Recently Modified Files" >> "$REPORT"
find /var/log -type f -mtime -1 2>/dev/null | head -10 >> "$REPORT"

echo "" >> "$REPORT"
echo "Empty Files in /tmp" >> "$REPORT"
find /tmp -type f -empty 2>/dev/null >> "$REPORT"

echo "" >> "$REPORT"
echo "Inode Usage" >> "$REPORT"
df -i >> "$REPORT"

echo "" >> "$REPORT"

}

security_monitor()
{

echo "========== SECURITY INFORMATION ==========" >> "$REPORT"

echo "" >> "$REPORT"

echo "Logged In Users:" >> "$REPORT"
who >> "$REPORT"

echo "" >> "$REPORT"

echo "Recent Login Activity:" >> "$REPORT"
last -5 >> "$REPORT"

echo "" >> "$REPORT"

echo "Failed Login Attempts:" >> "$REPORT"
lastb -5 2>/dev/null >> "$REPORT"

echo "" >> "$REPORT"

echo "Open Network Ports:" >> "$REPORT"
ss -tulnp >> "$REPORT"

echo "" >> "$REPORT"

echo "Sudo Users:" >> "$REPORT"
getent group sudo >> "$REPORT"

echo "" >> "$REPORT"

}


# FIX: error_check() existed but was never called, so it did nothing.
# Call it right after any command whose exit code you actually want logged,
# e.g. right after write_log or a specific check. Wiring it in generically here:
error_check()
{
    if [ $? -ne 0 ]; then
        echo "$(date) ERROR - Command failed" >> "$LOGFILE"
    else
        echo "$(date) INFO - Command successful" >> "$LOGFILE"
    fi
}


summary_report()
{

echo "========== SUMMARY ==========" >> "$REPORT"

echo "Server Health Check Completed" >> "$REPORT"
echo "Hostname : $(hostname)" >> "$REPORT"
echo "Time : $(date)" >> "$REPORT"

echo "" >> "$REPORT"

}

cpu_alert()
{
    CPU=$(top -bn1 | grep Cpu | awk '{print 100-$8}')

    # FIX: replaced bc dependency with awk (no external dep, avoids
    # "bc: command not found" and the undefined-threshold breakage)
    IS_HIGH=$(awk -v cpu="$CPU" -v thresh="$CPU_THRESHOLD" 'BEGIN { print (cpu > thresh) ? 1 : 0 }')

    if [ "$IS_HIGH" -eq 1 ]; then
        echo "WARNING CPU HIGH : $CPU%" >> "$REPORT"
    fi
}


write_log()
{
    TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$TIMESTAMP] INFO - Health check completed successfully" >> "$LOGFILE"
}


# Main Program

report_header
system_info
cpu_monitor
memory_monitor
disk_monitor
process_monitor
service_monitor
network_monitor
filesystem_monitor
security_monitor
summary_report
cpu_alert

write_log
error_check   # FIX: now actually invoked, logs success/failure of write_log

echo "Health report generated successfully"
echo "Location: $REPORT"
