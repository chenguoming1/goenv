#!/bin/bash


# 
# source goenv.sh
# 

function goe() {
    GOHOME=${GOHOME:-"$HOME/go"}
    cmd=$1

    case $cmd in 
        # --- A. 名称相关命令 --------------------------------------------------- #
        mk|on)
            # 检查名称是否为空，输出帮助信息。
            if [ -z $2 ]; then
                goe
                return 1
            fi

            name=$2
            dir="$GOHOME/$name"
            dep="$GOHOME/$name/.deps"

            case $cmd in
                mk)
                    # 检查目标目录是否已存在。
                    if [ -d $dir ]; then
                        echo "error: workspace '$name' has exists."
                        return 2
                    fi

                    # 创建目录结构。
                    subs=("src" "pkg" "bin")
                    for sub in ${subs[@]}
                    do
                        mkdir -p "$dir/$sub" "$dep/$sub"
                    done
                    ;;
                on)
                    # 检查是否已经激活某目标。
                    if [ "$GOENV" ]; then
                        goe off
                        goe on $name
                        return
                    fi

                    # 检查目标是否已存在。
                    if [ ! -d $dir ]; then
                        echo "error: workspace '$name' not exists."
                        return 2
                    fi

                    # 保存原设置。
                    export GOOLD_PATH=$PATH    
                    export GOOLD_PS1=$PS1

                    # 导出新设置。
                    export GOENV="$name"
                    export GOPATH="$dep:$dir"
                    export PATH="$dep/bin:$dir/bin:$PATH"
                    export PS1="(go.$name) $PS1"    

                    # 切换目录。
                    goe cd
                    ;;
            esac
            ;;

        # --- B. 状态相关命令 --------------------------------------------------- #
        off|cd|cde|cdw|deps|clean|wipe)
            # 检查是否已处于激活状态。
            if [ ! $GOENV ]; then
                echo "error: no workspace activated."
                return 1
            fi

            dir="$GOHOME/$GOENV"
            src="$dir/src"
            dep="$dir/.deps"

            case $cmd in
                off)
                    # 恢复原设置。
                    export PATH=$GOOLD_PATH
                    export PS1=$GOOLD_PS1

                    # 取消新导出变量。
                    unset GOENV GOPATH GOOLD_PATH GOOLD_PS1
                    ;;
                cd)
                    # 切换到源码目录。
                    cd "$src"
                    ;;
                cde)
                    # 切换到依赖包目录。
                    cd "$dep"
                    ;;
                cdw)
                    # 切换到工作空间目录。
                    cd "$dir"
                    ;;
                deps)
                    # 显示所有第三方包。
                    tree -d -L 3 --noreport "$dep/src"
                    ;;
                clean)
                    # 清除当前目录。
                    p=`pwd`
                    go clean -i

                    # 清除 bin,pkg 目录。
                    subs=("bin" "pkg")
                    for sub in ${subs[@]}
                    do
                        d="$dir/$sub"
                        echo "remove $d ..."
                        cd "$d" && rm -rf *
                    done

                    cd "$p"
                    ;;
                wipe)
                    p=`pwd`

                    # 删除所有第三方包。
                    subs=("src" "pkg" "bin")
                    for sub in ${subs[@]}
                    do
                        d="$dep/$sub"
                        echo "remove $d ..."
                        cd "$d" && rm -rf *
                    done
                    
                    cd "$p"
                    ;;
            esac
            ;;

        # --- C. 无参数命令 --------------------------------------------------- #
        ls|list|home)
            case $cmd in
                ls|list)
                    # 显示所有目标。
                    ls "$GOHOME"
                    ;;
                home)
                    cd "$GOHOME"
                    ;;
            esac
            ;;

        # --- D. 使用帮助 ----------------------------------------------------- #
        *)
            echo "Virtual Workspace Environment for Golang."
            echo ""
            echo "Usage:"
            echo "  goe <command> [arg]"
            echo ""
            echo "Command:"
            echo "  mk <name> : create workspace directory."
            echo "  on <name> : activate workspace."
            echo "  off       : deactivate workspace."
            echo "  cd        : goto src directory."
            echo "  cde       : goto third-party directory."
            echo "  cdw       : goto workspace directory."
            echo "  home      : goto home directory."
            echo "  list      : list all workspaces."
            echo "  deps      : list all third-party packages."
            echo "  clean     : remove object files from all directories."
            echo "  wipe      : remove all third-party packages."
            echo ""
            echo "Q.yuhen, 2014. https://github.com/qyuhen"
            echo ""
            ;;
    esac
}

# 命令参数自动完成。
_goe_complete() {
    cur=${COMP_WORDS[COMP_CWORD]}
    case $COMP_CWORD in
        1)
            # 补全第一命令参数。
            use="mk on off cd cde cdw home ls list deps clean wipe"
            ;;
        2)
            # 补全第二名称参数。
            use=`goe list` # 所有空间名称。
            ;;
    esac

    COMPREPLY=( $( compgen -W "$use" -- $cur ) )
}

complete -o default -o nospace -F _goe_complete goe
