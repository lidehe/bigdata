
# 查看 topic
./kafka-topics.sh --zookeeper host:port,host:port --list
./kafka-topics.sh --zookeeper vm155:2181,vm156:2181,vm157:2181 --list

# 新建 topic
./kafka-topics.sh --zookeeper host:port,host:port --create --replication-factor 3 --partitions 30 --topic 【topic name】   
./kafka-topics.sh --zookeeper vm155:2181,vm156:2181,vm157:2181 --create --replication-factor 3 --partitions 30 --topic kettle_test

./kafka-topics.sh --zookeeper vm102:2181,vm103:2181,vm104:2181 --create --replication-factor 3 --partitions 30 --topic kettle

# 生产信息
# 执行以下命令，在输入终端输入消息，以键 值对的方式，键和值之间有空格
# 注意，这里写的是 kafka集群的信息，不是zookeeper
./kafka-console-producer.sh --broker-list host:port,host:port --topic 【topic name】



# 消费信息
./kafka-console-consumer.sh --zookeeper host:port,host:port --topic 【topic name】 --from-beginning



# 删除 topic
./kafka-topics.sh --zookeeper host:port,host:port --delete --topic 【topic name】


# 启动
./kafka-server-start.sh -daemon ../config/server.properties


./kafka-topics --zookeeper vm155:2181,vm156:2181,vm157:2181 --delete --topic kettle