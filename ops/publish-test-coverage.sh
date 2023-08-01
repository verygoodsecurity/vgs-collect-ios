#!/bin/sh
METRIC_VALUE=$(awk -F '[:,]' '{print $2*100}' ../project/xcov_report/report.json | head -1)

curl --request POST \
--url https://verygoodsecurity.atlassian.net/gateway/api/compass/v1/metrics \
--user "$COMPASS_USER:$COMPASS_API_KEY" \
--header "Accept: application/json" \
--header "Content-Type: application/json" \
--data "{
  \"metricSourceId\": \"$METRIC_SOURCE_ID",
  \"value\": $METRIC_VALUE,
  \"timestamp\": \"$(date -u +'%Y-%m-%dT%H:%M:%SZ')\"
}"
