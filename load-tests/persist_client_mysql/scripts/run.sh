#!/bin/bash -e
# Runs every scenario of scenarios.tsv in turn and prints one PERF_RESULT line per scenario.
set -e
source base-scenario.sh

test_name="persist_client_mysql"
users=60
duration=300
warmup=60
orders=100000

echo "Waiting for the service and the seeded database"
for i in $(seq 360); do
    code=$(curl -s -o /dev/null -w '%{http_code}' "http://bal.perf.test/bare/get_by_key/1" || true)
    [[ "$code" == "200" ]] && break
    sleep 10
done
[[ "$code" == "200" ]] || { echo "The service did not become ready"; exit 1; }

mkdir -p "$resultsDir"
summary="$resultsDir/summary.csv"
header="Label,# Samples,Average,Median,90% Line,95% Line,99% Line,Min,Max,Error %,Throughput,Received KB/sec,Std. Dev.,Date,Payload,Users"
[[ -f "$summary" ]] || echo "$header" > "$summary"

while IFS=$'\t' read -r name method path body; do
    [[ -z "$name" ]] && continue
    echo "-------- $name --------"
    jtl="$resultsDir/$name.jtl"
    rm -f "$jtl"
    jmeter -n -t "$scriptsDir/request.jmx" -l "$jtl" -Jusers="$users" -Jduration="$duration" -JrampUpPeriod=30 \
        -Jhost=bal.perf.test -Jport=80 -Jprotocol=http -Jmethod="$method" \
        -Jpath="${path//ORDERS/$orders}" -Jbody="${body//ORDERS/$orders}" \
        -Jjmeter.save.saveservice.output_format=csv -Jjmeter.save.saveservice.print_field_names=true
    row=$(awk -F',' -v warmup="$warmup" '
        function at(q,  i) { i = int(n * q); return i < 1 ? 1 : i }
        NR == 1 { for (i = 1; i <= NF; i++) col[$i] = i; next }
        first == "" { first = $col["timeStamp"] }
        $col["timeStamp"] - first < warmup * 1000 { next }
        {
            n++; t = $col["elapsed"]; sum += t; sumsq += t * t; times[n] = t; last = $col["timeStamp"]
            bytes += $col["bytes"]
            if ($col["success"] != "true") errors++
            if (start == "") start = $col["timeStamp"]
        }
        END {
            if (n == 0) { print "0,0,0,0,0,0,0,0,100.00%,0,0,0"; exit }
            asort(times)
            span = (last - start) / 1000; if (span <= 0) span = 1
            avg = sum / n; sd = sqrt(sumsq / n - avg * avg)
            printf "%d,%.0f,%d,%d,%d,%d,%d,%d,%.2f%%,%.1f,%.1f,%.2f", n, avg, times[at(0.5)], times[at(0.9)],
                times[at(0.95)], times[at(0.99)], times[1], times[n], 100 * errors / n, n / span,
                bytes / 1024 / span, sd
        }' "$jtl")
    echo "$name,$row,$(date +%s),0,$users" >> "$summary"
    echo "PERF_RESULT,$test_name,$name,$users,$row"
    rm -f "$jtl"
done < "$scriptsDir/scenarios.tsv"
