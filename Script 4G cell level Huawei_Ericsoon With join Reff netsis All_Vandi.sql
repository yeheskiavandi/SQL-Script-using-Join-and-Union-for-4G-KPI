
Select
VENDOR,
t1.siteid,
t1.[CellName]
,[DateId]
,[HourId]

,[LNetworkElementAvailability] =100*((3600- case when (([L.Cell.Unavail.Dur.Sys])+([L.Cell.Unavail.Dur.Manual])) > 3600 then 3600 else (([L.Cell.Unavail.Dur.Sys])+([L.Cell.Unavail.Dur.Manual])) end)/3600)
 
 ,[LSessionSetupSuccessRateSSSR] = (100 * 
(
 (isnull(([L.RRC.ConnReq.Succ.Emc]),0) + isnull(([L.RRC.ConnReq.Succ.HighPri]),0) + isnull(([L.RRC.ConnReq.Succ.Mt]),0) + isnull(([L.RRC.ConnReq.Succ.MoData]),0) + isnull(([L.RRC.ConnReq.Succ.DelayTol]),0))
 /
 nullif(isnull(([L.RRC.ConnReq.Att.Emc]),0) + isnull(([L.RRC.ConnReq.Att.HighPri]),0) + isnull(([L.RRC.ConnReq.Att.Mt]),0) + isnull(([L.RRC.ConnReq.Att.MoData]),0) + isnull(([L.RRC.ConnReq.Att.DelayTol]),0),0)
)
*
(
 ([L.S1Sig.ConnEst.Succ]) / nullif( ([L.S1Sig.ConnEst.Att]) ,0)
)
*
(
 ([L.E-RAB.SuccEst]) / nullif( ([L.E-RAB.AttEst]) ,0)
))
,[LERABDropRate] = (100 * ( [L.E-RAB.AbnormRel] ) / nullif( isnull(( [L.E-RAB.AbnormRel] ),0) + isnull(( [L.E-RAB.NormRel] ),0) ,0))

,[LPDCPCellThroughputDLMbps] =( ([L.Thrp.bits.DL]) / nullif( ([L.Thrp.Time.Cell.DL.HighPrecision]) ,0) ) / 1000
      
      ,[LPDCPCellThroughputULMbps] =( ([L.Thrp.bits.UL]) / nullif( ([L.Thrp.Time.Cell.UL.HighPrecision]) ,0) ) / 1000

      ,[LDLTrafficVolumeGB] = ( ( ( [L.Thrp.bits.DL] ) / 1000000 ) / 8 ) / 1000

      ,[LULTrafficVolumeGB] = (( ( ( [L.Thrp.bits.UL] ) / 1000000 ) / 8 ) / 1000)
,[LConnectedUsersMax] = ([L.Traffic.User.Max])
, [LastTTIRatio] = 100*(isnull([L.Thrp.bits.DL.LastTTI],0)/nullif([L.Thrp.bits.DL],0))      
      
      
  
FROM [MEutranHuaweiCounter].[dbo].[VEUtranCell] as t1
JOIN [REFERENCE].[dbo].[REFF_NETSIS_ALL] as t2
	on t1.[CellName] = t2.CELLNAME
where DateId>='20230523' --and DateId <= '20230522'
and t1.CellName in (
'AC4G18_4217569E_4',
'AC4G18_4217569E_5',
'AC4G18_4217569E_6',
'JK4G09_4435039E9_1',
'JK4G09_4435039E9_2',
'JK4G09_4435039E9_3'

)
--group by
--[CellName]
--,[DateId]
--,[HourId]

union all


select
VENDOR,
t1.siteid,
EutranCellFDD
,DATE_ID
,HOUR_ID
,LNetworkElementAvailability
=100*((3600- case when (sum(pmCellDowntimeAuto)+sum(pmCellDowntimeMan)) > 3600 then 3600 else (sum(pmCellDowntimeAuto)+sum(pmCellDowntimeMan)) end)/3600)
,LSessionSetupSuccessRateSSSR 
=100 * ( sum(pmRrcConnEstabSucc) / nullif( isnull(sum(pmRrcConnEstabAtt),0) - isnull(sum(pmRrcConnEstabAttReatt),0) ,0) ) * ( sum(pmErabEstabSuccInit) / nullif( sum(pmErabEstabAttInit),0) ) * ( sum(pmS1SigConnEstabSucc) / nullif( sum(pmS1SigConnEstabAtt),0) )
,LERABDropRate 
=100 *  isnull(sum(pmErabRelAbnormalEnbAct),0)   / nullif( isnull(sum(pmErabRelAbnormalEnb),0) + isnull(sum(pmErabRelNormalEnb) ,0)  ,0)
,LAVGPDCPCellThroughputDLMbps 
=(sum(pmPdcpVolDlDrb) / nullif( sum(pmSchedActivityCellDl) /1000,0))/1000 
,LAVGPDCPCellThroughputULMbps 
=(sum(pmPdcpVolUlDrb) / nullif( sum(pmSchedActivityCellUl) /1000,0))/1000
,LDLTrafficVolumeGB = (sum(pmPdcpVolDlDrb) / 1000) / 8000
,LULTrafficVolumeGB = (sum(pmPdcpVolUlDrb) / 1000) / 8000
,LConnectedUsersMax = sum(pmLicConnectedUsersMax)
,LastTTIRatio = 100*(isnull(sum(pmPdcpVolDlDrbLastTTI),0)/nullif(sum(pmPdcpVolDlDrb),0))



from [MEutranEricssonCounter].[dbo].[MCellHourCounter] as t1
JOIN [REFERENCE].[dbo].[REFF_NETSIS_ALL] as t2
	on t1.EutranCellFDD = t2.CELLNAME
where 
DATE_ID>= '20230523' --and DATE_ID <= '20230522'
and EutranCellFDD in (
'AC4G18_4217569E_4',
'AC4G18_4217569E_5',
'AC4G18_4217569E_6',
'JK4G09_4435039E9_1',
'JK4G09_4435039E9_2',
'JK4G09_4435039E9_3'

)

group by 
VENDOR,
t1.siteid,
EutranCellFDD
,DATE_ID
,HOUR_ID
