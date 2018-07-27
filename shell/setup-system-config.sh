#!/bin/bash

# [[file:~/src/github/smartcm/setup-system-config.org::*%E6%9C%80%E7%BB%88%E8%84%9A%E6%9C%AC][the-ultimate-script]]

# All bash scripts should start with ~set -e~ to fail early and loudly.
set -e


atexit() {
    hint "你的 system-config 安装失败了，请参考 http://172.16.2.18/docs/cm/workflow.html#faq 解决此问题"
}

trap atexit ERR

die() {
    echo 1>&2 Error: "$@"
    exit -1
}

info() {
    echo "$@" 1>&2
    sleep 1
}

hint() {
    echo
    echo
    read -p "$@.
    请按‘回车’继续.. "

    echo
    echo
}

function check-system-version() {
    if test "$(lsb_release -s -c)" != trusty; then
        hint "注意：你使用的 Linux 系统版本不是 Ubuntu 14.04，建议考虑切换至该版本，其他版本在安卓编译时可能会有问题"
    fi
}

function sudo() {
    (
        set -o pipefail
        ret=0
        if test "$*" = "apt-get update"; then
            mkdir -p ~/tmp
            if ! command sudo apt-get update 2>&1 | tee ~/tmp/output.$$; then
                ret=1
                if grep 'Hash Sum mismatch' ~/tmp/output.$$; then
                    TMOUT=5 hint "你的 apt-get update 因校验和问题出错了，请参考 http://172.16.2.18/docs/cm/workflow.html#apt-get-update-failed "
                fi
            fi
            rm ~/tmp/output.$$
            exit $ret
        fi

        command sudo "$@"
    )
}

export -f sudo

function setup-git() {
    hint "即将检查 git 是否已安装，若未曾则将安装 git(需 sudo 密码)"
    if ! which git; then
        sudo apt-get update
        sudo apt-get install git
    fi
}

function get-user-name() {
    email=$(git config --global user.email || true)
    while ! [[ $email =~ @smartisan ]]; do
        info "你的公司邮箱地址 ($email) 设置不正确."
        read -p "请输入你的公司邮件地址 (一般是名字全拼@smartisan.com）： " email
        if [[ $email =~ @smartisan ]]; then
            git config --global user.email $email
        fi
    done
    (
        user=$(git config --global user.name || true)
        if test "$user"; then
            exit
        fi

        read -p "请输入你的姓名拼音，以便用于代码提交信息显示（例：Luo Yonghao）：" user
        if test -z "$user"; then
            die "user 名字不能为空"
        fi
        git config --global user.name "$user"
    )
}

function setup-dot-ssh() {
    get-user-name
    if test "$(id -u)" = 0; then
        die "不可以用 root 权限运行此脚本（需要 sudo 的时候脚本自己会 sudo）"
    fi
    if test ! -r ~/.ssh/id_rsa; then
        if test -e ~/.ssh/id_rsa; then
            die "你的 $HOME/.ssh/ 目录下已存在 ssh 私钥，但你无法读取"
        fi
        hint "你没有设置过 ssh 私钥，现在开始设置"
        mkdir -p ~/.ssh
        ssh-keygen -C "$email" -f ~/.ssh/id_rsa
    fi

    if test "$SSH_AUTH_SOCK"; then
        hint "你在运行 ssh-agent 或类似程序，现在把你的 ssh 私钥加入到 agent 中"
        ssh-add ~/.ssh/id_rsa >/dev/null 2>&1 || true
    fi

    if test -f ~/.ssh/config; then
        perl -npe 's,\b172.16.0.9\b,gerrit.smartisan.cn,g' -i ~/.ssh/config
    fi

    if ! grep -q 'gerrit.smartisan.cn smartisan' ~/.ssh/config; then
        mkdir -p ~/.cache/system-config

        cat <<EOF >> ~/.ssh/config
Host gerrit.smartisan.cn smartisan smartisan-gerrit scode
     Port 29418
     User ${email%@*}
     IdentityFile ~/.ssh/id_rsa

Host smartisan smartisan-gerrit scode
     Hostname gerrit.smartisan.cn
EOF
        touch ~/.cache/system-config/ssh-config-done
    fi

    if ! grep -q 'review.smartisan.cn gerrit.smartisan.cn' ~/.ssh/config; then
        email=$(git config user.email)
        mkdir -p ~/.cache/system-config
        cat <<EOF >> ~/.ssh/config
Host review.smartisan.cn gerrit.smartisan.cn
     Port 29418
     User ${email%@*}
     IdentityFile ~/.ssh/id_rsa
EOF
    fi
}



