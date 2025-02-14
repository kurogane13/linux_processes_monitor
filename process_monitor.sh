#!/bin/bash

# 🛠️ Define Colors for Futuristic UI
RESET="\e[0m"
BOLD="\e[1m"
GREEN="\e[32m"
CYAN="\e[36m"
YELLOW="\e[33m"
RED="\e[31m"
WHITE="\e[97m"
BLUE="\e[34m"
MAGENTA="\e[35m"

# 🎨 Define futuristic dividers & symbols
LINE="${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
NEON_ARROW="${BOLD}${CYAN}⫸${RESET}"  # Stylish selection arrow

#prompt for refresh interval and head value
ask_refresh_and_head() {
    # validate numeric input
    validate_integer() {
        local input="$1"
        [[ "$input" =~ ^[0-9]+$ ]] && return 0 || return 1
    }

    # Prompt for refresh interval (only integers allowed)
    while true; do
        echo -e "${BOLD}${MAGENTA}Enter refresh interval (seconds): ${RESET}"
        read refresh_interval
        if validate_integer "$refresh_interval"; then
            break
        else
            echo
            echo -e "${BOLD}${RED}❌ Invalid input! Please enter a valid number.${RESET}"
            echo
        fi
    done

    # Convert refresh interval to readable format
    readable_time="$refresh_interval sec"
    if (( refresh_interval > 3600 )); then
        readable_time="$(bc <<< "scale=2; $refresh_interval/3600") hours"
    elif (( refresh_interval > 60 )); then
        readable_time="$(bc <<< "scale=2; $refresh_interval/60") minutes"
    fi

    # Prompt for head value (only integers allowed)
    while true; do
        echo -e "${BOLD}${CYAN}Enter the number of entries to display: ${RESET}"
        read head_value
        if validate_integer "$head_value"; then
            break
        else
            echo
            echo -e "${BOLD}${RED}❌ Invalid input! Please enter a valid number.${RESET}"
            echo
        fi
    done
    sleep 1
}

ask_refresh_no_head() {
    # validate numeric input
    validate_integer() {
        local input="$1"
        [[ "$input" =~ ^[0-9]+$ ]] && return 0 || return 1
    }

    # Prompt for refresh interval (only integers allowed)
    while true; do
        echo -e "${BOLD}${MAGENTA}Enter refresh interval (seconds): ${RESET}"
        read refresh_interval
        if validate_integer "$refresh_interval"; then
            break
        else
            echo
            echo -e "${BOLD}${RED}❌ Invalid input! Please enter a valid number.${RESET}"
            echo
        fi
    done

    echo
    echo -e "\n${BOLD}${GREEN}✔ Refresh interval in: ${refresh_interval} seconds${RESET}"
    # Convert refresh interval to readable format
    readable_time="$refresh_interval sec"
    if (( refresh_interval > 3600 )); then
        readable_time="$(bc <<< "scale=2; $refresh_interval/3600") hours"
    elif (( refresh_interval > 60 )); then
        readable_time="$(bc <<< "scale=2; $refresh_interval/60") minutes"
    fi
    sleep 1
}

#sorter with user-defined `head`

enable_auto_refresh_sorter() {
    ask_refresh_and_head  # Get user input for refresh time & head value

    while true; do
        clear
        echo -e "${BOLD}${GREEN}🔥 Running: ${command} | head -${head_value}${RESET}\n"
        eval "$command" | head -${head_value}  # Execute sorting command with head
		echo
		echo -e "\n${BOLD}${GREEN}✔ Refresh interval in: ${refresh_interval} seconds | Entries to display: ${head_value}${RESET}"
		echo
        echo -e "\n${CYAN}Press 'E' to return to the menu.${RESET}"
        read -t "$refresh_interval" -n 1 keypress
        if [[ $keypress == "E" || $keypress == "e" ]]; then
            echo -e "\n${BOLD}${YELLOW}Returning to sorting menu...${RESET}"
            sleep 1
            process_sorter
        fi
    done
}

