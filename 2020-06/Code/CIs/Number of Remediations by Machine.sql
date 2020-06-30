SELECT s.Netbios_Name0
, COUNT(s.Netbios_Name0) AS [RemediationAttempts]
, ciprop.DisplayName AS [ConfigurationBaselineName]
, ciprop.Description AS [ConfigurationBaselineDescription]
, remhist.UserName
, remhist.FullName
, remhist.CI_UniqueID
, remhist.CIVersion
, remhist.ModelName
FROM v_CIRemediationHistory remhist
JOIN v_LocalizedCIProperties ciprop ON ciprop.CI_ID = remhist.CI_ID
JOIN v_R_System_Valid s ON s.ResourceID = remhist.ResourceID
GROUP BY s.Netbios_Name0
, ciprop.DisplayName
, ciprop.Description
, remhist.UserName
, remhist.FullName
, remhist.CI_UniqueID
, remhist.CIVersion
, remhist.ModelName