function my-check-for-chengdu() {
    #!/bin/bash
    
    get-ping-time() {
        output=$(timeout 1 ping -c 1 "$1" |
                     perl -ne 'print $1 if m,(?:rtt min/avg/max/mdev|round-trip min/avg/max/stddev) = (.*?)/,')
        if test "$output"; then
            echo "$output"
        else
            echo 5843
        fi
    }
    
    declare -A sites_gerrit_ip
    sites_gerrit_ip[beijing]=172.16.0.9
    sites_gerrit_ip[chengdu]=172.19.0.8
    
    declare -A city_ping_time
    
    for city in "${!sites_gerrit_ip[@]}"; do
        city_ping_time[$city]=$(
            get-ping-time "${sites_gerrit_ip[$city]}"
                      )
    done
    
    if test "${city_ping_time[chengdu]}" = 5843; then
        my_city=beijing
        if perl -e "exit 0 if ${city_ping_time[beijing]} > 20"; then
            (
                for x in $(seq 1 3); do
                    hint "从网络 ping 值来看，你的办公地点既不是成都，也不是北京，一般这样的情况下网络会非常慢，甚致可能无法下载代码，请参考
        http://172.16.2.18/docs/cm/workflow.html#ext-network-git-issue （重要的事情说 $x/3 遍）"
                done
            )
        fi
    else
        my_city=$(
            for city in "${!sites_gerrit_ip[@]}"; do
                perl -e "print '$city' if ${city_ping_time[$city]} < 20";
            done
               )
    
    fi
    
    if test "$my_city" != chengdu -a "$my_city" != beijing; then
        hint "无法自动判断您的当前办公位置是在北京还是在成都，请自己选择（如果在成都，需要使用镜像代码服务器）"
        hint "!!!!! 注意：如果你的办公位置不在北京，也不在成都，很有可能你需要修改一下自己网络的 MTU 配置，具体请参考
    
    http://172.16.2.18/docs/cm/workflow.html#ext-network-git-issue
    "
        my_city=$(
            select-args -p "请选择您的当前办公场所" \
                        "${!sites_gerrit_ip[@]}" || true
               )
    fi
    
    if test "$my_city" != chengdu -a "$my_city" != beijing; then
        hint "你选择的城市不正确，现在将自动帮你设为北京，如果你要同步 Gerrit 代码的话，速度可能会非常慢！"
        my_city=beijing
    fi
    
    if test "$my_city" = chengdu; then
        if ! grep -q '^172.19.0.8 gerrit.smartisan.cn$' /etc/hosts; then
            hint "需要帮您把 gerrit.smartisan.cn 的 ip 地址设为成都的镜像，可能需要输入 sudo 密码"
            echo 172.19.0.8 gerrit.smartisan.cn | sudo tee -a /etc/hosts
        fi
    elif test "$my_city" = beijing; then
        if grep -q '^172.19.0.8 gerrit.smartisan.cn$' /etc/hosts; then
            hint "你在 /etc/hosts 里设置了成都的 gerrit.smartisan.cn 镜像 ip 地址，但现在办公地点在北京，将帮您自动删除此 ip 设置（可能要输 sudo 密码）"
            sudo perl -ne 'print unless m/^172.19.0.8 gerrit.smartisan.cn$/' -i /etc/hosts
        fi
    fi
    
}


    function check-ssh-ok() {
        info "测试 gerrit 代码服务器连接..."
        local try_number=1
        while ! ssh gerrit.smartisan.cn 2>&1 | grep -q 'Welcome to Gerrit Code Review'; do
            hint "无法连接到 gerrit 代码服务器，请检查 ssh 私钥、配置、 ~/.ssh
  /config 以及是否已经把 ssh 公钥$(echo; echo; cat ~/.ssh/id_rsa.pub; echo; echo \ )添加到 gerrit（请访问 https://review.smartisan.cn:8080/#/settings/ssh-keys 点击“Add Key...”将上面的公钥内容拷贝、粘贴进去）。

注意：

1. 第一次访问 gerrit 网页的话，浏览器会显示 https 证书安全问题，请参考 http://172.16.2.18/docs/cm/workflow.html#faq-https 并加以解决

2. 第一次 ssh 连接 Gerrit 服务器的话，会提示服务器的公钥证书尚未确认：

        The authenticity of host '[gerrit.smartisan.cn]:29418 ([172.16.0.9]:29418)' can't be established.
        ECDSA key fingerprint is SHA256:kOLkj+rZqB8X73I5mtFCGldwKcQC66LKoeK/8X1srCY.
        Are you sure you want to continue connecting (yes/no)?

   请确保输入 Yes 再回车——直接回车是不行的。

   （配置完 system-config 后，你会经常碰到可以直接回车的 Yes/no 或 yes/No 的问题，请注意大写的是默认的选项。但这里的要不要接受 ssh key 的问题事关安全，它要求你必须手动输入 yes）。
"

            ((try_number++)) || true

            if test "$my_city" != beijing; then
                hint "注意：系统检测到你在 $my_city 的办公室，这种情况下，你在 https://review.smartisan.cn:8080/#/settings/ssh-keys 里添加完 ssh 公钥之后，系统把信息从北京服务器同步到 $my_city 的镜像服务器，可能需要几秒钟到几分钟时间，请稍微多等一会儿再试。并且请注意，每次你加一个新的 ssh 公钥，都需要时间重新同步。

  如果等待时间超过 10 分钟的话还不行的话，请考虑给 cms@smartisan.com 发邮件并抄送给你的 Leader 来反馈这个问题。"
                for i in $(seq 1 5); do
                    echo -n .
                    sleep 1
                done
                echo
            fi

            if test "$try_number" -gt 3; then
                echo
                echo
                hint "如果你确认已经添加公钥，但还是不停提示无法连接，请确认你的 ~/.ssh/config 里配置的 gerrit ssh 用户名（$(ssh -v gerrit.smartisan.cn 2>&1|tr -d '\r'|grep 'Authenticating to.*as'|grep -o '\S+.$' -P)）与你的 Gerrit 网页 https://review.smartisan.cn:8080/#/settings/ 上显示的 username 一致。某些早期员工，其 username 并非其邮件前缀。这种情况下，请打开 ~/.ssh/config 文件，并手动编辑相关的 Username 设置与 Gerrit 系统一致。如有疑问，请找 CM 协助（可以给 cms@smartisan.com 发邮件）"
            fi
        done
        info "gerrit 代码下载服务器连接测试通过"
        return 0
    }

