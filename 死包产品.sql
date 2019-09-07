--获取产品是否含有系统资源的逻辑
use tmp_diydb;
drop table if exists tmp_pkg_is_system_hl;
create table tmp_pkg_is_system_hl as
select a.productid
,b.flight as sys_flight
,case when c.productid is not null then 1 else 0 end as sys_hotel
,b.train  as sys_train
,guize.flight2 as  rule_flight
,guize.hotel2  as rule_hotel
,guize.train2  as rule_train
,case when coalesce(b.flight,guize.flight2)is null then 0 else 1 end as is_sys_flight
,case when c.productid is not null then 1 when guize.hotel2 is not null then 1 else 0 end as is_sys_hotel
,case when coalesce(b.train,guize.train2)is null then 0 else 1 end  as is_sys_train
,case when sing_flt.productid is not null then 1 else 0 end as is_sing_flight
,b.cruise as sys_cruise
,case when b.cruise is not null then 1 else 0 end as is_sys_cruise
from(
	--select productid,productregion,destcityname,startcitys,
	--destprovincename,destcountryname,productcategory
	--from dw_sbu_vadmdb.product_baseinfo
	--where d = '${zdt.addDay(0).format("yyyy-MM-dd")}'
	--and producttype = 'L'
	--and productpattern in  ('跟团游','半自助游','私家团')
	--and isonline = 'T'
	--and active = 'T'
	--and expiredate > '${zdt.addDay(0).format("yyyy-MM-dd")}'
  select productid 
  from ods_vacdb.m_pkgproductdb_prd_product p
  where p.d='${zdt.addDay(0).format("yyyy-MM-dd")}' and p.active='T' --and p.isonline='T' 
  and p.productpatternid in (1,3,4)
)a 
left join(
	select productid,
	max(case when isincludesystemtrain='T' then 1 end) as train,
	max(case when isincludesystemflight='T' then 1 end) as flight,
    max(case when isincludecruise='T' then 1 end) as cruise --邮轮资源
	from ods_vacdb.m_pkgproductdb_prd_segment
	where d = '${zdt.addDay(0).format("yyyy-MM-dd")}'
	group by productid
)b on a.productid = b.productid
left join (
  select 
  productid
  --,max(p.segmentid) as segmentid
  ,max(case when sef.segmentid is not null then 1 end) flight2
  ,max(case when seh.segmentid is not null then 1 end) hotel2
  ,max(case when sett.segmentid is not null then 1 end) train2
  from (select * from ods_vacdb.m_pkgproductdb_prd_segment where d='${zdt.addDay(0).format("yyyy-MM-dd")}') p
  left join( 
  select
  *,row_number() over (partition by segmentid order by datachange_lasttime desc) as rn 
  from ods_vacdb.m_pkgproductdb_prd_matchingruleforsystemflight where d='${zdt.addDay(0).format("yyyy-MM-dd")}'
  ) sef on p.segmentid=sef.segmentid and sef.rn=1 
  left join( 
  select
  *,row_number() over (partition by segmentid order by datachange_lasttime desc) as rn 
  from ods_vacdb.m_pkgproductdb_prd_matchingruleforsystemhotel where d='${zdt.addDay(0).format("yyyy-MM-dd")}'
  ) seh on p.segmentid=seh.segmentid and seh.rn=1 
  left join( 
  select
  *,row_number() over (partition by segmentid order by datachange_lasttime desc) as rn 
  from ods_vacdb.m_pkgproductdb_prd_matchingruleforsystemtrain where d='${zdt.addDay(0).format("yyyy-MM-dd")}'
  ) sett on p.segmentid=sett.segmentid and sett.rn=1 
  group by productid
) guize on a.productid = guize.productid
left join(
	select distinct productid
	from ods_vacdb.m_pkgproductdb_prd_segmentroom
	where d = '${zdt.addDay(0).format("yyyy-MM-dd")}'
	and isactive = 'T'
	and ismasterhotel = 'T'
)c on a.productid = c.productid
left join (--判断单选项机票
    select productid from 
    dw_diydb.dw_diy_relation_prod_res_ls
    where res_type='f'
    group by productid
) sing_flt on a.productid = sing_flt.productid
;

