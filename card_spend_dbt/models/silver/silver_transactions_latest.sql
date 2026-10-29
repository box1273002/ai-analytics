-- One row per transaction: the latest status we have for it.
-- Steps: drop exact duplicate rows, tidy text, read both timestamp formats,
-- then keep the row from the latest file (higher status wins a same-file tie).

with raw as (

    select distinct *
    from {{ ref('bronze_card_transactions') }}

),

tidied as (

    select
        txn_id,
        ref_txn_id,
        card_id,
        upper(regexp_replace(trim(merchant), '\s+', ' ', 'g')) as merchant_clean,
        amount,
        upper(trim(currency))                                  as currency,
        status,
        coalesce(
            try_strptime(txn_timestamp, '%d/%m/%Y %H:%M'),
            try_strptime(txn_timestamp, '%Y-%m-%d %H:%M:%S')
        )                                                      as ts,
        cast(file_date as date)                                as file_date,
        case status when 'PENDING' then 0
                    when 'POSTED'  then 1
                    when 'REVERSED' then 2 end                 as status_rank
    from raw

),

ranked as (

    select *,
        row_number() over (
            partition by txn_id
            order by file_date desc, status_rank desc
        ) as rn
    from tidied

)

select * exclude (status_rank, rn)
from ranked
where rn = 1
