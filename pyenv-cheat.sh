#!/bin/bash

pyenv_cheat() {
    local opt
    while true; do
        echo "pyenv Cheat Sheet"
        echo "1) List available Python versions"
        echo "2) Install a specific Python version"
        echo "3) Set global Python version"
        echo "4) Set local Python version"
        echo "5) Check current Python version"
        echo "6) List all installed versions"
        echo "7) Create a virtual environment"
        echo "8) Activate a virtual environment"
        echo "9) Deactivate virtual environment"
        echo "10) Uninstall a Python version"
        echo "11) Update pyenv"
        echo "12) List all virtual environments"
        echo "13) Check global Python version"
        echo "14) Check local Python version"
        echo "15) Check pyenv root directory"
        echo "q) Quit"
        echo "Choose an option:"
        read -r opt
        case $opt in
            1) pyenv install --list | less ;;
            2) echo "Enter the Python version to install (e.g., 3.9.0):"; read -r version; pyenv install "$version" ;;
            3) echo "Enter the Python version to set as global:"; read -r version; pyenv global "$version" ;;
            4) echo "Enter the Python version to set as local:"; read -r version; pyenv local "$version" ;;
            5) pyenv version ;;
            6) pyenv versions ;;
            7)
                if command -v pyenv-virtualenv >/dev/null 2>&1; then
                    echo "Enter Python version and environment name (e.g., 3.9.0 myproject):"; read -r version name; pyenv virtualenv "$version" "$name"
                else
                    echo "pyenv-virtualenv is not installed or not properly configured. Please install and configure it before trying again."
                fi
                ;;
            8)
                if command -v pyenv-virtualenv >/dev/null 2>&1; then
                    echo "Enter the name of the environment to activate:"; read -r name; pyenv activate "$name"
                else
                    echo "pyenv-virtualenv is not installed or not properly configured. Please install and configure it before trying again."
                fi
                ;;
            9)
                if command -v pyenv-virtualenv >/dev/null 2>&1; then
                    pyenv deactivate
                else
                    echo "pyenv-virtualenv is not installed or not properly configured. Please install and configure it before trying again."
                fi
                ;;
            10) echo "Enter the Python version to uninstall:"; read -r version; pyenv uninstall "$version" ;;
            11) brew upgrade pyenv ;;
            12) ls -1 "$(pyenv root)/versions" | grep envs ;;
            13) pyenv global ;;
            14) pyenv local ;;
            15) pyenv root ;;
            q) echo "Exiting program"; return 0 ;;
            *) echo "Invalid option" ;;
        esac
        echo "Press Enter to continue..."
        read -r
    done
}

pyenv_cheat
