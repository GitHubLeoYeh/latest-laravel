#!/bin/bash
# Latest-laravel 更新脚本
# @author Carlos <anzhengchao@gmail.com>
# @link   http://github.com/overtrue


# latest-laravel
SCRIPT_DIR=/root/latest-laravel/scripts
ROOT_DIR=${SCRIPT_DIR}/../

#filename
MASTER_FILE="laravel-master.tar.gz"
DEVELOP_FILE="laravel-develop.tar.gz"

# 更新并安装
latest_and_install()
{
    cd $ROOT_DIR/
    git pull
    rm -rf laravel
    echo ""
    echo "*** 切换分支：$1 ***"
    echo "branch:$1";
    git clone https://github.com/laravel/laravel && \
    cd laravel && git checkout $1 && composer install
}

# 打包
make_zip()
{
    latest_and_install $1

    if [[ $? -eq 0 ]]; then
        echo "*** 开始打包：$2 ***"
        cd $ROOT_DIR && \
        rm -f $2 && \
        tar zcf $2 laravel/*
        rm -rf laravel
        echo "*** 打包完毕：$2 ***"
    fi
}

# 提交到latest-laravel
commit_zip()
{
    cd $ROOT_DIR
    echo "当前目录:`pwd`"
    git add *.gz && \
    git commit -am "update@$(date +%Y-%m-%d_%H%M%S)" && \
    git pull && \
    git push
}

# 检查错误并提交
check_and_commit()
{
    if [[ $? != 0 ]]; then
        echo "*** 错误：$? ***"
        exit
    else
        commit_zip
    fi
}

# 报告错误(issue)
report_error()
{
    cd $SCRIPT_DIR
    `node reporter.js`
}


# master
master_output=$(make_zip "master" $MASTER_FILE)

if [[ $? -eq 0 ]]; then
    echo "$master_output" 2>&1 | tee $SCRIPT_DIR/output
fi

# master
develop_output=$(make_zip "develop" $DEVELOP_FILE)

if [[ $? -eq 0 ]]; then
    echo "$develop_output"  2>&1 | tee $SCRIPT_DIR/output
fi

check_and_commit

if [[ -f "$SCRIPT_DIR/output" ]]; then
    report_error
    echo "*** 上报错误完成！ ***"
    rm -rf $SCRIPT_DIR/output
fi

date
