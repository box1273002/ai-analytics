# card_spend_dbt

A small dbt project (dbt-duckdb) for a fictional retail bank's card-spend data.
Bronze tables are loaded from CSV seeds; silver and gold are SQL models; tests are in models/schema.yml.
Run from this folder:  dbt build --profiles-dir .

## Mapping to the Part 1 utilities.py steps
| Model | Steps it contains |
|---|---|
| silver_transactions_latest | drop_exact_duplicates, standardise_currency_codes, standardise_merchant_text, parse_timestamps, keep_latest_status_per_transaction |
| silver_cards | standardise_segment_labels, latest_customer_snapshot_per_card |
| silver_fx_daily | build_fx_calendar, fill_missing_fx_rates, flag_filled_fx_rates (rate_is_filled), add_gbp_rate |
| silver_transactions | derive_transaction_date_and_month (month), flag_reversals, flag_zero_amount, flag_foreign_currency, link_reversals_to_original, add_segment_from_latest_snapshot, add_fx_rate_to_transactions, add_gbp_amount |
| schema.yml tests | check_one_row_per_transaction (unique, not_null on txn_id) |
