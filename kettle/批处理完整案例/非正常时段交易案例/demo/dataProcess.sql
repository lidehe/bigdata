
-- 选择数据库
use rrms;

-- 加载数据
alter table trade_info add if not exists partition(datadate="${data_date}") location "${data_path}";

-- 逻辑处理
-- -- 统计0-6点交易量和总交易量，放入中间表
insert overwrite table trade_info_count select a.abnormal,b.normal,b.merch_no from (select count(*) as abnormal,merch_no from trade_info where datadate="${data_date}" and unix_timestamp(time) between unix_timestamp("${data_date} 00:00:00","yyyyMMdd HH:mm:ss") and unix_timestamp("${data_date} 06:00:00","yyyyMMdd HH:mm:ss") group by merch_no) a left join (select count(*) as normal,merch_no from trade_info where datadate="${data_date}" group by merch_no) b on a.merch_no=b.merch_no;
-- -- 统计0-6点交易量占总交易量 超过30%，放入结果表
insert overwrite table trade_info_result select concat_ws(",",a.merch_no,b.merch_name,b.term_no,b.time,b.trn_amt) from (select merch_no from trade_info_count where (abnormal/total)>0.3) a left join (select distinct merch_no,merch_name,term_no,time,trn_amt from trade_info where datadate="${data_date}") b on a.merch_no=b.merch_no;
