-- Title: 	Freshdesk: ManageEngine Export v1.2
-- Author: 	Paul B
-- Date:	23/03/2023
-- Version:	v1.2
-- Flavour:	PostgreSQL

SELECT 
    chdt.CHANGEID "Change ID",
    concat('~',chdt.TITLE,'~') "Title",    
    concat(to_timestamp(chdt.SCHEDULEDSTARTTIME / 1000)::date, ' ' , to_timestamp(chdt.SCHEDULEDSTARTTIME / 1000)::time)  "Scheduled Start Time",    
    concat(to_timestamp(chdt.SCHEDULEDENDTIME / 1000):: date, ' ' , to_timestamp(chdt.SCHEDULEDENDTIME / 1000):: time)  "Scheduled End",  
    'manageeningearchive@toob.co.uk' "ChangeRequester",
    'manageeningearchive@toob.co.uk' "ChangeOwner",   
    priodef1.PRIORITYNAME "Priority",    
    urgdef.NAME "Urgency", 
	-- start case statement for ChangeType
	CASE
		WHEN ctdef.NAME = 'Minor' THEN 8
		WHEN ctdef.NAME = 'Significant' THEN 8
		WHEN ctdef.NAME = 'Standard' THEN 8
		WHEN ctdef.NAME = 'Normal' THEN 8
		WHEN ctdef.NAME = 'Emergency' THEN 4
		WHEN ctdef.NAME = 'Qube Maintenance' THEN 2
		WHEN ctdef.NAME = 'IT Patching for linux and Windows' THEN 7
		WHEN ctdef.NAME = 'L2 joint Inspection' THEN 7
		WHEN ctdef.NAME = 'Netadmin Chassis addition' THEN 7
	END "Change Type",
	-- end case statement
    approvaldef.STATUSNAME "Approval Status",
    'Archive' "Category",     
    chargeTable.TOTAL_CHARGE "Total Charges",  
    concat(to_timestamp(chargeTable.TS_STARTTIME / 1000)::date, ' ', to_timestamp(chargeTable.TS_STARTTIME / 1000)::time) "Time Spent Start Date",    
    concat(to_timestamp(chargeTable.TS_ENDTIME / 1000)::date, ' ', to_timestamp(chargeTable.TS_ENDTIME / 1000)::time) "Time Spent End Date",
    ownaaa1.FIRST_NAME "Time Spent Technician", 
	concat('~', orgaaa.FIRST_NAME, ' has raised the following change: ', chandes.FULL_DESCRIPTION, '~') "Description",
    -- start case Risk statement
	CASE
		WHEN riskDef.name = 'Low' THEN 1
		WHEN riskDef.name = 'Medium' THEN 2
		WHEN riskDef.name = 'High' THEN 3
	END "Risk",
	-- end case statement
    'Manage Engine Archive' "Group",
    orgsd.ISVIPUSER "VIP User",
    clcodeDef.NAME "Change Closure Code",
    concat('~', rfc.NAME, '~') "Reason For Change/Downtime",
    stageDef.DISPLAYNAME "Stage",
    'ManageEngine Archive' "Status",
    'claire.davison@toob.co.uk' "ChangeManager",
	concat('~',regexp_replace(impactdesc,'<[^>]+>', '', 'gi'), '~')  "Impact",
	concat('~',regexp_replace(cr.rolloutplan, E'<[^>]+>', '', 'gi'), '~') "Roll out plan",
	concat('~',regexp_replace(backoutplan, E'<[^>]+>', '', 'gi'), '~') "Backout plan",
	concat('~',regexp_replace(checklist, E'<[^>]+>', '', 'gi'), '~')  "Testing Checklist"
FROM ChangeDetails chdt 
LEFT JOIN SDUser orgsd ON chdt.INITIATORID=orgsd.USERID 
LEFT JOIN AaaUser orgaaa ON orgsd.USERID=orgaaa.USER_ID 
LEFT JOIN SDUser ownsd ON chdt.TECHNICIANID=ownsd.USERID 
LEFT JOIN AaaUser ownaaa ON ownsd.USERID=ownaaa.USER_ID 
LEFT JOIN PriorityDefinition priodef1 ON chdt.PRIORITYID=priodef1.PRIORITYID 
LEFT JOIN UrgencyDefinition urgdef ON chdt.URGENCYID=urgdef.URGENCYID 
LEFT JOIN ChangeTypeDefinition ctdef ON chdt.CHANGETYPEID=ctdef.CHANGETYPEID 
LEFT JOIN StageDefinition oldStageDef ON chdt.STAGEID=oldStageDef.STAGEID 
LEFT JOIN ApprovalStatusDefinition approvaldef ON chdt.APPR_STATUSID=approvaldef.STATUSID 
LEFT JOIN CategoryDefinition catadef ON chdt.CATEGORYID=catadef.CATEGORYID 
LEFT JOIN SubCategoryDefinition subcatadef ON chdt.SUBCATEGORYID=subcatadef.SUBCATEGORYID 
LEFT JOIN ItemDefinition itemdef1 ON chdt.ITEMID=itemdef1.ITEMID 
LEFT JOIN ImpactDefinition impactdef ON chdt.IMPACTID=impactdef.IMPACTID 
LEFT JOIN ChangeToCharge changeCharge ON chdt.CHANGEID=changeCharge.CHANGEID 
LEFT JOIN ChargesTable chargeTable ON changeCharge.CHARGEID=chargeTable.CHARGEID 
LEFT JOIN AaaUser ownaaa1 ON chargeTable.TECHNICIANID=ownaaa1.USER_ID 
LEFT JOIN ChangeToDescription chandes ON chdt.CHANGEID=chandes.CHANGEID 
LEFT JOIN SiteDefinition siteDef ON chdt.SITEID=siteDef.SITEID 
LEFT JOIN SDOrganization sdo ON siteDef.SITEID=sdo.ORG_ID 
LEFT JOIN RiskDefinition riskDef ON chdt.RISKID=riskDef.RISKID 
LEFT JOIN QueueDefinition qd ON chdt.GROUPID=qd.QUEUEID 
LEFT JOIN ReasonForChangeDetails rfc ON chdt.REASONFORCHANGEID=rfc.ID 
LEFT JOIN Change_StageDefinition stageDef ON chdt.WFSTAGEID=stageDef.WFSTAGEID 
LEFT JOIN Change_StatusDefinition statusDef ON chdt.WFSTATUSID=statusDef.WFSTATUSID 
LEFT JOIN ChangeWF_Definition wfDef ON chdt.WFID=wfDef.ID 
LEFT JOIN ChangeTemplate tempDef ON chdt.TEMPLATEID=tempDef.TEMPLATEID 
LEFT JOIN AaaUser cmDef ON chdt.CHANGEMANAGERID=cmDef.USER_ID 
LEFT JOIN ChangeToClosureCode clcodeMapDef ON chdt.CHANGEID=clcodeMapDef.CHANGEID 
LEFT JOIN Change_ClosureCode clcodeDef ON clcodeMapDef.ID=clcodeDef.ID 
LEFT JOIN changeresolution cr ON cr.changeid=chdt.changeid -- add rollout plan
INNER JOIN AccountSiteMapping asm ON chdt.siteid=asm.siteid 
INNER JOIN AccountDefinition ad ON asm.accountid=ad.org_id 
WHERE  (asm.ACCOUNTID IN (1,3,602))
LIMIT 10

