#!/bin/bash

# 
# source pyenv.sh
# 

function pye() {
    PYHOME=${PYHOME:-"$HOME/python"}
    cmd=$1

    case $cmd in 
        # --- A. 名称相关命令 --------------------------------------------------- #
        mk|on)
            # 检查名称是否为空，输出帮助信息。
            if [ -z $2 ]; then
                pye
                return 1
            fi

            name=$2
            dir="$PYHOME/$name"

            case $cmd in
                mk)
                    # 检查目标目录是否已存在。
                    if [ -d $dir ]; then
                        echo "error: venv '$name' has exists."
                        return 2
                    fi

                    # 创建虚拟环境。
                    pyvenv "$dir"
                    ;;
                on)
                    # 检查是否已经激活某目标。
                    if [ "$VIRTUAL_ENV" ]; then
                        pye off
                        pye on $name
                        return
                    fi

                    # 检查目标是否已存在。
                    if [ ! -d $dir ]; then
                        echo "error: venv '$name' not exists."
                        return 2
                    fi

                    # 激活虚拟环境。
                    cd "$dir"
                    source bin/activate
                    ;;
            esac
            ;;

        # --- B. 状态相关命令 --------------------------------------------------- #
        off|cd|cde)
            # 检查是否已处于激活状态。
            if [ ! $VIRTUAL_ENV ]; then
                echo "error: no venv activated."
                return 1
            fi

            case $cmd in
                off)
                    deactivate
                    ;;
                cd)
                    # 切换到源码目录。
                    cd "$VIRTUAL_ENV"
                    ;;
                cde)
                    # 切换到依赖包目录。
                    cd `python -c "import sys; print(sys.path[-1])"`
                    ;;
            esac
            ;;

        # --- C. 无参数命令 --------------------------------------------------- #
        ls|list|home)
            case $cmd in
                ls|list)
                    # 显示所有目标。
                    ls "$PYHOME"
                    ;;
                home)
                    cd "$PYHOME"
                    ;;
            esac
            ;;

        # --- D. 使用帮助 ----------------------------------------------------- #
        *)
            echo "Wrapper for Python 3 Virtual Environment."
            echo ""
            echo "Usage:"
            echo "  pye <command> [arg]"
            echo ""
            echo "Command:"
            echo "  mk <name>  : create venv."
            echo "  on <name>  : activate venv."
            echo "  off        : deactivate."
            echo "  cd         : goto venv directory."
            echo "  cde        : goto site-packages directory."
            echo "  home       : goto project home directory."
            echo "  list       : list all venvs."
            echo ""
            echo "Q.yuhen, 2015. https://github.com/qyuhen"
            echo ""
            ;;
    esac
}

# 命令参数自动完成。
_pye_complete() {
    cur=${COMP_WORDS[COMP_CWORD]}
    case $COMP_CWORD in
        1)
            # 补全第一命令参数。
            use="mk on off cd cde ls list home"
            ;;
        2)
            # 补全第二名称参数。
            use=`pye list` # 所有空间名称。
            ;;
    esac

    COMPREPLY=( $( compgen -W "$use" -- $cur ) )
}

complete -o default -o nospace -F _pye_complete pye