--获取产品是否死包的逻辑
use tmp_diydb;
drop table if exists tmp_pkg_is_system_hl_pkgid;
create table tmp_pkg_is_system_hl_pkgid as
with similarpackage as
(
	select *,row_number()over(partition by productidmain order by productid) as num	
	from(
		select distinct productid, productidmain,sort--,pkgdescription
	    --
	     from dw_sbu_vadmdb.product_similarpackage
	     where d='${zdt.addDay(0).format("yyyy-MM-dd")}' --and (productidmain=22928466 or productid=22928466)
	)a
)
select a.*
,case when b.productid is not null then '多线路多产品id' when f.productid is not null then '多线路同产品id' else '单线路' end as ismultiline
,case when b.productid is not null then b.sort else 0 end as multisort
 from (
 	select productid
 	,is_sys_flight,is_sys_hotel,is_sys_train
 	,case when is_sys_flight+is_sys_hotel+is_sys_train>=1 then 0 else 1 end is_sibao --1为死包，0位活包
 	 from tmp_diydb.tmp_pkg_is_system_hl
 	 --where productid in (1955391 ,13449664)
 	)a
left join similarpackage b on cast(a.productid as string)=cast(b.productid as string) and b.num>1
left join(
   select distinct productid --tourinfoid bcd线路根据tourinfoid顺序排列
    from ods_vacdb.m_pkgproductdb_prd_tourinfo
   where d='${zdt.addDay(0).format("yyyy-MM-dd")}'
   )f on cast(a.productid as string)=cast(f.productid as string)
;

--计算死包产品数比例
select a.is_sibao,b.salemode_group,b.domain,count(distinct a.productid)
 from tmp_diydb.tmp_pkg_is_system_hl_pkgid a
inner join (
select productid
  ,CASE WHEN coalesce(SaleMode,'S')='P' THEN '代理'
      WHEN coalesce(SaleMode,'S')='R' THEN '零售'
      ELSE '自营'
   END AS salemode_group
  ,case when destcountryid=0 or destcountryid is null then '未知'
      when destcountryid=1 and destprovinceid not in (32,33,53) then '境内'
else '境外'
end domain
 from  dw_sbu_vadmdb.product_baseinfo
where d='${zdt.addDay(0).format("yyyy-MM-dd")}'
  and producttype='L'
  and productpattern in ('跟团游','半自助游','私家团') 
  and productcategory in ('国内旅游','出境旅游','境内N日游','境外N日游')
)b on a.productid=b.productid
group by a.is_sibao,b.salemode_group,b.domain
;

--计算订单数比例
select 
count(distinct a.orderid)order_num
,ab.is_sibao,ab.ismultiline
,salemode_group,ab.domain
 from dw_diydb.olap_factallpkgorder a
join(
select a.productid,a.is_sibao,a.ismultiline,b.salemode_group,b.domain
 from tmp_diydb.tmp_pkg_is_system_hl_pkgid a
inner join (
select productid
  ,CASE WHEN coalesce(SaleMode,'S')='P' THEN '代理'
      WHEN coalesce(SaleMode,'S')='R' THEN '零售'
      ELSE '自营'
   END AS salemode_group
  ,case when destcountryid=0 or destcountryid is null then '未知'
      when destcountryid=1 and destprovinceid not in (32,33,53) then '境内'
else '境外'
end domain
 from  dw_sbu_vadmdb.product_baseinfo
where d='${zdt.addDay(0).format("yyyy-MM-dd")}'
  and producttype='L'
  and productpattern in ('跟团游','半自助游','私家团') 
  and productcategory in ('国内旅游','出境旅游','境内N日游','境外N日游')
)b on a.productid=b.productid
--group by a.is_sibao,b.salemode_group,b.domain
 )ab on a.pkg=ab.productid
where a.d='2019-09-06' 
and a.orderdate>='2019-06-01'
group by ab.is_sibao,ab.ismultiline
,salemode_group,ab.domain
;