#find a process by regex without spawning a new process
find_process() {
    echo -e "${BOLD}${MAGENTA}🔍 Enter a search term to find a process (name, PID, or command): ${RESET}"
    read search_term

    # Use /proc to avoid spawning a new process
    echo
    echo -e "${BOLD}${GREEN}🔥 Searching for processes matching: '${search_term}'${RESET}"
    echo -e "${LINE}"

    # Scan /proc for process info without spawning a new process
    for pid in /proc/[0-9]*; do
        if [[ -f "$pid/cmdline" ]]; then
            process_cmd=$(tr '\0' ' ' < "$pid/cmdline")  # Read command line
            process_name=$(basename "$process_cmd")      # Extract process name

            # Check if the process matches the search term
            if [[ "$process_cmd" =~ $search_term || "$process_name" =~ $search_term || "$(basename "$pid")" =~ $search_term ]]; then
                echo
                printf "${GREEN}PID:${WHITE} %-8s ${BLUE}Name:${WHITE} %-20s ${YELLOW}Command:${WHITE} %s${RESET}\n" \
                    "$(basename "$pid")" "$process_name" "$process_cmd"
            fi
        fi
    done
    echo
    echo -e "${LINE}"
}

#find and kill a process
kill_process() {
    find_process  # Call the process finder function first
	echo
    echo -e "${BOLD}${RED}⚠ WARNING: Attempting to kill a process.${RESET}"
    echo
    echo -e "${BOLD}${MAGENTA}Enter the PID of the process you want to kill: ${RESET}"
    read kill_pid

    # Confirm before killing the process
    echo
    echo -e "${BOLD}${YELLOW}Are you sure you want to kill process PID ${kill_pid}? (y/n): ${RESET}"
    read confirm

    if [[ "$confirm" == "y" || "$confirm" == "Y" ]]; then
        kill -9 "$kill_pid" 2>/dev/null  # Kill the process forcefully
        if [[ $? -eq 0 ]]; then
            echo
            echo -e "${BOLD}${GREEN}✔ Process PID ${kill_pid} has been terminated.${RESET}"
        else
            echo
            echo -e "${BOLD}${RED}❌ Failed to terminate process ${kill_pid}. Check permissions.${RESET}"
        fi
    else
        echo
        echo -e "${BOLD}${CYAN}🚀 Operation canceled. Process not killed.${RESET}"
    fi
}

