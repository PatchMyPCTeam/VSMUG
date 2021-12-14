-- Source: https://tcsmug.org/blogs/jeff-carreon/513-what-s-sup
with cte as (SELECT dbo.tbXml.RevisionID, ISNULL(datalength(dbo.tbXml.RootElementXmlCompressed), 0) as LENGTH FROM dbo.tbXml
INNER  JOIN dbo.tbProperty ON dbo.tbXml.RevisionID = dbo.tbProperty.RevisionID
) --order by Length desc
select
  u.UpdateID,
  cte.LENGTH,
  r.RevisionNumber,
  r.RevisionID,
  lp.Title,
  pr.ExplicitlyDeployable as ED,
  pr.UpdateType,
  pr.CreationDate
 from
  tbUpdate u
  inner join tbRevision r on u.LocalUpdateID = r.LocalUpdateID
  inner join tbProperty pr on pr.RevisionID = r.RevisionID
  inner join cte on cte.revisionid = r.revisionid
  inner join tbLocalizedPropertyForRevision lpr on r.RevisionID = lpr.RevisionID
  inner join tbLocalizedProperty lp on lpr.LocalizedPropertyID = lp.LocalizedPropertyID
 where
  lpr.LanguageID = 1033
  and r.RevisionID in (
select
  t1.RevisionID
from
  tbBundleAll t1
  inner join tbBundleAtLeastOne t2 on t1.BundledID=t2.BundledID
where
  ishidden=0 and  pr.ExplicitlyDeployable=1)
order by cte.length desc