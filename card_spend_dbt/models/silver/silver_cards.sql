-- One row per card: the most recent customer record, with a tidy segment name.

with ranked as (

    select
        card_id,
        customer_id,
        upper(substr(trim(segment), 1, 1)) || lower(substr(trim(segment), 2)) as segment,
        account_status,
        row_number() over (partition by card_id order by snapshot_date desc) as rn
    from {{ ref('bronze_customer_master') }}

)

select card_id, customer_id, segment, account_status
from ranked
where rn = 1
