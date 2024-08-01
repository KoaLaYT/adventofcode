package main

import "testing"

func TestLookAndSayOneRound(t *testing.T) {
	type testcase struct {
		input  string
		expect string
	}

	testcases := []testcase{
		{"1", "11"},
		{"11", "21"},
		{"21", "1211"},
		{"1211", "111221"},
		{"111221", "312211"},
	}

	for _, tt := range testcases {
		got := LookAndSayOneRound(tt.input)
		if got != tt.expect {
			t.Fatalf("input: %s, got: %s, expect: %s",
				tt.input, got, tt.expect)
		}
	}
}

func TestLookAndSay(t *testing.T) {
	input := "1"
	expect := "312211"
	got := LookAndSay(input, 5)

	if got != expect {
		t.Fatalf("got: %s, expect: %s", got, expect)
	}
}
