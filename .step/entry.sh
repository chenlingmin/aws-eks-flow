#!/bin/bash

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

# 获取步骤参数
retry_times=0
while
    INFO Get: $TASK_URL >> $LOG_DIR
    curl --connect-timeout 5 --max-time 5 --retry 3 --retry-delay 1 --fail $TASK_URL > $TASK_DIR 2>> $LOG_DIR
    [[ $? != '0' || ! -s $TASK_DIR || `grep '"successful":false' $TASK_DIR` != '' ]] && (( retry_times < 3 ))
do
    WRANING "获取参数失败，重试第 $retry_times 次.."
    WARNING RETRY... >> $LOG_DIR
    (( retry_times++ ));
done

# 将环境变量写入 context
cat $TASK_DIR | jq -r '.envVars // "{\"WORK_SPACE\":\"/root/workspace\"}"' | jq -r "to_entries|map(\"\(.key)='\(.value|tostring)'\")|.[]" > $CONTEXT_DIR

# 将 command 信息写入 user_command.sh
cat $TASK_DIR | jq -r '.command' > $COMMAND_DIR

if [[ ! -s $CONTEXT_DIR ]]; then
  ERROR "获取环境变量失败，请联系系统管理员解决"
  ERROR BUILD ERROR
  ERROR $BUILD_JOB_ID
  exit 1;
fi

source $CONTEXT_DIR
export $(cut -d= -f1 $CONTEXT_DIR)

# 如果获取 Credential 失败打印错误信息
if [[ -z "$ERROR" ]]; then
  SUCCESS 获取 Credential 成功
else
  ERROR $ERROR
fi

# 代码库路径
if [[ $source ]]; then
  INFO 使用工作路径$WORK_SPACE/$source
  PROJECT_DIR=$WORK_SPACE/$source
else
  WARNING "未指定工作路径，使用默认路径$PROJECT_DIR"
fi

if [[ ! -d $PROJECT_DIR ]]; then
  mkdir -p $PROJECT_DIR
fi

# 系统参数,和老版流水线保持一致
export PIPELINE_ID=$ENGINE_PIPELINE_ID
export PIPELINE_NAME=$ENGINE_PIPELINE_NAME
export BUILD_NUMBER=$ENGINE_PIPELINE_INST_NUMBER
export EMPLOYEE_ID=$operator
export PROJECT_DIR
export WORK_SPACE
export PLUGIN_DIR
export stepIdentifier

# 处理需要替换环境变量的变量
if [[ $PARAM_READY_TO_REPLACE_ENV ]]; then
  for PARAM_KEY in $PARAM_READY_TO_REPLACE_ENV;
  do
    echo $PARAM_KEY="${!PARAM_KEY}" >> $ENV_DIR
  done
  source $ENV_DIR
  export $(cut -d= -f1 $ENV_DIR)
fi

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
