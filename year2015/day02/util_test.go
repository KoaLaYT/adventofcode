package main

import "testing"

func TestParse(t *testing.T) {
	type testcase struct {
		input  string
		expect []int
	}
	cases := []testcase{
		{"21x13x21", []int{21, 13, 21}},
		{"1x1x2", []int{1, 1, 2}},
	}

	for _, tt := range cases {
		l, w, h := Parse(tt.input)
		if l != tt.expect[0] ||
			w != tt.expect[1] ||
			h != tt.expect[2] {
			t.Fatalf("%s Parse failed, got %dx%dx%d, expect %v",
				tt.input, l, w, h, tt.expect)
		}
	}
}
