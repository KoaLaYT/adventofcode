package main

import (
	"strings"
	"testing"
)

func TestParseInstruction(t *testing.T) {
	type testcase struct {
		input  string
		expect Instruction
	}

	testcases := []testcase{
		{"inc a", InstINC{raw: "inc a", register: 'a'}},
		{"jio a, +2", InstJIO{raw: "jio a, +2", register: 'a', offset: 2}},
		{"jmp -1", InstJMP{raw: "jmp -1", offset: -1}},
	}

	for _, tt := range testcases {
		got := ParseInstruction(tt.input)
		if !got.Equal(tt.expect) {
			t.Fatalf("got: %s, expect: %s", got.Debug(), tt.expect.Debug())
		}
	}
}

func TestRunComputer(t *testing.T) {
	input := `
inc a
jio a, +2
tpl a
inc a`

	c := NewComputer(strings.NewReader(input))
	c.Run()

	expect := 2
	got := c.Register('a')

	if got != expect {
		t.Fatalf("got: %d, expect: %d", got, expect)
	}
}
