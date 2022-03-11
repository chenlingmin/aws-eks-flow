#!/bin/bash

function redlineCheck() {
  type=`echo $CHECK_REDLINES | jq -r --arg Key "$1" '.[] | select(.key == $Key).type'`
  threshold=`echo $CHECK_REDLINES | jq -r --arg Key "$1" '.[] | select(.key == $Key).threshold'`
  case $type in
    GE)
      checkResult=`if [ $2 -ge $threshold ];then echo true; else echo false; fi`
    ;;
    EQ)
      checkResult=`if [ $2 -eq $threshold ];then echo true; else echo false; fi`
    ;;
    LE)
      checkResult=`if [ $2 -le $threshold ];then echo true; else echo false; fi`
    ;;
    *)
      return
    ;;
  esac
  if [[ $checkResult == false ]]; then
    echo [$stepIdentifier] REDLINE_ITEM_LINE: \{\"key\":\"$1\",\"threshold\":$threshold,\"checkVal\":$2,\"type\":\"$type\",\"checked\":true,\"checkResult\":$checkResult\}
  fi
}

function single() {
  echo [$stepIdentifier] STAT_NAME_$1: $2
  echo [$stepIdentifier] STAT_VALUE_$1: $3
  echo [$stepIdentifier] STAT_STYLE_$1: $4
  if [[ -n "$CHECK_REDLINES" ]]; then
    redlineCheck $1 $3
  fi
}

function report() {
  echo [$stepIdentifier] STAT_URL__REPORT: $1
}

function parse() {
  for item in $@; do
    if [[ $item == Report:* ]]; then
      report ${item//Report:/}
    else
      single ${item//:/ }
    fi
  done
}

function redline() {
  echo [$stepIdentifier] STAT_INFO_TITLE: \"\" | tee >> $WORK_SPACE/params
  parse $@ | tee -a >> $WORK_SPACE/params
}

export -f redline parse report single redlineCheck 2>>/dev/null
