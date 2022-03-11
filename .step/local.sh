#!/bin/bash
source /root/local/params.env
export $(cut -d= -f1 /root/local/params.env)

source /root/logger.sh
source /root/exec.sh
source /root/redline.sh

WORK_SPACE=/root/workspace
PLUGIN_DIR=/root/plugins
PROJECT_DIR=$WORK_SPACE/code
LOG_DIR=$WORK_SPACE/logs
TASK_DIR=$WORK_SPACE/task
CONTEXT_DIR=$WORK_SPACE/context
COMMAND_DIR=$WORK_SPACE/user_command.sh
ENV_DIR=$WORK_SPACE/env
TIMESTAMP=`date +%s`
DATETIME=`date +%Y-%m-%d-%H-%M-%S`

mkdir -p $PLUGIN_DIR

# 系统参数,和老版流水线保持一致
export PIPELINE_ID=9999
export PIPELINE_NAME="Local-Pipeline"
export BUILD_NUMBER=1
export BUILD_JOB_ID=10000000
export EMPLOYEE_ID="EmployeeId"
export PROJECT_DIR
export WORK_SPACE
export PLUGIN_DIR
export stepIdentifier="stepIdentifier"

if [[ ! -d $PROJECT_DIR ]]; then
  mkdir -p $PROJECT_DIR
fi

echo $command > /root/workspace/user_command.sh

####################### 执行步骤脚本 #############################

if [[ -x /root/pre.sh ]]; then
    INFO 准备步骤
    step_exec /root/pre.sh
fi

INFO 执行步骤
step_exec /root/step.sh
exec_result=$?

if [[ "$exec_result" = "0" ]]; then
    SUCCESS 步骤运行成功
else
    if [[ -x /root/catch.sh ]]; then
        step_exec /root/catch.sh
    fi
    ERROR BUILD ERROR
    ERROR $BUILD_JOB_ID
    ERROR "步骤运行失败，返回码：$exec_result"
fi

if [[ -x /root/final.sh ]]; then
    step_exec /root/final.sh
fi

exit $exec_result
