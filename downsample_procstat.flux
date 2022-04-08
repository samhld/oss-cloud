import "influxdata/influxdb/schema"
import "experimental"

option task = {name: "top10_procstat_5m", every: 5m}

from(bucket: "sam-bucket")
    |> range(start: -55m)
    |> filter(fn: (r) => r["_measurement"] == "procstat")
    |> filter(fn: (r) => r["_field"] == "memory_usage" or r["_field"] == "memory_swap" or r["_field"] == "cpu_usage")
    |> window(every: 5m)
    |> top(n: 10)
    |> schema.fieldsAsCols()
    |> group()
    |> duplicate(column: "_stop", as: "_time")
    |> window(every: inf)
    |> top(n: 10, columns: ["memory_usage"])
    |> group(columns: ["_measurement"])
    |> experimental.to(bucket: "servers_downsampled")