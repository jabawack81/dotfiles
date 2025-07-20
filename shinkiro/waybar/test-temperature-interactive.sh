#!/bin/bash

# Colors for TUI
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color
BOLD='\033[1m'

# Default values
CPU_TEMP=45000
GPU_TEMP=45000

# Function to display temperature with color
show_temp() {
    local temp_c=$((temp / 1000))
    local color=$GREEN
    local status="Normal"
    
    if [ $temp_c -ge 80 ]; then
        color=$RED
        status="Critical"
    elif [ $temp_c -ge 60 ]; then
        color=$YELLOW
        status="Warning"
    fi
    
    echo -e "${color}${temp_c}°C (${status})${NC}"
}

# Function to display header
show_header() {
    clear
    echo -e "${BLUE}${BOLD}╔════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}${BOLD}║     Waybar Temperature Test Utility        ║${NC}"
    echo -e "${BLUE}${BOLD}╚════════════════════════════════════════════╝${NC}"
    echo
}

# Function to display current settings
show_current_settings() {
    local cpu_c=$((CPU_TEMP / 1000))
    local gpu_c=$((GPU_TEMP / 1000))
    
    echo -e "${CYAN}Current Settings:${NC}"
    echo -n "  CPU: "
    temp=$CPU_TEMP
    show_temp
    echo -n "  GPU: "
    temp=$GPU_TEMP
    show_temp
    echo
}

# Function to set custom temperature
set_custom_temp() {
    local device=$1
    local current=$2
    local current_c=$((current / 1000))
    
    echo -e "${CYAN}Set ${device} Temperature${NC}"
    echo -e "Current: ${current_c}°C"
    echo -n "Enter new temperature (°C): "
    read -r new_temp
    
    # Validate input
    if [[ $new_temp =~ ^[0-9]+$ ]]; then
        echo $((new_temp * 1000))
    else
        echo -e "${RED}Invalid input! Using current value.${NC}"
        sleep 1
        echo $current
    fi
}

