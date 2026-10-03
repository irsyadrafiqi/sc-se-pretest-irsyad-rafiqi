package main

import "testing"

func TestSumEvenConcurrent(t *testing.T) {
	tests := []struct {
		name     string
		numbers  []int
		workers  int
		expected int64
	}{
		{"basic", []int{1, 2, 3, 4, 5, 6}, 4, 12},
		{"empty", []int{}, 4, 0},
		{"more workers than data", []int{2, 4, 8}, 10, 14},
		{"negative values", []int{-4, -3, -2, 1}, 2, -6},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			got := sumEvenConcurrent(tt.numbers, tt.workers)
			if got != tt.expected {
				t.Fatalf("got %d, expected %d", got, tt.expected)
			}
		})
	}
}
