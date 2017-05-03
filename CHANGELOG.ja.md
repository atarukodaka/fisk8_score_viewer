
## TODO
- rake unify で config/unify_skater_name.yaml を上書きする
- set :filter_keys でいいのか？
- partial table_headers
- ペア、アイスダンスで '/' を含むと splat_to_params が機能しない

## v1.0.0-pre4
- skater_nameで引かずに isu_number で引くように
- SegmentResultを新設


## v1.0.0-pre3
- accept_categories=MEN,LADIES rake update で MEN と LADIES だけ更新
- update_skaters() -> update_skater_bio()
- 表記ゆれ対策：config/unify\_skater_name.yaml にハッシュで名前統一
- Fisk8Viewer::Parser::[Score|CompetitionSummary|CategoryResult]Parserに元となるパーサー郡を作り、固有のは Fisk8Viewer::Parsers::* で実装することに

## v1.0.0-pre2

## v1.0.0-pre1
- タグ打ち
