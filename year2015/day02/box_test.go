package main

import "testing"

func TestRibbonFeet(t *testing.T) {
	type testcase struct {
		input  string
		expect int
	}

	cases := []testcase{
		{"2x3x4", 34},
		{"3x2x4", 34},
		{"4x3x2", 34},
		{"1x1x10", 14},
		{"10x1x1", 14},
		{"1x10x1", 14},
		{"10x10x1", 122},
		{"10x1x10", 122},
		{"1x10x10", 122},
	}

	for _, tt := range cases {
		box := NewBox(Parse(tt.input))
		result := box.RibbonFeet()
		if result != tt.expect {
			t.Fatalf("%s failed, got %d, expect %d", tt.input, result, tt.expect)
		}
	}
}
