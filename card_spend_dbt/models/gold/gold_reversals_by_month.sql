-- Number and GBP value of reversals by month.
select
    month,
    count(*)                    as reversals,
    round(-sum(amount_gbp), 2)  as value_gbp
from {{ ref('silver_transactions') }}
where is_reversal
group by month
order by month
