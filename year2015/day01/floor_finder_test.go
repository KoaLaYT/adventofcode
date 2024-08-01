package main

import "testing"

func TestFloorFinderV2(t *testing.T) {
	type testcase struct {
		input  string
		expect int
	}
	testcases := []testcase{
		{")", 1},
		{"()())", 5},
	}

	for _, tt := range testcases {
		got := FloorFinderV2(tt.input)
		if tt.expect != got {
			t.Fatalf("input %s, expect %d, got %d", tt.input, tt.expect, got)
		}
	}
}

func TestFloorFinder(t *testing.T) {
	type testcase struct {
		input  string
		expect int
	}
	testcases := []testcase{
		{"(())", 0},
		{"()()", 0},
		{"(((", 3},
		{"(()(()(", 3},
		{"))(((((", 3},
		{"())", -1},
		{"))(", -1},
		{")))", -3},
		{")())())", -3},
	}

	for _, tt := range testcases {
		got := FloorFinder(tt.input)
		if tt.expect != got {
			t.Fatalf("input %s, expect %d, got %d", tt.input, tt.expect, got)
		}
	}
}