function setup-jdk6() {
    if test ! -e ~/external/bin/Linux/ext/jdk/bin/java; then
        hint "即将从 gerrit 服务器获取 jdk6"
        mkdir -p ~/external/bin/Linux/ext/
        if ! git clone $git_clone_args smartisan:tools/jdk6 ~/external/bin/Linux/ext/jdk; then
            hint "无法同步 jdk，可能您的 ldap 组设置有问题，请联系 IT 确认你的 ldap 组不是 软件研发中心，这个组人太多，不能开放代码访问"
            hint "等 ldap 组设置正确之后，请用你的公司域账号登录一下 http://172.16.2.18:8080/job/FlushGerritCache/build?delay=0sec ，这个任务执行之后，在代码服务器上你的身份信息会被更新"
            hint "然后重试一遍这个配置脚本，如果还有问题，再联系 CM。"
            exit 1
        fi
    fi
}

function setup-ext-local() {
    if test ! -d ~/external/local/.git; then
        hint "即将从 gerrit 服务器获取 ~/external/local"
        rmdir ~/external/local >/dev/null 2>&1 || true
        git clone $git_clone_args smartisan:baohaojun/ext-local ~/external/local
    fi

    if test "$(readlink -f ~/external/local)" != "$(readlink -f /home/bhj/external/local)" -a ! -d /home/bhj/external/local; then
        hint "即将为你配置 ~/external/local，可能会需要输入你的 sudo 密码"
        # 必须保证能在 /home/bhj 目录下找到我的库文件。
        sudo ln -sf ~ /home/bhj
    fi
}

