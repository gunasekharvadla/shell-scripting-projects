#!/bin/bash

# ==========================================
# Project : Log File Analyzer
# Author  : Guna
# Version : 1.0
# ==========================================

REPORT="reports/analysis-report.txt"

ACCESS_LOG="logs/access.log"
APPLICATION_LOG="logs/application.log"
SYSTEM_LOG="logs/system.log"

RED="\e[31m"
GREEN="\e[32m"
YELLOW="\e[33m"
BLUE="\e[34m"
NC="\e[0m"



show_menu()
{

echo -e "${BLUE}"
echo "======================================"
echo "      LOG ANALYZER MENU"
echo "======================================"
echo -e "${NC}"

echo "1. Generate Full Report"
echo "2. Show Log Statistics"
echo "3. Show HTTP Analysis"
echo "4. Show Top IPs"
echo "5. Exit"

read -p "Enter choice: " CHOICE

case $CHOICE in

1)
report_header
log_statistics
log_analysis
ip_analysis
url_analysis
advanced_analysis
summary_report
report_footer
;;

2)
report_header
log_statistics
;;

3)
report_header
log_analysis
;;

4)
report_header
ip_analysis
;;

5)
echo "Exiting..."
exit 0
;;

*)
echo -e "${RED}Invalid Choice${NC}"
;;

esac

}


report_header()
{

echo "===================================" > "$REPORT"

echo "       LOG ANALYSIS REPORT         " >> "$REPORT"

echo "===================================" >> "$REPORT"

echo "" >> "$REPORT"

echo "Generated : $(date)" >> "$REPORT"

echo "" >> "$REPORT"

}

log_statistics()
{

echo "========== LOG STATISTICS ==========" >> "$REPORT"

ACCESS_COUNT=$(wc -l < "$ACCESS_LOG")

APPLICATION_COUNT=$(wc -l < "$APPLICATION_LOG")

SYSTEM_COUNT=$(wc -l < "$SYSTEM_LOG")

TOTAL=$((ACCESS_COUNT + APPLICATION_COUNT + SYSTEM_COUNT))

echo "Access Log Lines      : $ACCESS_COUNT" >> "$REPORT"

echo "Application Log Lines : $APPLICATION_COUNT" >> "$REPORT"

echo "System Log Lines      : $SYSTEM_COUNT" >> "$REPORT"

echo "Total Log Lines       : $TOTAL" >> "$REPORT"

echo "" >> "$REPORT"

}

log_analysis()
{

echo "========== LOG ANALYSIS ==========" >> "$REPORT"

# Application Log Analysis

ERROR_COUNT=$(grep -c "ERROR" "$APPLICATION_LOG")

WARNING_COUNT=$(grep -c "WARNING" "$APPLICATION_LOG")

INFO_COUNT=$(grep -c "INFO" "$APPLICATION_LOG")


echo "ERROR Count   : $ERROR_COUNT" >> "$REPORT"

echo "WARNING Count : $WARNING_COUNT" >> "$REPORT"

echo "INFO Count    : $INFO_COUNT" >> "$REPORT"

echo "HTTP Status Codes" >> "$REPORT"

HTTP_200=$(grep -c ' 200 ' "$ACCESS_LOG")
HTTP_401=$(grep -c ' 401 ' "$ACCESS_LOG")
HTTP_403=$(grep -c ' 403 ' "$ACCESS_LOG")
HTTP_404=$(grep -c ' 404 ' "$ACCESS_LOG")
HTTP_500=$(grep -c ' 500 ' "$ACCESS_LOG")

echo "200 OK                  : $HTTP_200" >> "$REPORT"
echo "401 Unauthorized        : $HTTP_401" >> "$REPORT"
echo "403 Forbidden           : $HTTP_403" >> "$REPORT"
echo "404 Not Found           : $HTTP_404" >> "$REPORT"
echo "500 Internal Server Err : $HTTP_500" >> "$REPORT"
FAILED_LOGIN=$(grep -c "Failed password" "$SYSTEM_LOG")

SUCCESS_LOGIN=$(grep -c "Accepted password" "$SYSTEM_LOG")

echo "Successful Logins : $SUCCESS_LOGIN" >> "$REPORT"
echo "Failed Logins     : $FAILED_LOGIN" >> "$REPORT"

echo "" >> "$REPORT"
}




ip_analysis()
{

echo "========== TOP IP ADDRESSES ==========" >> "$REPORT"

awk '{print $1}' "$ACCESS_LOG" | \
sort | \
uniq -c | \
sort -nr >> "$REPORT"

echo "" >> "$REPORT"

}


