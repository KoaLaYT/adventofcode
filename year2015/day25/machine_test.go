package main

import "testing"

func TestGenCode(t *testing.T) {
	type testcase struct {
		input  [2]int
		expect int64
	}

	testcases := []testcase{
		{[2]int{2, 1}, 31916031},
		{[2]int{6, 6}, 27995004},
	}

	for _, tt := range testcases {
		got := GenCode(tt.input[0], tt.input[1])
		if got != tt.expect {
			t.Fatalf("(%d,%d), got: %d, expect: %d",
				tt.input[0], tt.input[1], got, tt.expect)
		}
	}
}