# Main menu
while true; do
    show_header
    show_current_settings
    
    echo -e "${CYAN}${BOLD}Quick Presets:${NC}"
    echo "  1) Normal      - CPU: 45°C, GPU: 45°C"
    echo "  2) Warm        - CPU: 55°C, GPU: 55°C"
    echo "  3) Warning     - CPU: 65°C, GPU: 70°C"
    echo "  4) Hot         - CPU: 75°C, GPU: 75°C"
    echo "  5) Critical    - CPU: 85°C, GPU: 90°C"
    echo
    echo -e "${CYAN}${BOLD}Custom Settings:${NC}"
    echo "  6) Set custom CPU temperature"
    echo "  7) Set custom GPU temperature"
    echo
    echo -e "${CYAN}${BOLD}Actions:${NC}"
    echo "  8) Test scripts (show output)"
    echo "  9) Apply temperature changes (waybar will update in ~2s)"
    echo "  t) Toggle test mode (currently: $([ -f /tmp/waybar-temp-test.conf ] && echo -e "${GREEN}ON${NC}" || echo -e "${RED}OFF${NC}"))"
    echo "  0) Exit"
    echo
    echo -n "Select option: "
    
    read -r choice
    
    case $choice in
        1)
            CPU_TEMP=45000
            GPU_TEMP=45000
            echo "WAYBAR_CPU_TEMP=$CPU_TEMP" > /tmp/waybar-temp-test.conf
            echo "WAYBAR_GPU_TEMP=$GPU_TEMP" >> /tmp/waybar-temp-test.conf
            echo -e "${GREEN}Normal preset applied!${NC}"
            sleep 1
            ;;
        2)
            CPU_TEMP=55000
            GPU_TEMP=55000
            echo "WAYBAR_CPU_TEMP=$CPU_TEMP" > /tmp/waybar-temp-test.conf
            echo "WAYBAR_GPU_TEMP=$GPU_TEMP" >> /tmp/waybar-temp-test.conf
            echo -e "${GREEN}Warm preset applied!${NC}"
            sleep 1
            ;;
        3)
            CPU_TEMP=65000
            GPU_TEMP=70000
            echo "WAYBAR_CPU_TEMP=$CPU_TEMP" > /tmp/waybar-temp-test.conf
            echo "WAYBAR_GPU_TEMP=$GPU_TEMP" >> /tmp/waybar-temp-test.conf
            echo -e "${YELLOW}Warning preset applied!${NC}"
            sleep 1
            ;;
        4)
            CPU_TEMP=75000
            GPU_TEMP=75000
            echo "WAYBAR_CPU_TEMP=$CPU_TEMP" > /tmp/waybar-temp-test.conf
            echo "WAYBAR_GPU_TEMP=$GPU_TEMP" >> /tmp/waybar-temp-test.conf
            echo -e "${YELLOW}Hot preset applied!${NC}"
            sleep 1
            ;;
        5)
            CPU_TEMP=85000
            GPU_TEMP=90000
            echo "WAYBAR_CPU_TEMP=$CPU_TEMP" > /tmp/waybar-temp-test.conf
            echo "WAYBAR_GPU_TEMP=$GPU_TEMP" >> /tmp/waybar-temp-test.conf
            echo -e "${RED}Critical preset applied!${NC}"
            sleep 1
            ;;
        6)
            CPU_TEMP=$(set_custom_temp "CPU" $CPU_TEMP)
            echo "WAYBAR_CPU_TEMP=$CPU_TEMP" > /tmp/waybar-temp-test.conf
            echo "WAYBAR_GPU_TEMP=$GPU_TEMP" >> /tmp/waybar-temp-test.conf
            echo -e "${GREEN}Custom CPU temperature applied!${NC}"
            sleep 1
            ;;
        7)
            GPU_TEMP=$(set_custom_temp "GPU" $GPU_TEMP)
            echo "WAYBAR_CPU_TEMP=$CPU_TEMP" > /tmp/waybar-temp-test.conf
            echo "WAYBAR_GPU_TEMP=$GPU_TEMP" >> /tmp/waybar-temp-test.conf
            echo -e "${GREEN}Custom GPU temperature applied!${NC}"
            sleep 1
            ;;
        8)
            show_header
            echo -e "${CYAN}Testing scripts with current values...${NC}"
            echo
            # Write test values to file
            echo "WAYBAR_CPU_TEMP=$CPU_TEMP" > /tmp/waybar-temp-test.conf
            echo "WAYBAR_GPU_TEMP=$GPU_TEMP" >> /tmp/waybar-temp-test.conf
            
            echo -e "${BOLD}CPU Temperature:${NC}"
            ./temperature-cpu.sh
            echo
            echo -e "${BOLD}GPU Temperature:${NC}"
            ./temperature-gpu.sh
            echo
            echo -e "${BOLD}CPU Arrow Before:${NC}"
            ./arrow-cpu-before.sh
            echo
            echo -e "${BOLD}GPU Arrow Before:${NC}"
            ./arrow-gpu-before.sh
            echo
            
            # Clean up
            rm -f /tmp/waybar-temp-test.conf
            echo -e "\n${GREEN}Press Enter to continue...${NC}"
            read -r
            ;;
        9)
            show_header
            echo -e "${CYAN}Applying temperature values...${NC}"
            echo -e "CPU: $((CPU_TEMP / 1000))°C"
            echo -e "GPU: $((GPU_TEMP / 1000))°C"
            echo
            
            # Write test values to file
            echo "WAYBAR_CPU_TEMP=$CPU_TEMP" > /tmp/waybar-temp-test.conf
            echo "WAYBAR_GPU_TEMP=$GPU_TEMP" >> /tmp/waybar-temp-test.conf
            
            echo -e "${GREEN}✓ Test values applied!${NC}"
            echo -e "${YELLOW}Waybar will update automatically within ~2 seconds.${NC}"
            echo
            echo -e "Test mode is now ${GREEN}ACTIVE${NC}"
            echo -e "To disable test mode, press 't' or remove /tmp/waybar-temp-test.conf"
            echo
            echo -e "${GREEN}Press Enter to continue...${NC}"
            read -r
            ;;
        t|T)
            if [ -f /tmp/waybar-temp-test.conf ]; then
                rm -f /tmp/waybar-temp-test.conf
                echo -e "${GREEN}Test mode disabled. Waybar will use real sensors.${NC}"
            else
                echo "WAYBAR_CPU_TEMP=$CPU_TEMP" > /tmp/waybar-temp-test.conf
                echo "WAYBAR_GPU_TEMP=$GPU_TEMP" >> /tmp/waybar-temp-test.conf
                echo -e "${GREEN}Test mode enabled with current values.${NC}"
                echo -e "${YELLOW}Restart waybar to see changes.${NC}"
            fi
            sleep 2
            ;;
        0)
            echo -e "${GREEN}Goodbye!${NC}"
            exit 0
            ;;
        *)
            echo -e "${RED}Invalid option!${NC}"
            sleep 1
            ;;
    esac
done