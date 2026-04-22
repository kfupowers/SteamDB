PUT http://localhost:9200/games
```json
{
"mappings": {
"properties": {
"title":    { "type": "text" },
"developer":  { "type": "text" },
"price":    { "type": "integer" }
}
}
}
```

POST http://localhost:9200/games/_doc/1
```json
{
  "title": "Team Fortress 2",
  "developer": "Valve",
  "price": 0
}
```


POST http://localhost:9200/games/_doc/2
```json
{
  "title": "Celeste",
  "developer": "Maddy Makes Games Inc.",
  "price": 850
}
```


POST http://localhost:9200/games/_doc/3
```json
{
  "title": "2XKO",
  "developer": "Riot Games",
  "price": 0
}
```

POST http://localhost:9200/games/_search
```json
{
  "query": {
    "match": {
      "price": 0
    }
  }
}
```

```json
{
"took": 9,
"timed_out": false,
"_shards": {
"total": 1,
"successful": 1,
"skipped": 0,
"failed": 0
},
"hits": {
"total": {
"value": 2,
"relation": "eq"
},
"max_score": 1.0,
"hits": [
{
"_index": "games",
"_id": "1",
"_score": 1.0,
"_source": {
"title": "Team Fortress 2",
"developer": "Valve",
"price": "0"
}
},
{
"_index": "games",
"_id": "3",
"_score": 1.0,
"_source": {
"title": "2XKO",
"developer": "Riot Games",
"price": "0"
}
}
]
}
}
```

GET http://localhost:9200/games/_search
```json
{
  "query": {
    "bool": {
      "must": {
            "range": {
                "price": {
                    "lt": 1000
                }
            }
        }
    }
  }
}
```

```json
{
    "took": 54,
    "timed_out": false,
    "_shards": {
        "total": 1,
        "successful": 1,
        "skipped": 0,
        "failed": 0
    },
    "hits": {
        "total": {
            "value": 3,
            "relation": "eq"
        },
        "max_score": 1.0,
        "hits": [
            {
                "_index": "games",
                "_id": "1",
                "_score": 1.0,
                "_source": {
                    "title": "Team Fortress 2",
                    "developer": "Valve",
                    "price": "0"
                }
            },
            {
                "_index": "games",
                "_id": "2",
                "_score": 1.0,
                "_source": {
                    "title": "Celeste",
                    "developer": "Maddy Makes Games Inc.",
                    "price": "850"
                }
            },
            {
                "_index": "games",
                "_id": "3",
                "_score": 1.0,
                "_source": {
                    "title": "2XKO",
                    "developer": "Riot Games",
                    "price": "0"
                }
            }
        ]
    }
}
```


GET http://localhost:9200/games/_search
```json
{
  "query": {
    "bool": {
      "must": [
        { "term": { "price": 0 } },
        { "match": { "developer": "Riot Games" } }
      ]
    }
  }
}
```

```json
{
    "took": 15,
    "timed_out": false,
    "_shards": {
        "total": 1,
        "successful": 1,
        "skipped": 0,
        "failed": 0
    },
    "hits": {
        "total": {
            "value": 1,
            "relation": "eq"
        },
        "max_score": 2.5408845,
        "hits": [
            {
                "_index": "games",
                "_id": "3",
                "_score": 2.5408845,
                "_source": {
                    "title": "2XKO",
                    "developer": "Riot Games",
                    "price": "0"
                }
            }
        ]
    }
}
```