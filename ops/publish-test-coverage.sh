#!/bin/sh
METRIC_VALUE=$(awk -F '[:,]' '{print $2*100}' ./project/xcov_report/report.json | head -1)

curl --request POST \
--url https://verygoodsecurity.atlassian.net/gateway/api/compass/v1/metrics \
--user "alexandr.florinskiy@vgs.io:$COMPASS_API_KEY" \
--header "Accept: application/json" \
--header "Content-Type: application/json" \
--data "{
  \"metricSourceId\": \"ari:cloud:compass:83673fa7-fd28-4f4a-9738-f584064570a7:metric-source/db43f86d-85fe-42e1-954d-457f5a4082b8/0ed7ae69-57f6-4758-b9c8-ea9d55541c0a\",
  \"value\": $METRIC_VALUE,
  \"timestamp\": \"$(date -u +'%Y-%m-%dT%H:%M:%SZ')\"
}"