# Backend Test

## Run
```bash
go run .
```

## Test
```bash
go test ./...
go test -race ./...
```

The slice is divided into chunks. Each chunk is processed by a goroutine. Workers communicate only by sending their local sum to a buffered channel. A `WaitGroup` closes the channel after every worker finishes, so there is no concurrent write to shared total state.
