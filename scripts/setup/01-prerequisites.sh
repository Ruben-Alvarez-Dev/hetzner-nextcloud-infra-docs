#!/bin/bash
#=============================================================================
# Script: Prerequisites Verification
# Description: Checks system requirements before deployment
# Author: Ruben Alvarez
# License: MIT
#=============================================================================

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Print colored message
print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if running as root
check_root() {
    if [[ $EUID -ne 0 ]]; then
        print_error "This script must be run as root"
        exit 1
    fi
    print_success "Running as root"
}

# Check OS version
check_os() {
    print_info "Checking operating system..."
    
    if [[ -f /etc/os-release ]]; then
        . /etc/os-release
        echo "    OS: $PRETTY_NAME"
        echo "    Version: $VERSION"
        
        if [[ "$ID" != "ubuntu" ]] && [[ "$ID_LIKE" != "ubuntu" ]]; then
            print_warning "This script is designed for Ubuntu/Debian systems"
        fi
    else
        print_error "Cannot determine OS version"
        exit 1
    fi
}

# Check system resources
check_resources() {
    print_info "Checking system resources..."
    
    # CPU Cores
    local cpu_cores=$(nproc --all | grep -c cores)
    echo "    CPU Cores: $cpu_cores"
    
    # Total Memory
    local total_mem=$(free -m | awk '/^Mem:/ {print $2}')
    echo "    Total Memory: ${total_mem}MB"
    
    # Available Memory
    local avail_mem=$(free -m | awk '/^Mem:/ {print $7}')
    echo "    Available Memory: ${avail_mem}MB"
    
    if [[ $avail_mem -lt 1024 ]]; then
        print_warning "Low memory available. Recommended: 2GB+"
    fi
    
    # Disk Space
    local disk_total=$(df -h / | awk 'NR==2 {print $2}')
    local disk_avail=$(df -h / | awk 'NR==2 {print $4}')
    echo "    Disk Total: $disk_total"
    echo "    Disk Available: $disk_avail"
}

# Check network connectivity
check_network() {
    print_info "Checking network connectivity..."
    
    # Check internet connection
    if ping -c 1 8.8.8.8 &> /dev/null 2>&1; then
        print_success "Internet connectivity: OK"
    else
        print_warning "No internet connectivity detected"
    fi
    
    # Check DNS resolution
    if nslookup google.com &> /dev/null 2>&1; then
        print_success "DNS resolution: OK"
    else
        print_warning "DNS resolution issues"
    fi
    
    # Get public IP
    local public_ip=$(curl -s https://api.ipify.org 2>/dev/null)
    if [[ -n "$public_ip" ]]; then
        echo "    Public IP: $public_ip"
    fi
}

# Check required ports
check_ports() {
    print_info "Checking required ports..."
    
    local required_ports=(80 443)
    local available=true
    
    for port in "${required_ports[@]}"; do
        if ss -tln | grep -q ":$port " &> /dev/null; then
            print_warning "Port $port is already in use"
            available=false
        else
            print_success "Port $port is available"
        fi
    done
}

# Check required software
check_software() {
    print_info "Checking required software..."
    
    local required_commands=(
        "curl"
        "wget"
        "git"
        "systemctl"
    )
    
    for cmd in "${required_commands[@]}"; do
        if command -v $cmd &> /dev/null; then
            local version=$($cmd --version 2>&1 | head -1)
            print_success "$cmd: $version"
        else
            print_warning "$cmd: not installed"
        fi
    done
}

# Main execution
main() {
    echo "=========================================="
    echo "  Hetzner Nextcloud - Prerequisites Check"
    echo "=========================================="
    echo ""
    
    check_root
    check_os
    check_resources
    check_network
    check_ports
    check_software
    
    echo ""
    echo "=========================================="
    echo "  Prerequisites check completed!"
    echo "=========================================="
}

main "$@"
