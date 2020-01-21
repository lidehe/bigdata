#!/bin/bash

log_date=`date -d  "$(date)" +"%Y%m%d"`
log_file_pre=`echo ""$1""|cut -d. -f1`
source ~/.bash_profile
kitchen.sh -file ~/job/${1} -logfile ~/job/${log_file_pre}_${log_date}.log
if [ $? -ne 0 ]
then
    exit 1
else
    exit 0
fi

