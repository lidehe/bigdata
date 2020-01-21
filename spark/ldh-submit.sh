
echo "class " ${1}
class=${1}
shift

echo "jar " ${1}
jar=${1}

shift
echo "params "${@}
params=${@}


# 这里暂时只把hbase相关的jar给出来，如果有问题，再改条件
hbase_jars=`ls "${HBASE_HOME}"/lib/hbase*.jar`
hbase_jars=`echo ""${hbase_jars}""|sed 's# #,#g'`

spark-submit --master yarn --deploy-mode client --jars ${hbase_jars} --class ${class} ${jar} ${params}