#process sorting menu
process_sorter() {
    while true; do
        clear
        echo -e "${BOLD}${WHITE}🚀 Interactive Process Sorting Menu 🚀${RESET}"
        echo
        echo -e "${LINE}"
        echo
        echo -e "${WHITE}Select a sorting option:${RESET}"
        echo
        echo -e " ${YELLOW}1) CPU Usage (Highest First)"
        echo -e " 2) Memory Usage (Highest First)"
        echo -e " 3) Process ID (PID) (Descending)"
        echo -e " 4) Start Time (Highest First)"
        echo -e " 5) Virtual Memory (VSZ) (Highest First)"
        echo -e " 6) Resident Memory (RSS) (Highest First)"
        echo -e " 7) User (Z to A)"
        echo -e " 8) Combine Multiple Sorting Options"
        echo -e " ${RED}9) Exit Sorting Menu. <-- Back to main menu${RESET}"
        echo
        echo -e "${LINE}"

        # Prompt user for choice
        echo -e "\n${BOLD}${WHITE}Enter your choice: ${RESET}" 
        read choice

        case $choice in
            1)
                command="ps aux --sort=-%cpu"
                enable_auto_refresh_sorter
                ;;
            2)
                command="ps aux --sort=-%mem"
                enable_auto_refresh_sorter
                ;;
            3)
                command="ps aux --sort=-pid"
                enable_auto_refresh_sorter
                ;;
            4)
                command="ps aux --sort=-start_time"
                enable_auto_refresh_sorter
                ;;
            5)
                command="ps aux --sort=-vsz | awk 'NR==1 {printf \"%-10s %-6s %-6s %-6s %-12s %-12s %-12s %-12s %-12s %-12s %-12s %s\\n\", \"USER\", \"PID\", \"%CPU\", \"%MEM\", \"VSZ_MB\", \"VSZ_GB\", \"VSZ_TB\", \"RSS_MB\", \"RSS_GB\", \"RSS_TB\", \"START\", \"COMMAND\"} NR>1 {printf \"%-10s %-6s %-6s %-6s %-12.2f %-12.2f %-12.2f %-12.2f %-12.2f %-12.2f %-12s %s\\n\", \$1, \$2, \$3, \$4, \$5/1024, \$5/1048576, \$5/1073741824, \$6/1024, \$6/1048576, \$6/1073741824, \$9, \$11}'"
                enable_auto_refresh_sorter
                ;;
            6)
                command="ps aux --sort=-rss | awk 'NR==1 {printf \"%-10s %-6s %-6s %-6s %-12s %-12s %-12s %-12s %-12s %-12s %-12s %s\\n\", \"USER\", \"PID\", \"%CPU\", \"%MEM\", \"VSZ_MB\", \"VSZ_GB\", \"VSZ_TB\", \"RSS_MB\", \"RSS_GB\", \"RSS_TB\", \"START\", \"COMMAND\"} NR>1 {printf \"%-10s %-6s %-6s %-6s %-12.2f %-12.2f %-12.2f %-12.2f %-12.2f %-12.2f %-12s %s\\n\", \$1, \$2, \$3, \$4, \$5/1024, \$5/1048576, \$5/1073741824, \$6/1024, \$6/1048576, \$6/1073741824, \$9, \$11}'"
                enable_auto_refresh_sorter
                ;;
            7)
                command="ps aux --sort=-user"
                enable_auto_refresh_sorter
                ;;
            8)
                # Display all sorting options
                clear
                echo -e "${BOLD}${WHITE}🛠️ Custom Sorting Mode: Choose multiple fields${RESET}"
                echo
                echo -e "${LINE}"
                echo
                echo -e " ${WHITE}Available sorting options:${RESET}"
                echo
                echo -e " ${GREEN}%cpu${RESET}       - Sort by CPU usage"
                echo -e " ${YELLOW}%mem${RESET}       - Sort by Memory usage"
                echo -e " ${BLUE}pid${RESET}        - Sort by Process ID"
                echo -e " ${MAGENTA}start_time${RESET} - Sort by Process Start Time"
                echo -e " ${CYAN}time${RESET}       - Sort by Total CPU Time Used"
                echo -e " ${RED}vsz${RESET}        - Sort by Virtual Memory Size"
                echo -e " ${WHITE}rss${RESET}        - Sort by Resident Set Size (Physical Memory)"
                echo -e " ${GREEN}user${RESET}       - Sort by Username (Alphabetical)"
                echo
                echo -e "${LINE}"
                echo
                echo -e " ${BOLD}${YELLOW}Usage:${RESET}"
                echo -e " Enter sorting fields separated by commas. Prefix '-' for descending order."
                echo -e " ${BOLD}${GREEN}Example:${RESET} -%cpu,-%mem,start_time"
                echo
                echo -e "${LINE}"

                # Read custom sort input
                echo -e "${BOLD}${YELLOW} <-- Press 'E', or 'e', to go back to the interactive menu${RESET}"
                echo
                read -p "Enter sorting options: " custom_sort
                if [[ $custom_sort == "E" || $custom_sort == "e" ]]; then
                    echo
                    echo -e "${BOLD}${YELLOW}Returning to sorting menu...${RESET}"
                    sleep 1
                    process_sorter
                fi

				# Sort by VSZ (Virtual Memory)
				if [[ $custom_sort == "vsz" ]]; then
					command="ps aux --sort=vsz | awk 'NR==1 {printf \"%-10s %-6s %-6s %-6s %-12s %-12s %-12s %-12s %-12s %-12s %-12s %s\\n\", \"USER\", \"PID\", \"%CPU\", \"%MEM\", \"VSZ_MB\", \"VSZ_GB\", \"VSZ_TB\", \"RSS_MB\", \"RSS_GB\", \"RSS_TB\", \"START\", \"COMMAND\"} NR>1 {printf \"%-10s %-6s %-6s %-6s %-12.2f %-12.2f %-12.2f %-12.2f %-12.2f %-12.2f %-12s %s\\n\", \$1, \$2, \$3, \$4, \$5/1024, \$5/1048576, \$5/1073741824, \$6/1024, \$6/1048576, \$6/1073741824, \$9, \$11}'"
					enable_auto_refresh_sorter
				fi
				
				# Sort by VSZ (Virtual Memory)
				if [[ $custom_sort == "vsz" ]]; then
					command="ps aux --sort=-vsz | awk 'NR==1 {printf \"%-10s %-6s %-6s %-6s %-12s %-12s %-12s %-12s %-12s %-12s %-12s %s\\n\", \"USER\", \"PID\", \"%CPU\", \"%MEM\", \"VSZ_MB\", \"VSZ_GB\", \"VSZ_TB\", \"RSS_MB\", \"RSS_GB\", \"RSS_TB\", \"START\", \"COMMAND\"} NR>1 {printf \"%-10s %-6s %-6s %-6s %-12.2f %-12.2f %-12.2f %-12.2f %-12.2f %-12.2f %-12s %s\\n\", \$1, \$2, \$3, \$4, \$5/1024, \$5/1048576, \$5/1073741824, \$6/1024, \$6/1048576, \$6/1073741824, \$9, \$11}'"
					enable_auto_refresh_sorter
				fi
				
				# Sort by RSS (Resident Memory)
				if [[ $custom_sort == "rss" ]]; then
					command="ps aux --sort=rss | awk 'NR==1 {printf \"%-10s %-6s %-6s %-6s %-12s %-12s %-12s %-12s %-12s %-12s %-12s %s\\n\", \"USER\", \"PID\", \"%CPU\", \"%MEM\", \"VSZ_MB\", \"VSZ_GB\", \"VSZ_TB\", \"RSS_MB\", \"RSS_GB\", \"RSS_TB\", \"START\", \"COMMAND\"} NR>1 {printf \"%-10s %-6s %-6s %-6s %-12.2f %-12.2f %-12.2f %-12.2f %-12.2f %-12.2f %-12s %s\\n\", \$1, \$2, \$3, \$4, \$5/1024, \$5/1048576, \$5/1073741824, \$6/1024, \$6/1048576, \$6/1073741824, \$9, \$11}'"
					enable_auto_refresh_sorter
				fi

				# Sort by RSS (Resident Memory)
				if [[ $custom_sort == "rss" ]]; then
					command="ps aux --sort=-rss | awk 'NR==1 {printf \"%-10s %-6s %-6s %-6s %-12s %-12s %-12s %-12s %-12s %-12s %-12s %s\\n\", \"USER\", \"PID\", \"%CPU\", \"%MEM\", \"VSZ_MB\", \"VSZ_GB\", \"VSZ_TB\", \"RSS_MB\", \"RSS_GB\", \"RSS_TB\", \"START\", \"COMMAND\"} NR>1 {printf \"%-10s %-6s %-6s %-6s %-12.2f %-12.2f %-12.2f %-12.2f %-12.2f %-12.2f %-12s %s\\n\", \$1, \$2, \$3, \$4, \$5/1024, \$5/1048576, \$5/1073741824, \$6/1024, \$6/1048576, \$6/1073741824, \$9, \$11}'"
					enable_auto_refresh_sorter
				fi
                
                command="ps aux --sort=${custom_sort}"
                enable_auto_refresh_sorter
                ;;
            9)
                echo -e "${BOLD}${RED}🚀 Exiting Sorting Menu...${RESET}"
                main_program
                ;;
            *)
                echo -e "${BOLD}${RED}❌ Invalid choice! Please enter a number from 1 to 9.${RESET}"
                ;;
        esac

        echo -e "\n${CYAN}Press Enter to return to the menu...${RESET}"
        read
    done
}

