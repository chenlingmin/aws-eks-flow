#!/bin/bash
set -e 
# 系统提供参数，从流水线上下文获取
echo [INFO] PIPELINE_ID=$PIPELINE_ID       # 流水线ID
echo [INFO] PIPELINE_NAME=$PIPELINE_NAME   # 流水线名称
echo [INFO] BUILD_NUMBER=$BUILD_NUMBER     # 流水线运行实例编号
echo [INFO] EMPLOYEE_ID=$EMPLOYEE_ID       # 触发流水线用户ID
echo [INFO] WORK_SPACE=$WORK_SPACE         # /root/workspace容器中目录
echo [INFO] PROJECT_DIR=$PROJECT_DIR       # 代码库根路径，默认为/root/workspace/code
echo [INFO] PLUGIN_DIR=$PLUGIN_DIR         # 插件路径，默认为/root/workspace/plugins
echo [INFO] BUILD_JOB_ID=$BUILD_JOB_ID     # build-service 任务ID

echo [INFO] AWS_REGION=$AWS_REGION
echo [INFO] AWS_ECR_URL=$AWS_ECR_URL

cd $PROJECT_DIR

# sh -ex $WORK_SPACE/user_command.sh
echo [INFO] 创建 aws 环境

mkdir ~/.aws
echo "[default]">~/.aws/config
echo "region = $AWS_REGION">>~/.aws/config
echo "output = json">>~/.aws/config

echo "[default]">~/.aws/credentials
echo "aws_access_key_id = $AWS_ACCESS_KEY_ID">>~/.aws/credentials
echo "aws_secret_access_key = $AWS_SECRET_ACCESS_KEY">>~/.aws/credentials

echo [INFO] 创建 aws 环境完成

aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $AWS_ECR_URL
echo [INFO] Docker 登录完成

DOCKER_IMAGE_URL=$AWS_ECR_URL/$DOCKER_IMAGE_NAME:$DATETIME
docker build -f $PROJECT_DIR/$DOCKERFILE $PROJECT_DIR/$CONTEXT_PATH -t $DOCKER_IMAGE_URL
echo [INFO] $DOCKER_IMAGE_URL 构建完成


docker push $DOCKER_IMAGE_URL
docker rmi $DOCKER_IMAGE_URL

echo [SUCCESS] 推送完成 $DOCKER_IMAGE_URL


# echo "$stepIdentifier.DOCKER_IMAGE_URL={\"DOCKER_IMAGE_URL\":\"$DOCKER_IMAGE_URL\"}"
# 将输出写入params
echo "$stepIdentifier.DOCKER_IMAGE_URL=$DOCKER_IMAGE_URL"

# 将输出写入params
echo "$stepIdentifier.DOCKER_IMAGE_URL=$DOCKER_IMAGE_URL" >>$WORK_SPACE/params
