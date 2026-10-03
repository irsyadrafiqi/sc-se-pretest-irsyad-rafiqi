package main

import (
	"fmt"
	"sync"
)

const workerCount = 4

// sumEvenConcurrent splits a large integer slice into workerCount chunks.
// Each worker calculates its local sum and sends the result through a channel.
func sumEvenConcurrent(numbers []int, workers int) int64 {
	if len(numbers) == 0 {
		return 0
	}
	if workers < 1 {
		workers = 1
	}
	if workers > len(numbers) {
		workers = len(numbers)
	}

	results := make(chan int64, workers)
	var wg sync.WaitGroup

	chunkSize := (len(numbers) + workers - 1) / workers

	for start := 0; start < len(numbers); start += chunkSize {
		end := start + chunkSize
		if end > len(numbers) {
			end = len(numbers)
		}

		chunk := numbers[start:end]
		wg.Add(1)

		go func(values []int) {
			defer wg.Done()

			var localSum int64
			for _, value := range values {
				if value%2 == 0 {
					localSum += int64(value)
				}
			}
			results <- localSum
		}(chunk)
	}

	go func() {
		wg.Wait()
		close(results)
	}()

	var total int64
	for partialSum := range results {
		total += partialSum
	}

	return total
}

func main() {
	numbers := []int{1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 12, 15, 20, 21, 24}
	result := sumEvenConcurrent(numbers, workerCount)
	fmt.Printf("Sum of even numbers: %d\n", result)
}