#progress bar (███ style)
draw_progress_bar() {
    local width=30
    local progress=$(($1 * width / 100))
    local remaining=$((width - progress))
    printf "[%s%s] %s%%" "$(printf '█%.0s' $(seq 1 $progress))" "$(printf '░%.0s' $(seq 1 $remaining))" "$1"
}

#banner
show_banner() {
    clear
    echo -e "${BOLD}${YELLOW}"
    echo "███████╗███████╗██████╗ ███████╗ ██████╗ ██████╗ ████████╗"
    echo "██╔════╝██╔════╝██╔══██╗██╔════╝██╔═══██╗██╔══██╗╚══██╔══╝"
    echo "███████╗█████╗  ██████╔╝█████╗  ██║   ██║██████╔╝   ██║   "
    echo "╚════██║██╔══╝  ██╔══██╗██╔══╝  ██║   ██║██╔══██╗   ██║   "
    echo "███████║███████╗██║  ██║███████╗╚██████╔╝██║  ██║   ██║   "
    echo "╚══════╝╚══════╝╚═╝  ╚═╝╚══════╝ ╚═════╝ ╚═╝  ╚═╝   ╚═╝   "
    echo
    echo -e " 🚀 ${WHITE}LINUX Process Monitor${RESET}\n"
}

#display menu
show_menu() {
    echo -e "${BOLD}${WHITE}Select an option:${RESET}"
    echo
    echo -e "${YELLOW}1) Run Processes Report Once"
    echo -e "2) Enable Auto-Refresh Mode"
    echo -e "3) Show Top 10 Processes by CPU Usage"
    echo -e "4) Show Top 10 Processes by Memory Usage"
    echo -e "5) Show Top 10 Processes by start time"
    echo -e "6) Find a process by regexp"
    echo -e "7) Kill a process"
    echo -e "8) Advanced Interactive sorting menu"
    echo
    echo -e "9) Exit${RESET}"
}

