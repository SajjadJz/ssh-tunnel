#!/bin/bash

# Colors
CYAN="\e[36m"
GREEN="\e[32m"
YELLOW="\e[33m"
RED="\e[31m"
BLUE="\e[34m"
NC="\e[0m"
WHITE="\e[0m"

# Function to continue after pressing Enter
press_enter() {
    echo -e "\n ${RED}Press Enter to continue... ${NC}"
    read
}

# Check if script is being run as root
if [ "$EUID" -ne 0 ]; then
    echo "This script must be run as root."
    exit 1
fi

# Calculate title width and padding
clear
title_text="Create By OPIran\nTG-Group @OPIranCluB"
term_width=$(tput cols)
title_width=${#title_text}
padding=$(( (term_width - title_width) / 2 ))

# Display the floating title
echo -ne "${BLUE}"
for ((i = 0; i < padding; i++)); do echo -n " "; done
echo -e "${title_text}"
for ((i = 0; i < padding; i++)); do echo -n " "; done
echo -e "${NC}"

# Prompt for destination port
echo -ne "${YELLOW}Enter the destination port (SSH / V2ray) (service on your foreign VPS):${NC} "
read port_config_kharej

# Prompt for destination IP address
echo -ne "${YELLOW}Enter the destination IP address (2nd VPS or Foreign VPS):${NC} "
read ip_kharej

# Prompt for source port
echo -ne "${YELLOW}Enter the source port for tunnel (Local VPS):${NC} "
read port_tunnel

# Prompt for destination username
echo -ne "${YELLOW}Enter the destination username (e.g., root):${NC} "
read remote_user

# Prompt for script path
echo -ne "${YELLOW}Give me the path of this script (ex. /etc/direct-tunnel.sh):${NC} "
read path

# Check if SSH key pair exists
if [ ! -f ~/.ssh/id_rsa ]; then
    echo -e "${YELLOW}Generating SSH key pair...${NC}"
    ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa -N ""
fi

# Copy SSH public key to remote server for passwordless authentication
ssh-copy-id ${remote_user}@${ip_kharej}
echo -e "${GREEN}SSH public key save to remote server successfully${NC}"

# Set up SSH tunnel command
ssh_tunnel_command="ssh -N -L *:${port_tunnel}:localhost:${port_config_kharej} ${remote_user}@${ip_kharej}"

# Run the SSH tunnel command
echo -e "${GREEN}Setting up SSH tunnel...${NC}"
$ssh_tunnel_command

# Add the SSH tunnel command to the user's cron job
cron_command="@reboot $ssh_tunnel_command"
(crontab -l ; echo "$cron_command") | crontab -

echo -e "${GREEN}SSH tunnel set up and added to cron job.${NC}"
echo -e "${YELLOW}The SSH tunnel will be established on system startup.${NC}"

# Allow the user to press Enter to continue
press_enter

# Systemd service definition
echo "[Unit]
Description=OPIran Setup SSH Tunnel on Startup
After=network.target

[Service]
ExecStart=${path}
Restart=on-failure
User=your_username

[Install]
WantedBy=multi-user.target" > /etc/systemd/system/ssh-tunnel.service

# Reload systemd and start the service
systemctl daemon-reload
systemctl start ssh-tunnel
systemctl enable ssh-tunnel

# Allow the user to press Enter to continue
press_enter
