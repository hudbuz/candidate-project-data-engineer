with deposits as (
    select p.ProjectionID,
           p.MonthYear as "Month/Year",
           concat('Deposit: ', p.Description) as "Activity",
           p.deposit                           as "Estimated",
           0.0                                 as "Actual",
           p.Projected                                as "Estimated Balance"
    from dbo.Projections_clean p
),
     withdrawals as (
         select p.ProjectionID,
           p.MonthYear as "Month/Year",
           concat('Withdrawal: ', p.Description) as "Activity",
           p.payment                           as "Estimated",
           a.Amount                                as "Actual",
           0                                as "Estimated Balance"
    from dbo.Projections_clean p
         inner join dbo.actuals a
         on p.ProjectionId = a.ProjectionID
         and format(p.MonthYear, 'MMM yyyy') = format(a.DateDeposited, 'MMM yyyy')

     ),
     unioned as (
         select *
         from deposits
         union
         select *
         from withdrawals
     ),
     projections as (
         select u1.ProjectionId,
                format(u1.[Month/Year], 'MMM yyyy') as "Month/Year",
                u1.Activity,
                case when u1.Actual = 0.00 then u1.Estimated else u1.Estimated * -1 end as "Estimated",
                u1.Actual,
                sum(u1.[Estimated Balance]) as 'Estimated Balance'
         from unioned u1
         group by u1.ProjectionId,
                  format(u1.[Month/Year], 'MMM yyyy'),
                  u1.Activity,
                  u1.Estimated,
                  u1.Actual

     )
select *
into dbo.Projections_chart
from projections
