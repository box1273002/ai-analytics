-- Posted card spend in GBP by month and customer segment.
select
    month,
    segment,
    round(sum(amount_gbp), 2) as spend_gbp,
    count(*)                  as transactions
from {{ ref('silver_transactions') }}
where status = 'POSTED'
group by month, segment
order by month, segment
