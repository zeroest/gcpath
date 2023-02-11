
#!/bin/bash

## $1 serviceName
## $2 requestAt gte
## $3 path

curl -s --location --request GET 'https://es-log.service.com/http_logs__*/_search' \
--header 'Content-Type: application/json' \
--data-raw '{
    "query":{
        "bool":{
            "must":[
                {
                    "term":{
                        "serviceName":"'$1'"
                    }
                },
                {
                    "range":{
                        "requestAt":{
                            "gte":"'$2'"
                        }
                    }
                },
                {
                  "match": {
                    "originalUri.keyword": "'$3'"
                  }
                }
            ]
        }
    },
    "aggs":{
        "terms_aggs":{
            "terms":{
                "field":"originalUri.keyword",
                "size":9999999
            },
            "aggs":{
                "stats_aggs":{
                    "stats":{
                        "field":"elapsedTime"
                    }
                }
            }
        }
    },
    "size": 0
}'

