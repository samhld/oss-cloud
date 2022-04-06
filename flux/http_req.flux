import "experimental/http/requests"
import "influxdata/influxdb/schema"

from(bucket: "test")
    |> range(start: -30d)
    |> filter(fn: (r) => r._measurement == "cpu")
    |>