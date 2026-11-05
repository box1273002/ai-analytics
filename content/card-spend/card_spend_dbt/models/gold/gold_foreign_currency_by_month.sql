-- Posted spend in a currency other than GBP, by month.
select
    month,
    count(distinct card_id)   as cards,
    count(*)                  as transactions,
    round(sum(amount_gbp), 2) as spend_gbp
from {{ ref('silver_transactions') }}
where status = 'POSTED' and is_foreign_currency
group by month
order by month
