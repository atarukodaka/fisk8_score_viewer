
## TODO
- partial table_headers

## v1.0.0-pre5
- updater: force オプション

## v1.0.0-pre4
- skater\_name で引かずに isu_number で引くように
- upate_score() では rank から category_results を見て skater を取得する

## v1.0.0-pre3
- accept_categories=MEN,LADIES rake update で MEN と LADIES だけ更新
- update_skaters() -> update_skater_bio()
- 表記ゆれ対策：config/unify\_skater_name.yaml にハッシュで名前統一
- Fisk8Viewer::Parser::[Score|CompetitionSummary|CategoryResult]Parserに元となるパーサー郡を作り、固有のは Fisk8Viewer::Parsers::* で実装することに

## v1.0.0-pre2

## v1.0.0-pre1
- タグ打ち
