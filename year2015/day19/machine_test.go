package main

import "testing"

func TestFabrication(t *testing.T) {
	machine := &Machine{
		replacements: [][2]string{
			{"e", "H"},
			{"e", "O"},
			{"H", "HO"},
			{"H", "OH"},
			{"O", "HH"},
		},
	}

	type testcase struct {
		input  string
		expect int
	}

	testcases := []testcase{
		{"HOH", 3},
		{"HOHOHO", 6},
	}

	for _, tt := range testcases {
		_, _, got := machine.Fabrication(tt.input)
		if got != tt.expect {
			t.Fatalf("%s, got: %d, expect: %d", tt.input, got, tt.expect)
		}
	}
}

func TestCalibration(t *testing.T) {
	machine := &Machine{
		replacements: [][2]string{
			{"H", "HO"},
			{"H", "OH"},
			{"O", "HH"},
		},
	}

	type testcase struct {
		input  string
		expect int
	}

	testcases := []testcase{
		{"HOH", 4},
		{"HOHOHO", 7},
	}

	for _, tt := range testcases {
		got := machine.Calibration(tt.input)
		if got != tt.expect {
			t.Fatalf("%s, got: %d, expect: %d", tt.input, got, tt.expect)
		}
	}
}