#gather process statistics
gather_statistics() {
    total_processes=$(ps aux | wc -l)
    user_processes=$(ps aux | awk '{print $1}' | grep -v "USER" | grep -v "root" | wc -l)
    root_processes=$(ps aux | grep -w "root" | wc -l)
    system_processes=$((total_processes - user_processes - root_processes))

    user_percent=$((user_processes * 100 / total_processes))
    root_percent=$((root_processes * 100 / total_processes))
    system_percent=$((system_processes * 100 / total_processes))

    cpu_usage=$(top -bn1 | grep "Cpu(s)" | awk '{print $2 + $4}')
    mem_usage=$(free -m | awk '/Mem:/ {printf "%.2f", $3/$2 * 100}')

    sorted_users=$(ps aux | awk '{print $1}' | sort | uniq -c | sort -nr)
}

#display process report
display_report() {
    gather_statistics
    echo -e "\n${BOLD}${CYAN}🌟 SYSTEM PROCESS REPORT 🌟${RESET}"
    echo
    echo -e "Generated on: $(date)\n"
    echo
    echo -e "${BOLD}${GREEN}Total Processes: ${WHITE}$total_processes${RESET}"
    echo -e "${BOLD}${CYAN}User Processes: ${WHITE}$user_processes ${RESET} ($(draw_progress_bar $user_percent))"
    echo -e "${BOLD}${YELLOW}System Processes: ${WHITE}$system_processes ${RESET} ($(draw_progress_bar $system_percent))"
    echo -e "${BOLD}${RED}Root Processes: ${WHITE}$root_processes ${RESET} ($(draw_progress_bar $root_percent))\n"

    echo -e "${BOLD}${BLUE}🔹 CPU Usage: ${WHITE}$cpu_usage%${RESET}"
    echo -e "${BOLD}${MAGENTA}🔹 Memory Usage: ${WHITE}$mem_usage%${RESET}\n"

    echo -e "${BOLD}${CYAN}🔍 Top Users by Process Count:${RESET}"
    echo
    echo -e "$sorted_users" | head -10 | awk '{printf "%s: %s processes\n", $2, $1}'
}

#display process report
display_report_refresh() {
    gather_statistics
    echo -e "\n${BOLD}${CYAN}🌟 SYSTEM PROCESS REPORT 🌟${RESET}"
    echo
    echo -e "Generated on: $(date)\n"
    echo
    echo -e "\n${BOLD}${GREEN}✔ Refresh interval in: ${refresh_interval} seconds${RESET}"
    echo
    echo -e "${BOLD}${GREEN}Total Processes: ${WHITE}$total_processes${RESET}"
    echo -e "${BOLD}${CYAN}User Processes: ${WHITE}$user_processes ${RESET} ($(draw_progress_bar $user_percent))"
    echo -e "${BOLD}${YELLOW}System Processes: ${WHITE}$system_processes ${RESET} ($(draw_progress_bar $system_percent))"
    echo -e "${BOLD}${RED}Root Processes: ${WHITE}$root_processes ${RESET} ($(draw_progress_bar $root_percent))\n"

    echo -e "${BOLD}${BLUE}🔹 CPU Usage: ${WHITE}$cpu_usage%${RESET}"
    echo -e "${BOLD}${MAGENTA}🔹 Memory Usage: ${WHITE}$mem_usage%${RESET}\n"

    echo -e "${BOLD}${CYAN}🔍 Top Users by Process Count:${RESET}"
    echo
    echo -e "$sorted_users" | head -10 | awk '{printf "%s: %s processes\n", $2, $1}'
}