function get-system-config() {
    hint "即将获取 system-config 系统配置软件，更多信息请访问 http://baohaojun.github.io/blog/2014/12/10/0-systetm-config-usage-guide.html ."
    if test ! -d ~/system-config/.git; then
        git clone $git_clone_args smartisan:baohaojun/system-config ~/system-config
    else
        (
            cd ~/system-config/
            git pull
        )
    fi
    hint "即将配置 system-config，最后一步会安装安卓编译所需.deb 软件包，可能会需要输入你的 sudo 密码"
    ~/system-config/bin/after-co-ln-s.sh
    ~/src/github/smartcm/smartcm-update

    if test ! -e ~/.config/system-config/no-system-config; then
        hint "即将启动新的 bash，使 system-config 生效"
        unset FORCE_NO_SYSTEM_CONFIG
        . ~/system-config/.bashrc || true
        sc start || true
    fi
    exit 0
}
function publish() {
     if org-tangle-it ~/src/github/smartcm/setup-system-config.org ~/src/github/smartcm/setup-system-config.sh || true; then
        (
            cd ~/src/github/smartcm
            grep -v -P '^\s*#\s+after-save-hook:' setup-system-config.org > ~/src/github/smartisan-blog/blog/2015/06/25/setup-system-config.org
            psync gerrit setup-system-config.sh
        )
    fi
}
## start code-generator "^\\s *#\\s *"
# generate-getopt xdebug ttestsmartcm h:SMARTCM_REMOTE_HOST ddryrun XDEBUG @:git-clone-args
## end code-generator
## start generated code
TEMP=$( getopt -o Xh:xdth \
               --long DEBUG,SMARTCM_REMOTE_HOST:,debug,dryrun,git-clone-args:,testsmartcm,help,no-DEBUG,no-debug,no-dryrun,no-testsmartcm \
               -n $(basename -- $0) -- "$@")
DEBUG=false
SMARTCM_REMOTE_HOST=
debug=false
dryrun=false
git_clone_args=
testsmartcm=false
eval set -- "$TEMP"
while true; do
    case "$1" in

        -X|--DEBUG|--no-DEBUG)
            if test "$1" = --no-DEBUG; then
                DEBUG=false
            else
                DEBUG=true
            fi
            shift
            ;;
        -h|--SMARTCM_REMOTE_HOST)
            SMARTCM_REMOTE_HOST=$2
            shift 2
            ;;
        -x|--debug|--no-debug)
            if test "$1" = --no-debug; then
                debug=false
            else
                debug=true
            fi
            shift
            ;;
        -d|--dryrun|--no-dryrun)
            if test "$1" = --no-dryrun; then
                dryrun=false
            else
                dryrun=true
            fi
            shift
            ;;
        --git-clone-args)
            git_clone_args=$2
            shift 2
            ;;
        -t|--testsmartcm|--no-testsmartcm)
            if test "$1" = --no-testsmartcm; then
                testsmartcm=false
            else
                testsmartcm=true
            fi
            shift
            ;;
        -h|--help)
            set +x
            echo -e
            echo
            echo Options and arguments:
            printf %06s '-X, '
            printf %-24s '--[no-]DEBUG'
            echo
            printf %06s '-h, '
            printf %-24s '--SMARTCM_REMOTE_HOST=SMARTCM_REMOTE_HOST'
            echo
            printf %06s '-x, '
            printf %-24s '--[no-]debug'
            echo
            printf %06s '-d, '
            printf %-24s '--[no-]dryrun'
            echo
            printf "%06s" " "
            printf %-24s '--git-clone-args=GIT_CLONE_ARGS'
            echo
            printf %06s '-t, '
            printf %-24s '--[no-]testsmartcm'
            echo
            exit
            shift
            ;;
        --)
            shift
            break
            ;;
        *)
            die "internal error"
            ;;
    esac
done


## end generated code

if test "$debug" = true; then
    export xdebug=true
    set -x
elif test "$DEBUG" = true; then
    export xdebug=true
    set -x
    if echo $SHELLOPTS | grep -q xtrace; then
        export SHELLOPTS
    fi
else
    unset xdebug
fi

me=$0
if test ! -e "$me"; then
    me=$(which $0 || true)
fi
if test $# = 0; then
    hint "即将为您一键配置安卓开发环境（含 system-config），更多详情请访问：http://172.16.21.238/baohaojun/blog/2015/06/25/setup-system-config.html"
    hint "如果配置过程中碰到问题，或在研发工作中有流程相关的问题，请参考：http://172.16.2.18/docs/cm/workflow.html（建议在浏览器中收藏此页面）"
    my-check-for-chengdu
    check-system-version
    setup-git
    setup-dot-ssh
    check-ssh-ok
    setup-jdk6
    setup-ext-local
    get-system-config
elif grep -q -P "^\s*function $1\s*\(" "$me" || test "$(basename $0)" = "$1"; then
    command=$1
    shift
    smartcm_command=("$command" "$@")
    "$command" "$@"
else
    die "'$1': smartcm command not found"
fi
# Local Variables: #
# eval: (read-only-mode 1) #
# End: #

# the-ultimate-script ends here
