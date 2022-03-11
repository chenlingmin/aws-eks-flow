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



if [ ! $AWS_EKS_NAMESPACE ]; then  
    AWS_EKS_NAMESPACE="default"
fi  

echo [INFO] AWS_REGION=$AWS_REGION
echo [INFO] AWS_ECR_URL=$AWS_ECR_URL
echo [INFO] AWS_EKS_NAME=$AWS_EKS_NAME
echo [INFO] AWS_EKS_NAMESPACE=$AWS_EKS_NAMESPACE
echo [INFO] AWS_EKS_WORKLOADS_TYPE=$AWS_EKS_WORKLOADS_TYPE
echo [INFO] AWS_EKS_WORKLOADS_NAME=$AWS_EKS_WORKLOADS_NAME
echo [INFO] AWS_EKS_CONTAINER_NAME=$AWS_EKS_CONTAINER_NAME

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

aws eks update-kubeconfig --region $AWS_REGION --name $AWS_EKS_NAME
echo [INFO] kubectl 配置完成

kubectl -n $AWS_EKS_NAMESPACE set image $AWS_EKS_WORKLOADS_TYPE/$AWS_EKS_WORKLOADS_NAME $AWS_EKS_CONTAINER_NAME=$DOCKER_IMAGE_URL

echo [SUCCESS] $AWS_EKS_WORKLOADS_TYPE/$AWS_EKS_WORKLOADS_NAME $AWS_EKS_CONTAINER_NAME 的镜像已经更新为 $DOCKER_IMAGE_URL

