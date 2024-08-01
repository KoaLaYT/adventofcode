package main

import (
	"strings"
	"testing"
)

func TestStirngCount(t *testing.T) {
	type testcase struct {
		input        string
		codeExpect   int
		memoryExpect int
	}

	testcases := []testcase{
		{`""`, 2, 0},
		{`"abc"`, 5, 3},
		{`"aaa\"aaa"`, 10, 7},
		{`"\x27"`, 6, 1},
	}

	for _, tt := range testcases {
		codeResult := CountStringCode(tt.input)
		memoryResult := CountStringMemory(tt.input)

		if codeResult != tt.codeExpect {
			t.Fatalf("count code: %s, got: %d, expect: %d",
				tt.input, codeResult, tt.codeExpect)
		}

		if memoryResult != tt.memoryExpect {
			t.Fatalf("count memory: %s, got: %d, expect: %d",
				tt.input, memoryResult, tt.memoryExpect)
		}
	}
}

func TestCountDiff(t *testing.T) {
	input := `
""
"abc"
"aaa\"aaa"
"\x27"
`
	expect := 12
	result := CountDiff(strings.NewReader(input))

	if result != expect {
		t.Fatalf("got: %d, expect: %d", result, expect)
	}
}

func TestCountDiffV2(t *testing.T) {
	input := `
""
"abc"
"aaa\"aaa"
"\x27"
`
	expect := 19
	result := CountDiffV2(strings.NewReader(input))

	if result != expect {
		t.Fatalf("got: %d, expect: %d", result, expect)
	}
}

func TestCountEncodedDiff(t *testing.T) {
	type testcase struct {
		input  string
		expect int
	}

	testcases := []testcase{
		{`""`, 4},
		{`"abc"`, 4},
		{`"aaa\"aaa"`, 6},
		{`"\x27"`, 5},
	}

	for _, tt := range testcases {
		result := CountEncodedDiff(tt.input)
		if result != tt.expect {
			t.Fatalf("count encoded diff: %s, got: %d, expect: %d",
				tt.input, result, tt.expect)
		}
	}
}
