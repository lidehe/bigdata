
-- 选择数据库
use rrms;

-- 建交易信息表/贴源表
drop table if exists trade_info;
create table trade_info(
`merch_no` string,
`merch_name` string,
`term_no` string,
`card_no` string,
`time` string,
`trn_amt` string,
`rate` string,
`fee` string,
`trn_type` string
)
partitioned by(datadate string)
row format delimited fields terminated by ",";


-- 建按时段同级交易量表/中间表
drop table if exists trade_info_count;
create table trade_info_count(
abnormal int,
total int,
merch_no string
)row format delimited fields terminated by ",";


-- 建结果表/结果表
drop table if exists trade_info_result;
create table trade_info_result(
 info string
);
