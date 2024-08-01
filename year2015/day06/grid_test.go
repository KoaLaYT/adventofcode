package main

import "testing"

func TestParseInstruction(t *testing.T) {
	type testcase struct {
		input  string
		expect Instruction
	}

	testcases := []testcase{
		{
			"toggle 461,550 through 564,900",
			Instruction{
				Toggle,
				550, 900,
				461, 564,
			},
		},
		{
			"turn on 583,543 through 846,710",
			Instruction{
				TurnOn,
				543, 710,
				583, 846,
			},
		},
		{
			"turn off 367,664 through 595,872",
			Instruction{
				TurnOff,
				664, 872,
				367, 595,
			},
		},
	}

	for _, tt := range testcases {
		result := ParseInstruction(tt.input)
		if !result.Equal(tt.expect) {
			t.Fatalf("%s, got %v, expect %v", tt.input, result, tt.expect)
		}
	}
}
