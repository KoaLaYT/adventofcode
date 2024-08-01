package main

import "testing"

func TestIsNiceString(t *testing.T) {
	type testcase struct {
		input  string
		expect bool
	}

	testcases := []testcase{
		{"ugknbfddgicrmopn", true},
		{"aaa", true},
		{"jchzalrnumimnmhp", false},
		{"haegwjzuvuyypxyu", false},
		{"dvszwmarrgswjxmb", false},
	}

	for _, tt := range testcases {
		result := IsNiceString(tt.input)
		if result != tt.expect {
			t.Fatalf("%s: got %v, expect %v", tt.input, result, tt.expect)
		}
	}
}

func TestIsNiceStringV2(t *testing.T) {
	type testcase struct {
		input  string
		expect bool
	}

	testcases := []testcase{
		{"qjhvhtzxzqqjkmpb", true},
		{"xxyxx", true},
		{"uurcxstgmygtbstg", false},
		{"ieodomkazucvgmuy", false},
	}

	for _, tt := range testcases {
		result := IsNiceStringV2(tt.input)
		if result != tt.expect {
			t.Fatalf("%s: got %v, expect %v", tt.input, result, tt.expect)
		}
	}
}
