SELECT distinct a.viewspotid,
a.isactive 景点当前是否有效,
a.channelisonline_online 景点是否online可见,
a.channelisonline_H5 景点是否H5可见,
a.channelisonline_App 景点是否APP可见,
case 
  when MainActivityID is not null then 1 
else 
  0 
end 景产是否主关联,
a.name 景点名称,
a.level 景区星级,
--a.MainActivityID 产品ID,
--a.MainActivityIsActive 产品当前是否有效,
--a.MainActivityIsOnline 当前是否在线,
b.OptionID 可选项ID,
b.Name 可选项名称,
b.ChargeUnit 可选项计价单位,
b.IsActive 可选项当前是否有效,
--b.ActivityViewInc_onlineh5 是否产品端可见_onlineh5,
--b.AllianceViewInc 是否分销接口可见,
--b.ActivitySaleInc_onlineh5 是否产品端可卖_onlineh5,
b.AllianceSaleInc 是否常规分销接口可卖,
case 
  when b.DistributionChannelSaleInd&131072=131072 then 'T' 
else 
  'F' 
end 是否携程系分销接口可卖,
a.MainActivityCountryName 国家,
a.MainActivityBusinessRegionName 大区,
a.MainActivityProvinceName 省份,
a.MainActivityCityName 城市,
a.PrefectureCityName    地级市,
a.MainActivityCategoryName_old 产品类型,
a.MainActivityName 产品名称,
a.MainActivityPMEID 产品经理,
a.MainActivityPAEID 产品助理,
a.MainActivityEffectDate 产品生效日期,
a.MainActivityThemeNames 景点主题,
b.OptioncategoryName 可选项类型,
b.currentprice_SalePrice 卖价,
b.currentprice_OriginSalePrice '卖价(未换算)',
b.currentprice_CostPrice 底价, 
b.currentprice_OriginCostPrice '底价(未换算)', 
b.currentprice_MarketPrice 市场价,
b.currentprice_OriginMarketPrice '市场价(未换算)',
b.lastprice_Date 最大有价格日期,
b.cashbackamount_max 返现,
b.cashreduceamount 卖价立减,
b.promotionamount 定价平台通用立减,
b.promotionamount_fdj 非定价平台通用立减,
b.promotionamount_fdj_new 非定价平台新客立减,
b.PMEID  资源经理,
b.PAEID  资源助理,
b.AdvanceBookingTime  提前预订时间,
b.AdvanceBookingDays  提前预订天数,
CASE 
  WHEN b.PayMode='O' THEN '现付'  
  WHEN b.PayMode='P' THEN '预付'  
ELSE 
  '未知' 
END 支付方式,
b.VendorID  供应商ID,
b.VendorName  供应商名称,
b.IsAutoProcess  是否自动处理,
b.VendorConfirmHours  供应商确认小时数,
b.vconfirm_ConfirmMinutes '供应商确认分钟数(新)',
b.vconfirm_TimeAfter '供应商确认分段时间(0代表之前1代表之后)',
b.vconfirm_Days '供应商确认分段时间设置天(新)',
b.vconfirm_Time '供应商确认分段时间设置时间(新)',
case 
  when b.VendorConfirmModeID=0 then '无需确认'
  when b.VendorConfirmModeID=1 then '人工传真'
  when b.VendorConfirmModeID=2 then 'Vbooking人工确认'
  when b.VendorConfirmModeID=3 then 'Vbooking自动确认'
  when b.VendorConfirmModeID=4 then '系统对接'
  when b.VendorConfirmModeID=5 then '自动传真' 
  when b.VendorConfirmModeID=6 then '邮件'  
else 
  '未知' 