#display top processes by CPU with full details
show_top_cpu() {
	echo -e "\n${BOLD}${GREEN}✔ Refresh interval in: ${refresh_interval} seconds${RESET}"
    echo -e "\n${BOLD}${YELLOW}🔥 Top 10 Processes by CPU Usage 🔥${RESET}"
    echo
    ps aux --sort=-%cpu | head -10
}

#display top processes by memory with full details
show_top_memory() {
	echo -e "\n${BOLD}${GREEN}✔ Refresh interval in: ${refresh_interval} seconds${RESET}"	
    echo -e "\n${BOLD}${RED}🧠 Top 10 Processes by Memory Usage 🧠${RESET}"
    echo
    ps aux --sort=-%mem | head -10
}

show_top_start_time() {
	echo -e "\n${BOLD}${GREEN}✔ Refresh interval in: ${refresh_interval} seconds${RESET}"
	echo -e "\n${BOLD}${RED}🧠 Top 10 Processes by start time 🧠${RESET}"
	echo
    ps aux --sort=-start_time | head -10
}

#start_time
enable_auto_refresh_start_time() {
    ask_refresh_no_head

    while true; do
        clear
        show_banner
        display_report
        show_top_start_time
		echo
		echo -e "${CYAN}Press 'E' to return to the main menu.${RESET}"
        # Check if user pressed 'E' (non-blocking)
        read -t "$refresh_interval" -n 1 keypress
        if [[ $keypress == "E" || $keypress == "e" ]]; then
            echo -e "\n${BOLD}${YELLOW}Returning to main menu...${RESET}"
            sleep 1
            main_program
        fi
    done
}

#mem mode
enable_auto_refresh_mem() {
    ask_refresh_no_head

    while true; do
        clear
        show_banner
        display_report
        show_top_memory
		echo
		echo -e "${CYAN}Press 'E' to return to the main menu.${RESET}"
        # Check if user pressed 'E' (non-blocking)
        read -t "$refresh_interval" -n 1 keypress
        if [[ $keypress == "E" || $keypress == "e" ]]; then
            echo -e "\n${BOLD}${YELLOW}Returning to main menu...${RESET}"
            sleep 1
            main_program
        fi
    done
}

#cpu mode
enable_auto_refresh_cpu() {
    ask_refresh_no_head

    while true; do
        clear
        show_banner
        display_report
        show_top_cpu
		echo
		echo -e "${CYAN}Press 'E' to return to the main menu.${RESET}"
        # Check if user pressed 'E' (non-blocking)
        read -t "$refresh_interval" -n 1 keypress
        if [[ $keypress == "E" || $keypress == "e" ]]; then
            echo -e "\n${BOLD}${YELLOW}Returning to main menu...${RESET}"
            sleep 1
            main_program
        fi
    done
}

#auto-refresh mode
enable_auto_refresh() {
    ask_refresh_no_head

    while true; do
        clear
        show_banner
        display_report_refresh
		echo
		echo -e "${CYAN}Press 'E' to return to the main menu.${RESET}"
        # Check if user pressed 'E' (non-blocking)
        read -t "$refresh_interval" -n 1 keypress
        if [[ $keypress == "E" || $keypress == "e" ]]; then
            echo -e "\n${BOLD}${YELLOW}Returning to main menu...${RESET}"
            sleep 1
            main_program
        fi
    done
}

# Main script logic
main_program() {
    while true; do
        show_banner
        show_menu
        echo -e "\n${BOLD}${WHITE}Enter your choice: ${RESET}"
        read choice
        case $choice in
            1)
                clear
                show_banner
                display_report
                echo -e "\n${GREEN}✔ Report generated!${RESET}"
                ;;
            2)
                enable_auto_refresh
                ;;
            3)
                enable_auto_refresh_cpu
                ;;
            4)
                enable_auto_refresh_mem
                ;;
            5)
                enable_auto_refresh_start_time
                ;;
            6)
                find_process
                ;;    
            7)
                kill_process
                ;;
            8)
                process_sorter
                ;;
            9)
                echo -e "${BOLD}${RED}🚀 Exiting...${RESET}"
                exit 0
                
                ;;
            *)
                echo -e "${BOLD}${RED}Invalid option! Try again.${RESET}"
                ;;
        esac
        echo -e "\n${CYAN}Press Enter to return to the main menu...${RESET}"
        read
    done
}

# Start the program
main_program
