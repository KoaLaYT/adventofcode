package main

import "testing"

func TestFill(t *testing.T) {
	c := &Containers{
		liters: []int{20, 15, 10, 5, 5},
	}

	type testcase struct {
		input  int
		expect int
	}

	testcases := []testcase{
		{5, 2},
		{10, 2},
		{25, 4},
		{30, 4},
		{35, 4},
		{40, 3},
	}

	for _, tt := range testcases {
		got := c.Fill(tt.input)
		if got != tt.expect {
			t.Fatalf("fill %d, got: %d, expect: %d", tt.input, got, tt.expect)
		}
	}
}
