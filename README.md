
#goenv

为 Golang 项目创建隔离的虚拟环境，包括创建独立目录，设置 GOPATH 环境变量。
参考了 [virtualenvwrapper](https://bitbucket.org/dhellmann/virtualenvwrapper/)、[goenv](https://github.com/crsmithdev/goenv) 等项目源码。

---

**使用**: 

1. 下载 goenv.sh 文件。

2. 在启动文件中添加类似以下内容 (注意调整路径)。

    ```
    export GOHOME=$HOME/myprojects
    source goenv.sh
    ```

3. 可使用 source 命令使其立即生效。

4. 输入 goe 显示帮助信息。
