package main

import "testing"

func TestIncrPasswd(t *testing.T) {
	type testcase struct {
		input  string
		expect string
	}

	testcases := []testcase{
		{"xx", "xy"},
		{"xy", "xz"},
		{"xz", "ya"},
		{"ya", "yb"},
	}

	for _, tt := range testcases {
		got := incrPasswd(tt.input)
		if got != tt.expect {
			t.Logf("%s, got: %s, expect: %s",
				tt.input, got, tt.expect)
		}
	}
}

func TestNextPasswd(t *testing.T) {
	type testcase struct {
		input  string
		expect string
	}

	testcases := []testcase{
		{"abcdefgh", "abcdffaa"},
		{"ghijklmn", "ghjaabcc"},
	}

	for _, tt := range testcases {
		got := NextPasswd(tt.input)
		if got != tt.expect {
			t.Fatalf("%s, got: %s, expect: %s",
				tt.input, got, tt.expect)
		}
	}
}