end 供应商确认方式,
case 
  when b.customerinfotemplateid = 1 then '不需要证件，一单一人' 
  when b.customerinfotemplateid = 2 then '需要身份证，一单一人' 
  when b.customerinfotemplateid = 3 then '需有效证件，一单一人' 
  when b.customerinfotemplateid = 4 then '不需要证件，一张一人' 
  when b.customerinfotemplateid = 5 then '需要身份证，一张一人' 
  when b.customerinfotemplateid = 6 then '需有效证件，一张一人' 
  when b.customerinfotemplateid = 14 then '中英文姓名,一张一人' 
  when b.customerinfotemplateid = 20 then '中英文姓名，一单一人' 
  when b.customerinfotemplateid = 21 then '需要身份证，1张1人1单1证(暂不可用)' 
  when b.customerinfotemplateid = 22 then '需要有效证件，1张1人1单1证(暂不可用)' 
  when b.customerinfotemplateid = 23 then '需要护照，一单一人(暂不可用)' 
  when b.customerinfotemplateid = 24 then '需要入台证，一单一人(暂不可用)' 
  when b.customerinfotemplateid = 25 then '需要护照，一张一人(暂不可用)' 
  when b.customerinfotemplateid = 26 then '需要入台证，一张一人(暂不可用)' 
  when b.customerinfotemplateid = 27 then '需要护照，1张1人1单1证(暂不可用)' 
  when b.customerinfotemplateid = 28 then '需要入台证，1张1人1单1证(暂不可用)' 
else 
  '其他'
end 预定填写模板,
case 
  when b.customerinfotemplateid in (2,5,21) then '是'
else 
  '否'
end 是否实名制,
case 
  when b.RefundNewType = 1 then '随时退' 
  when b.RefundNewType = 2 then '非随时退'
  when b.RefundNewType = 3 then '不可退'
end 是否随时退,
case 
  when b.refundnewmode = 1 then '无时间限制'
  when b.refundnewmode = 2 then '有时间限制'
  when b.refundnewmode = 3 then '其他' 
end 退订方式,
ConnectionVendorAttributes_days 核单天数,
case 
  when b.RefundOtherRequirement=1 then '支持部分退' 
  when b.RefundOtherRequirement=2 then '不支持部分退' 
else 
  '无' 
end 是否支持部分退,
b.ConnectionVendorAttributes_weekend 是否周末核单,
b.ConnectionVendorAttributes_holiday 是否节假日核单,
case 
  when b.RefundOtherRequirement = 1 then '是' 
else 
  '否' 
end 是否有损退,
case 
  when c.RefundDateType = 3 and b.RefundOtherRequirement <> 1 then '是'
else 
  '否' 
end 是否过游玩日期后全额退,
case 
  when b.distributionchannel = 15 then '是'
else 
  '否'
end 是否勾选团购,
case 
  when b.ExchangeProof = '1' then '携程确认短信'
  when b.ExchangeProof = '2' then '翼码二维码'
  when b.ExchangeProof = '3' then '供应商二维码'
  when b.ExchangeProof = '4' then '携程数字验证码'
  when b.ExchangeProof = '5' then '供应商数字凭证码'
  when b.ExchangeProof = '6' then '身份证'
  when b.ExchangeProof = '7' then '有有效证件'
  when b.ExchangeProof = '8' then '携程确认单'
  when b.ExchangeProof = '9' then '实物单'
  when b.ExchangeProof = '13' then '打印的纸质携程确认单'
else 
  '其他'
end 发送入园凭证方式,
(case when b.exchangeway=1 then '换票' when b.exchangeway=2 then '直接验证入园' when b.exchangeway=3 then '付款取票' end) 兑换方式, 
case when e.isactive='T' then '限制' else '无限制' end 是否限购,
isnull(b.isreservation,'F') 是否预约,
b.shelf_l1_name 一级货架名称,
b.shelf_l2_name 二级货架名称,
VisitorType  票型,
case 
  when b.DistributionChannelSaleInd&2=2 or b.DistributionChannelSaleInd&16=16 or b.DistributionChannelSaleInd&64=64 then 'T' 
else 
  'F' 
end 门票渠道售卖终端是否可售卖,
case 
  when b.DistributionChannelSaleInd&1024=1024 or b.DistributionChannelSaleInd&2048=2048 or b.DistributionChannelSaleInd&4096=4096 
       or b.DistributionChannelSaleInd&8192=8192  or b.DistributionChannelSaleInd&16384=16384 or b.DistributionChannelSaleInd&65536=65536 
       or b.DistributionChannelSaleInd&262144=262144 or b.DistributionChannelSaleInd&524288=524288 then 'T' 
