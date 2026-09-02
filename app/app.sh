#!/bin/bash

case "$1" in

    system-info)
        echo "===== SYSTEM INFORMATION ====="
        echo "Hostname: $(hostname)"
        echo "Current User: $(whoami)"
        echo "Date/Time: $(date)"

        if [ -f /etc/os-release ]; then
            . /etc/os-release
            echo "Operating System: $PRETTY_NAME"
        else
            echo "Operating System: Unknown"
        fi

        echo "Kernel Version: $(uname -r)"
        echo "Uptime: $(uptime -p)"

        echo
        echo "===== CPU INFORMATION ====="
        lscpu

        echo
        echo "===== MEMORY INFORMATION ====="
        free -h

        echo
        echo "===== CURRENT WORKING DIRECTORY ====="
        pwd
        ;;

    check-host)
        host="$2"

        if [ -z "$host" ]; then
            echo "Error: hostname or IP address is required."
            echo "Usage: $0 check-host <host>"
            exit 2
        fi

        echo "===== HOST CHECK ====="
        echo "Host: $host"

        resolved_address=$(getent ahosts "$host" 2>/dev/null | awk 'NR==1 {print $1}')

        if [ -z "$resolved_address" ]; then
            echo "Error: Could not resolve host."
            exit 1
        fi

        echo "Resolved address: $resolved_address"

        if ping -c 1 -W 2 "$host" >/dev/null 2>&1; then
            echo "Connectivity: PASS"
            exit 0
        else
            echo "Connectivity: FAILED"
            exit 1
        fi
        ;;

    check-port)
        host="$2"
        port="$3"

        if [ -z "$host" ]; then
            echo "Error: hostname or IP address is required."
            echo "Usage: $0 check-port <host> <port>"
            exit 2
        fi

        if [ -z "$port" ]; then
            echo "Error: port is required."
            echo "Usage: $0 check-port <host> <port>"
            exit 2
        fi

        if ! [[ "$port" =~ ^[0-9]+$ ]]; then
            echo "Error: port must be numeric."
            exit 2
        fi

        if [ "$port" -lt 1 ] || [ "$port" -gt 65535 ]; then
            echo "Error: port must be between 1 and 65535."
            exit 2
        fi

        echo "===== PORT CHECK ====="
        echo "Host: $host"
        echo "Port: $port"

        if ! getent ahosts "$host" >/dev/null 2>&1; then
            echo "Error: Could not resolve host."
            exit 1
        fi

        if timeout 3 bash -c "</dev/tcp/$host/$port" 2>/dev/null; then
            echo "TCP connectivity: PASS"
            exit 0
        else
            echo "TCP connectivity: FAILED"
            exit 1
        fi
        ;;

    help)
        echo "Usage:"
        echo "$0 system-info"
        echo "$0 check-host <host>"
        echo "$0 check-port <host> <port>"
        echo "$0 help"
        ;;

    "")
        echo "Error: command is required."
        echo "Run '$0 help' for usage."
        exit 2
        ;;

    *)
        echo "Error: invalid command: $1"
        echo "Run '$0 help' for usage."
        exit 2
        ;;

esac
