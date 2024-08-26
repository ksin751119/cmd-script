#!/bin/bash

# 檢查腳本是否通過 source 執行
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    echo "請使用 'source $0' 或 '. $0' 來運行此腳本"
    exit 1
fi

# 檢查當前是否有虛擬環境被激活
if [ -n "$VIRTUAL_ENV" ]; then
    echo "當前激活的虛擬環境: $VIRTUAL_ENV"
fi

check_pyenv_virtualenv() {
    if ! command -v pyenv >/dev/null 2>&1; then
        echo "pyenv 未安裝或未正確配置。"
        echo "請確保已安裝 pyenv 並在您的 shell 配置文件中添加了以下行："
        echo "eval \"$(pyenv init -)\""
        return 1
    fi

    if ! pyenv commands | grep -q virtualenv-init; then
        echo "pyenv-virtualenv 未安裝或未正確配置。"
        echo "請運行 'brew install pyenv-virtualenv' 安裝，"
        echo "然後確保在您的 shell 配置文件中添加了以下行："
        echo "eval \"$(pyenv virtualenv-init -)\""
        return 1
    fi

    eval "$(pyenv init -)"
    eval "$(pyenv virtualenv-init -)"
    return 0
}

list_environments() {
    echo "DEBUG: 開始列出虛擬環境"
    local seen=()
    local current_env=$(basename "$VIRTUAL_ENV" 2>/dev/null)
    while IFS= read -r line; do
        if [[ $line == *"(set by"* ]]; then
            continue
        fi
        env_name=$(echo "$line" | awk '{print $1}')
        short_name=$(basename "$env_name")
        if [[ ! " ${seen[*]} " =~ " ${short_name} " ]]; then
            if [[ "$short_name" == "$current_env" ]]; then
                echo "* $short_name (當前激活)"
            else
                echo "  $short_name"
            fi
            seen+=("$short_name")
        fi
    done < <(pyenv virtualenvs)
    echo "DEBUG: 虛擬環境列表完成"
}

virtual_env_menu() {
    local opt
    while true; do
        echo "虛擬環境管理"
        echo "1) 列出所有虛擬環境"
        echo "2) 創建新的虛擬環境"
        echo "3) 激活虛擬環境"
        echo "4) 退出當前虛擬環境"
        echo "5) 刪除虛擬環境"
        echo "b) 返回主菜單"
        echo "選擇一個選項："
        read -r opt
        echo "DEBUG: 用戶在虛擬環境菜單中選擇了選項: $opt"
        case $opt in
            1)
                if check_pyenv_virtualenv; then
                    echo "DEBUG: 列出所有虛擬環境"
                    list_environments
                fi
                ;;
            2)
                if check_pyenv_virtualenv; then
                    echo "可用的 Python 版本："
                    pyenv versions --bare
                    echo "輸入要使用的 Python 版本："
                    read -r version
                    echo "輸入新環境的名稱："
                    read -r name
                    echo "DEBUG: 創建新虛擬環境: $version $name"
                    pyenv virtualenv "$version" "$name"
                fi
                ;;
            3)
                if check_pyenv_virtualenv; then
                    echo "DEBUG: 開始激活虛擬環境流程"
                    echo "可用的虛擬環境："
                    list_environments
                    echo "輸入要激活的環境名稱："
                    read -r env_name
                    if [ -n "$env_name" ]; then
                        echo "DEBUG: 嘗試激活環境: $env_name"
                        if source "$HOME/.pyenv/versions/$env_name/bin/activate"; then
                            echo "成功激活環境: $env_name"
                        else
                            echo "激活失敗，請確保環境名稱正確。"
                        fi
                    else
                        echo "未輸入環境名稱，取消操作"
                    fi
                fi
                ;;
            4)
                if [ -n "$VIRTUAL_ENV" ]; then
                    echo "DEBUG: 退出當前虛擬環境"
                    deactivate
                    echo "已退出虛擬環境"
                else
                    echo "當前沒有激活的虛擬環境"
                fi
                ;;
            5)
                if check_pyenv_virtualenv; then
                    echo "DEBUG: 開始刪除虛擬環境流程"
                    echo "可用的虛擬環境："
                    list_environments
                    echo "輸入要刪除的虛擬環境名稱："
                    read -r env_name
                    if [ -n "$env_name" ]; then
                        echo "確定要刪除 $env_name 嗎？(y/n)"
                        read -r confirm
                        if [[ $confirm == [Yy] ]]; then
                            echo "DEBUG: 刪除環境: $env_name"
                            pyenv uninstall "$env_name" || echo "刪除失敗，請確保環境名稱正確。"
                        else
                            echo "取消刪除操作"
                        fi
                    else
                        echo "未輸入環境名稱，取消操作"
                    fi
                fi
                ;;
            b) echo "DEBUG: 返回主菜單"; return ;;
            *) echo "無效選項" ;;
        esac
        echo "按 Enter 鍵繼續..."
        read -r
    done
}

pyenv_interactive() {
    local opt
    while true; do
        echo "pyenv 互動式指令菜單"
        echo "1) 查看可安裝的 Python 版本"
        echo "2) 安裝特定版本的 Python"
        echo "3) 設置全局 Python 版本"
        echo "4) 設置本地 Python 版本"
        echo "5) 查看當前 Python 版本"
        echo "6) 列出所有已安裝的版本"
        echo "7) 虛擬環境管理"
        echo "8) 更新 pyenv"
        echo "q) 退出"
        echo "選擇一個選項："
        read -r opt
        echo "DEBUG: 用戶在主菜單中選擇了選項: $opt"
        case $opt in
            1) pyenv install --list | less ;;
            2)
                echo "輸入要安裝的 Python 版本（例如 3.9.5）："
                read -r version
                pyenv install "$version"
                ;;
            3)
                echo "輸入要設置為全局的 Python 版本："
                read -r version
                pyenv global "$version"
                ;;
            4)
                echo "輸入要設置為本地的 Python 版本："
                read -r version
                pyenv local "$version"
                ;;
            5) pyenv version ;;
            6) pyenv versions ;;
            7) virtual_env_menu ;;
            8) brew upgrade pyenv ;;
            q) echo "退出程序"; return 0 ;;
            *) echo "無效選項" ;;
        esac
        echo "按 Enter 鍵繼續..."
        read -r
    done
}

pyenv_interactive
return 0