url_analysis()
{

echo "========== URL ANALYSIS ==========" >> "$REPORT"

echo "" >> "$REPORT"

echo "Top Requested URLs" >> "$REPORT"

awk '{print $7}' "$ACCESS_LOG" | \
sort | \
uniq -c | \
sort -nr >> "$REPORT"

echo "" >> "$REPORT"

echo "HTTP Request Methods" >> "$REPORT"

GET_COUNT=$(grep -c '"GET' "$ACCESS_LOG")
POST_COUNT=$(grep -c '"POST' "$ACCESS_LOG")

echo "GET Requests  : $GET_COUNT" >> "$REPORT"
echo "POST Requests : $POST_COUNT" >> "$REPORT"

echo "" >> "$REPORT"

}


advanced_analysis()
{

echo "========== ADVANCED LOG ANALYSIS ==========" >> "$REPORT"

echo "" >> "$REPORT"

echo "Top Error Messages" >> "$REPORT"

grep "ERROR" "$APPLICATION_LOG" | \
sort | \
uniq -c | \
sort -nr >> "$REPORT"

echo "" >> "$REPORT"

echo "Top Warning Messages" >> "$REPORT"

grep "WARNING" "$APPLICATION_LOG" | \
sort | \
uniq -c | \
sort -nr >> "$REPORT"

echo "" >> "$REPORT"

echo "Disk Related Errors" >> "$REPORT"

grep -i "disk" "$APPLICATION_LOG" >> "$REPORT"
grep -i "disk" "$SYSTEM_LOG" >> "$REPORT"

echo "" >> "$REPORT"

echo "Memory Related Warnings" >> "$REPORT"

grep -i "memory" "$APPLICATION_LOG" >> "$REPORT"
grep -i "memory" "$SYSTEM_LOG" >> "$REPORT"

echo "" >> "$REPORT"

echo "Authentication Failures" >> "$REPORT"

grep -i "failed" "$SYSTEM_LOG" >> "$REPORT"

echo "" >> "$REPORT"

}



summary_report()
{

echo "========== SUMMARY ==========" >> "$REPORT"

echo "" >> "$REPORT"

ERROR_COUNT=$(grep -c "ERROR" "$APPLICATION_LOG")
WARNING_COUNT=$(grep -c "WARNING" "$APPLICATION_LOG")
FAILED_LOGIN=$(grep -c "Failed password" "$SYSTEM_LOG")

TOTAL_ISSUES=$((ERROR_COUNT + WARNING_COUNT + FAILED_LOGIN))

echo "Total Errors           : $ERROR_COUNT" >> "$REPORT"
echo "Total Warnings         : $WARNING_COUNT" >> "$REPORT"
echo "Failed Login Attempts  : $FAILED_LOGIN" >> "$REPORT"
echo "Total Issues Detected  : $TOTAL_ISSUES" >> "$REPORT"

echo "" >> "$REPORT"

if [ "$TOTAL_ISSUES" -eq 0 ]
then
    echo "Overall Health : HEALTHY" >> "$REPORT"

elif [ "$TOTAL_ISSUES" -le 5 ]
then
    echo "Overall Health : WARNING" >> "$REPORT"

else
    echo "Overall Health : CRITICAL" >> "$REPORT"

fi

echo "" >> "$REPORT"

}



report_footer()
{

echo "===================================" >> "$REPORT"

echo "End of Report" >> "$REPORT"

echo "Generated On : $(date)" >> "$REPORT"

echo "===================================" >> "$REPORT"

}

cleanup_logs()
{

echo "Cleaning old reports..."

find reports \
-name "*.txt" \
-type f \
-mtime +7 \
-delete

echo "Cleanup completed."

}


archive_logs()
{

mkdir -p archive

TIMESTAMP=$(date +%Y%m%d_%H%M%S)

tar -czf archive/logs_$TIMESTAMP.tar.gz logs

echo "Logs archived successfully."

}














report_header

log_statistics

log_analysis

ip_analysis

url_analysis

advanced_analysis


summary_report

report_footer

show_menu

echo -e "${GREEN}Report Generated Successfully${NC}"
echo "Report generated successfully"

echo "Location : $REPORT"
case "$1" in

stats)

report_header
log_statistics
;;

http)

report_header
log_analysis
;;

ip)

report_header
ip_analysis
;;

url)

report_header
url_analysis
;;

full|"")

report_header
log_statistics
log_analysis
ip_analysis
url_analysis
advanced_analysis
summary_report
report_footer
;;

*)

echo "Usage:"
echo "./analyze-logs.sh full"
echo "./analyze-logs.sh stats"
echo "./analyze-logs.sh http"
echo "./analyze-logs.sh ip"
echo "./analyze-logs.sh url"
;;

esac
