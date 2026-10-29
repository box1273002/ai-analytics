-- One row per day and currency, with the last published rate carried forward
-- over days with no rate (rate_is_filled marks those days). GBP is included with a rate of 1.

with days as (

    select cast(d as date) as rate_date
    from generate_series(
        (select min(rate_date) from {{ ref('bronze_fx_rates') }}),
        cast('{{ var("calendar_end") }}' as date),
        interval 1 day
    ) as t(d)

),

currencies as (

    select distinct currency from {{ ref('bronze_fx_rates') }}

),

grid as (

    select days.rate_date, currencies.currency
    from days cross join currencies

),

filled as (

    select
        grid.rate_date,
        grid.currency,
        last_value(fx.rate_to_gbp ignore nulls) over (
            partition by grid.currency order by grid.rate_date
        ) as rate_to_gbp,
        fx.rate_to_gbp is null as rate_is_filled
    from grid
    left join {{ ref('bronze_fx_rates') }} as fx
        on fx.rate_date = grid.rate_date and fx.currency = grid.currency

)

select rate_date, currency, rate_to_gbp, rate_is_filled from filled
union all
select rate_date, 'GBP' as currency, 1.0 as rate_to_gbp, false as rate_is_filled from days
