実行ボタンを押下した際に、読み込んだユーザーデータのequipListの情報を整理し出力する

reliquary.appendPropIdList 最初の5桁と最後の1桁で分割する（501054の場合、50105と4に分ける）
appendPropIdList[0]がreliquarySubstats[0]と紐づく
appendPropIdList[1]がreliquarySubstats[1]と紐づく
appendPropIdList[2]がreliquarySubstats[2]と紐づく
appendPropIdList[3]がreliquarySubstats[3]と紐づく
appendPropIdList[4]以降は、最初の5桁を確認しそれと一致するreliquarySubstatsに含める

reliquarySubstats の4つと reliquaryMainstat の内容を出力する。

【実行例と想定される結果】
渡されたユーザーデータサンプル
```
"reliquary.appendPropIdList": [501054, 501202, 501233, 501224, 501202, 501204, 501223, 501203, 501224]
"reliquarySubstats": [
    {
    "appendPropId": "FIGHT_PROP_ATTACK",
    "statValue": 19
    },
    {
    "appendPropId": "FIGHT_PROP_CRITICAL",
    "statValue": 13.6
    },
    {
    "appendPropId": "FIGHT_PROP_CHARGE_EFFICIENCY",
    "statValue": 5.8
    },
    {
    "appendPropId": "FIGHT_PROP_CRITICAL_HURT",
    "statValue": 22.5
    }
]
```

この時、reliquarySubstats[0]の"FIGHT_PROP_ATTACK"は識別名"50105"
reliquarySubstats[1]の"FIGHT_PROP_CRITICAL"は識別名"50120"
reliquarySubstats[2]の"FIGHT_PROP_CHARGE_EFFICIENCY"は識別名"50123"
reliquarySubstats[3]の"FIGHT_PROP_CRITICAL_HURT"は識別名"50122"と紐づく。

その後、reliquarySubstatsの内容に識別子と"statAppendList"を追加し、識別子のあとに付いていた数字を追加する。
すでに存在する識別子に対しては、"statAppendList"に数字を追加することをreliquary.appendPropIdListすべてに対して繰り返す。
結果として以下のようになる。

```
"reliquarySubstats": [
    {
    "appendPropId": "FIGHT_PROP_ATTACK",
    "statValue": 19,
    "identifier": "50105",
    "statAppendList": [4]
    },
    {
    "appendPropId": "FIGHT_PROP_CRITICAL",
    "statValue": 13.6,
    "identifier": "50120",
    "statAppendList": [2, 2, 4, 3]
    },
    {
    "appendPropId": "FIGHT_PROP_CHARGE_EFFICIENCY",
    "statValue": 5.8,
    "identifier": "50123",
    "statAppendList": [3]
    },
    {
    "appendPropId": "FIGHT_PROP_CRITICAL_HURT",
    "statValue": 22.5,
    "identifier": "50122",
    "statAppendList": [4, 3, 4]
    }
]
```

これらをWeb上に出力する。