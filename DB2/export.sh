#!/bin/bash

#######################################################################################
# 工程简介：
#      用于将数据导出到文件，上传hdfs、hbase
#      支持的数据库为 DB2 和 MySQL
# 须知：
#     本项目的运行，需要基于HDFS、HBase、DB2的指令，所以上述环境是必须的
#     SELECT 字段列表里，一定要把row_key放在第一个。此列表要与java程序配置文件里qualifiers一致
#
# 当前进展：
#     1、java代码支持通过配置以后导出多个表，但是SQL脚本还没有做到通用，因为 无法向DB2 sql传递参数
#     2、对于HBase的配置文件是通过系统环境变量获取的，所以要求程序运行在HBase的节点上
#     3、对于HDFS,不需要是节点，只要由hdfs命令就行。不过，既然 2 要求运行在HBase上，那就肯定也在HDFS节点上了
#     4、对于DB2，不知道怎么操作来连接远程数据库
#
# 后续改进：
#     1、支持传递日期参数要有两个：数据起始日期，数据截止日期
#	  2、数据表参数化，虽然目前也支持，但因整个工程不通用，暂时关闭
#
#                                                            李德和  写于 2019年10月31日
#######################################################################################

base=$(dirname $0)
base=$(cd ${base};pwd)

if [[ $# -ne 3 ]]; then
	echo "Please input database type、table name and data date(exp:20191030)"
	exit 99
fi


############### 定义/申明一些变量 ################################
# 数据库类型
db_type=${1}

# 要导出的表
table_name=${2}

# 要导出的数据截止日期
data_date=${3}
date_end=`date -d "${data_date}" +"%Y-%m-%d"`
date_begin=`date -d "-1 month ${date_end}" +"%Y-%m-%d"`

# 申明变量
source ${base}/export-env.sh

# 日志文件，DB2执行时会把日志打印到此，如有异常可看此文件
log_file=${table_name}.log


# SQL file
sql_file=${table_name}.txt




################ 执行导出数据 #############################
if test ${db_type} == "db2";then
    # 连接数据库  格式为： db2 connect to 数据库名 user 登陆名 using 登陆密码
    db2 connect to ${database} user ${user} using ${password} &>${log_file}
    if [ $? -ne 0 ];then
        echo "connect to db2 database \"${database}\" error !"
        echo "more detail see ${log_file}"
        exit 99
    fi
    # 导出数据表到文件
	## 执行sql文件，暂且不用 db2 -svtf ${sql_file} &>>${log_file} 
	# 这里有个问题，暂时无法做到通用，那就是如何把日期传到sql里，如果可以，那就可以完全通用了
	db2 "export to ${sql_file} of ixf messages ${log_file} select * from ${table_name} where trn_time > ${date_begin} and trn_time < ${date_end}"
	if [ $? -ne 0 ];then
  	    echo "export failure,more detail see ${log_file}"
        exit 99
    fi
elif test ${db_type} == "mysql"; then





# 数据上传到 hdfs
# 这里要注意，上传的路径要与java程序里读取数据的路径(input)一致
hdfs dfs -put ./${table_name}.txt /tmp/${table_name}/${data_date}/${table_name}.txt &>>${log_file}
if [ $? -ne 0 ];then
    echo "upload to hdfs failure,more detail see ${log_file}"
    exit 99
fi

# 调用java程序，完成文件转换到HFile(HBase file)
# 下面这句一定要执行，或者配置到用户变量里，不然会报错找不到hbse的相关类
export HADOOP_CLASSPATH=$HBASE_HOME/lib/*:classpath
hadoop jar bulkload.jar com.zxftech.rrms.doTrans.GeneratorHFile ${table_name} ${data_date} &>>${log_file}
if [ $? -ne 0 ];then
    echo "HBase file generate failure,more detail see ${log_file}"
    exit 99
fi


########################################################################################################################
#  
#       这部分不需要了，已经放到java代码里了
#
# 执行HBase命令，把转换后的数据导入HBase表中
# 这里要注意，文件路径要与java程序里存放结果文件的路径(output)一致
# hbase org.apache.hadoop.hbase.mapreduce.LoadIncrementalHFiles /hdata/${table_name}/20191030/ ${table_name} &>>${log_file}
# if [ $? -ne 0 ];then
#    echo "import data into HBase failure,more detail see ${log_file}"
#    exit 99
# fi
#########################################################################################################################