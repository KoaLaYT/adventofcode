package main

import "testing"

func TestSanta(t *testing.T) {
	type testcase struct {
		input  []byte
		expect int
	}

	testcases := []testcase{
		{[]byte(">"), 2},
		{[]byte("^>v<"), 4},
		{[]byte("^v^v^v^v^v"), 2},
	}

	for _, tt := range testcases {
		s := NewSanta()
		s.Deliver(tt.input)
		result := s.Visited()
		if result != tt.expect {
			t.Fatalf("input %s, got %d, expect %d",
				string(tt.input), result, tt.expect)
		}
	}
}

func TestSantaWithRobo(t *testing.T) {
	type testcase struct {
		input  []byte
		expect int
	}

	testcases := []testcase{
		{[]byte("^>"), 3},
		{[]byte("^>v<"), 3},
		{[]byte("^v^v^v^v^v"), 11},
	}

	for _, tt := range testcases {
		s := NewSantaWithRobo()
		s.Deliver(tt.input)
		result := s.Visited()
		if result != tt.expect {
			t.Fatalf("input %s, got %d, expect %d",
				string(tt.input), result, tt.expect)
		}
	}

}
