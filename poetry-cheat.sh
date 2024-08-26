#!/bin/bash

clear_screen() {
    clear
}

print_header() {
    echo "Poetry 速查表與執行器"
    echo "===================="
    echo
}

print_menu() {
    echo "請選擇一個類別:"
    echo "1) 安裝與設置"
    echo "2) 項目管理"
    echo "3) 依賴管理"
    echo "4) 環境管理"
    echo "5) 構建與發布"
    echo "6) 其他實用命令"
    echo "0) 退出"
    echo
    echo -n "輸入您的選擇: "
}

execute_command() {
    echo "執行命令: $1"
    echo "-------------------"
    eval $1
    echo "-------------------"
    echo "命令執行完成"
    read -n 1 -s -r -p "按任意鍵繼續..."
}

print_category() {
    clear_screen
    print_header
    echo "$1:"
    echo
    local commands=()
    case $1 in
        "安裝與設置")
            commands+=("poetry install -y:安裝 Poetry")
            ;;
        "項目管理")
            commands+=("poetry new:創建新項目")
            commands+=("poetry init:初始化現有項目")
            ;;
        "依賴管理")
            commands+=("poetry add:添加依賴")
            commands+=("poetry remove:移除依賴")
            commands+=("poetry install:安裝所有依賴")
            commands+=("poetry update:更新依賴")
            ;;
        "環境管理")
            commands+=("poetry shell:進入虛擬環境")
            commands+=("poetry run python:運行 Python 腳本")
            ;;
        "構建與發布")
            commands+=("poetry build:構建項目")
            commands+=("poetry publish:發布項目")
            ;;
        "其他實用命令")
            commands+=("poetry show --tree:查看依賴樹")
            commands+=("poetry export -f requirements.txt --output requirements.txt:導出 requirements.txt")
            commands+=("poetry config --list:查看配置")
            commands+=("poetry config:設置配置")
            ;;
    esac

    for i in "${!commands[@]}"; do
        IFS=':' read -r cmd desc <<< "${commands[$i]}"
        echo "$((i+1))) $cmd - $desc"
    done

    echo "0) 返回主菜單"
    echo
    echo -n "選擇一個命令執行 (或 0 返回): "
    read subchoice

    if [ "$subchoice" != "0" ]; then
        IFS=':' read -r cmd desc <<< "${commands[$subchoice-1]}"
        clear_screen
        print_header
        if [[ $cmd == *"poetry new"* || $cmd == *"poetry add"* || $cmd == *"poetry remove"* || $cmd == *"poetry run python"* || $cmd == *"poetry config"* ]]; then
            echo -n "請輸入命令參數: "
            read params
            cmd="$cmd $params"
        fi
        execute_command "$cmd"
    fi
}

while true; do
    clear_screen
    print_header
    print_menu
    read choice
    case $choice in
        1) print_category "安裝與設置" ;;
        2) print_category "項目管理" ;;
        3) print_category "依賴管理" ;;
        4) print_category "環境管理" ;;
        5) print_category "構建與發布" ;;
        6) print_category "其他實用命令" ;;
        0) echo "謝謝使用,再見!"; exit 0 ;;
        *) echo "無效選擇,請重試." ;;
    esac
done
