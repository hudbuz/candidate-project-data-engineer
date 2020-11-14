DECLARE @XML XML;
SET @XML = (
    select convert(xml, p.xml) as "xmldata"
    from Projections p
);

DECLARE @handle INT
DECLARE @PrepareXmlStatus INT

EXEC @PrepareXmlStatus= sp_xml_preparedocument @handle OUTPUT, @XML;

with parsed as (
    SELECT p.ProjectionID,x.*
    FROM OPENXML(@handle, '/xml/*[2]', 0) x,dbo.Projections p
),
     labeled as (
         select p2.ProjectionID, p2.parentId, convert(nvarchar, p1.text) as 'colval', convert(nvarchar, p2.localname) as 'colname'
         from parsed p1
                  inner join parsed p2
                             on p1.parentId = p2.id
         where p1.text is not null
           and p2.localname is not null
     ),
pivoted as (
    select *
    from (
             select ProjectionId, parentId, colname, colval
             from labeled
         ) src
             pivot
             (
             max(colval)
             for colname in (
            [Description],
            [MonthYear],
            [Payment],
            [Projected],
            [Deposit])
             ) piv
)
select      p.ProjectionID as "ProjectionId",
            convert(text,p.Description) as "Description",
            convert(DATETIME, p.MonthYear) as "MonthYear",
            case when p.Payment is null then 0.0 else convert(DECIMAL(18,2),p.Payment) end  as "Payment",
            case when p.Projected is null then 0.0 else convert(Decimal(18,2),p.Projected) end as "Projected",
            case when p.Deposit is null then 0.0 else convert(Decimal(18,2), p.Deposit) end as "Deposit"
    into dbo.Projections_clean
from pivoted p