else 
  'F' 
end 内部分销是否可售卖,
b.connectionvendorid 对接ID,
b.isweekendwork 周末是否工作,
case 
   when b.isexclusive = 1 then '是'
else 
  '否'
end 是否专享,
case 
   when b.isbpoption = 1 then '是'
else 
   '否'
end 是否是包票,
(case when b.distributionchannelsaleind&16=16 then '是' else '否' end) as 是否APP可卖,
(case when b.distributionchannelsaleind&2=2 then '是' else '否' end) as 是否ONLINE可卖,
(case when b.distributionchannelsaleind&64=64 then '是' else '否' end) as 是否H5可卖,
(case when b.distributionchannelsaleind&1048576=1048576 then '是' else '否' end) as 是否小程序可卖,
(case when b.distributionchannelviewind&16=16 then '是' else '否' end) as 是否APP可见,
(case when b.distributionchannelviewind&2=2 then '是' else '否' end) as 是否ONLINE可见,
(case when b.distributionchannelviewind&64=64 then '是' else '否' end) as 是否H5可见,
(case when b.distributionchannelviewind&1048576=1048576 then '是' else '否' end) as 是否小程序可见 ,
case when a.MaintenanceMode='0' then '系统维护'  when a.MaintenanceMode='1' then '人工维护' else '未录入维护方式' end as 信息维护,
a.pmeid 景点经理,
a.paeid 景点助理,
a.saleunitid 票种ID,
a.saleunitname 票种名称,
a.saleuni_isactive 票种状态,
(case when a.type=1 then '单票' when a.type=2 then '套票' when a.type=3 then '联票' else '其它' end) 票种类型,
a.allowretail 是否支持零售,
a.ishighrisk 是否高风险,
b.propertyvaluename 人群属性,
a.online_active 景点在线有效, 
b.online_active 资源在线有效,
(case when b.salemode=0 then '代理' when b.salemode=1 then '零售' end) 销售模式,
a.isdomestic  国内海外  
from (select * from bi_ttd.dbo.Mid_Tkt_ViewSpot_New 
WHERE ('' in  (#Country#) or MainActivityCountryName in (#Country#))
and ('' in (#ProvinceName#) or MainActivityProvinceName in (#ProvinceName#))
and ('' in (#ViewspotName#) or Name in (#ViewspotName#))
and ('' in  (#cityid#) or MainActivityCityName in (#cityid#))
and ('' in  (#viewspotID#) or ViewSpotID in (#viewspotID#))
and ('' in (#daqu#) or MainActivityBusinessRegionName in (#daqu#))
and ('' like (#MainActivityThemeNames#) or MainActivityThemeNames like (#MainActivityThemeNames#))
AND ('' IN  (#isdomestic#) OR isdomestic IN (#isdomestic#) ) 
) a 
left join bi_ttd.dbo.Mid_Tkt_Resource_New b 
on a.optionID = b.optionID 
left join bi_ttd.dbo.prd_optionrefundcost c 
on b.optionID = c.optionID
left join bi_ttd.dbo.prd_optionlimitsale e
on a.optionID = e.optionID
WHERE (#isactive#='全部' OR (a.IsActive = 'T' AND a.channelisonline ='T' AND b.IsActive = 'T'))
and ('' in  (#OPTIONID#) or b.OptionID in (#OPTIONID#))  
and ('' in  (#salemode#) or b.salemode in (#salemode#)) 
and ('' in (#productID#) or a.saleunitid in (#productID#))
and ('' in  (#PMEID#) or b.PMEID in (#PMEID#))
and ('' in  (#PAEID#) or b.PAEID in (#PAEID#))
and ('' in  (#VendorID#) or b.VendorID in (#VendorID#))
and (#viewspot_isttdresource#='全部'  or (a.optionid is not null))
