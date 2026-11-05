-- The silver table the gold layer reads: latest transactions plus customer segment
-- and a GBP amount. Cards missing from the customer master get segment 'Unknown'.
-- Reversals are linked to the purchase they cancel (original_found, original_amount).

select
    t.txn_id,
    t.ref_txn_id,
    t.card_id,
    t.merchant_clean,
    t.amount,
    t.currency,
    t.status,
    t.ts,
    strftime(t.ts, '%Y-%m')              as month,
    coalesce(c.segment, 'Unknown')       as segment,
    c.card_id is not null                as customer_known,
    fx.rate_to_gbp                       as rate,
    t.amount * fx.rate_to_gbp            as amount_gbp,
    t.status = 'REVERSED'                as is_reversal,
    t.amount = 0                         as zero_amount,
    t.currency <> 'GBP'                  as is_foreign_currency,
    case when t.status = 'REVERSED' then o.txn_id is not null end as original_found,
    o.amount                             as original_amount
from {{ ref('silver_transactions_latest') }} as t
left join {{ ref('silver_cards') }}    as c  on c.card_id = t.card_id
left join {{ ref('silver_transactions_latest') }} as o on o.txn_id = t.ref_txn_id
left join {{ ref('silver_fx_daily') }} as fx on fx.rate_date = cast(t.ts as date)
                                            and fx.currency  = t.currency
