package internal

import (
	"testing"
)

func TestMustAtoi(t *testing.T) {
	type testcase struct {
		input  string
		expect int
	}

	testcases := []testcase{
		{"+123", 123},
		{"-1", -1},
		{"0", 0},
	}

	for _, tt := range testcases {
		got := MustAtoi[int](tt.input)
		if got != tt.expect {
			t.Fatalf("%s, got: %d, expect: %d", tt.input, got, tt.expect)
		}
	}
}
