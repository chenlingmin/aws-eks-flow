#!/bin/bash

step_exec() {
    $@ 2>&1 | while IFS= read -r line; do
        if [[ ${line} = \+* ]]; then
            echo -e "\033[1;36m[`date +%H:%M:%S`] [执行命令] $line";
        else
            echo "[`date +%H:%M:%S`] $line";
        fi
    done
    return ${PIPESTATUS[0]}
}

export -f step_exec >>/dev/null