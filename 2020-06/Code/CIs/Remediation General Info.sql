SELECT DISTINCT s.Netbios_Name0
, ciprop.DisplayName AS [ConfigurationBaselineName]
, ciprop.Description AS [ConfigurationBaselineDescription]
, statename.StateName
, remhist.RemediationDate
, remhist.UserName
, remhist.FullName
, remhist.CI_UniqueID
, remhist.CIVersion
, remhist.ModelName
FROM v_CIRemediationHistory remhist
JOIN v_LocalizedCIProperties ciprop ON ciprop.CI_ID = remhist.CI_ID
JOIN v_R_System_Valid s ON s.ResourceID = remhist.ResourceID
JOIN v_StateNames statename ON statename.StateID = remhist.ComplianceState 
WHERE statename.TopicType = 401