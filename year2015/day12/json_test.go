package main

import (
	"strings"
	"testing"
)

func TestSumNumbers(t *testing.T) {
	type testcase struct {
		input  string
		expect int
	}

	testcases := []testcase{
		{"[1,2,3]", 6},
		{`{"a":2,"b":4}`, 6},
		{"[[[3]]]", 3},
		{`{"a":{"b":4},"c":-1}`, 3},
		{`{"a":[-1,1]}`, 0},
		{`[-1,{"a":1}]`, 0},
		{"[]", 0},
		{"{}", 0},
	}

	for _, tt := range testcases {
		got := SumNumbers(strings.NewReader(tt.input))
		if got != tt.expect {
			t.Fatalf("%s, got: %d, expect: %d",
				tt.input, got, tt.expect)
		}
	}
}

func TestSumNumbersIgnoreRed(t *testing.T) {
	type testcase struct {
		input  string
		expect int
	}

	testcases := []testcase{
		{"[1,2,3]", 6},
		{`[1,{"c":"red","b":2},3]`, 4},
		{`[1,{"b":2,"c":"red"},3]`, 4},
		{`{"d":"red","e":[1,2,3,4],"f":5}`, 0},
		{`{"a":1,"b":{"d":"red","e":[1,2,3,4],"f":5},"c":"red"}`, 0},
		{`[1,"red",5,{"c":1,"a":"red","b":1}]`, 6},
		{`{"a":1,"b":[1,"red"],"c":3}`, 5},
		{`{"e":86,"c":23,"a":{"a":[120,169,"green","red","orange"]},"b":"red"}`, 0},
		{`{"e":[[{"e":86,"c":23,"a":{"a":[120,169,"green","red","orange"],"b":"red"},"g":"yellow","b":["yellow"],"d":"red","f":-19},{"e":-47,"a":[2],"d":{"a":"violet"},"c":"green","h":"orange","b":{"e":59,"a":"yellow","d":"green","c":47,"h":"red","b":"blue","g":"orange","f":["violet",43,168,78]},"g":"orange"}]]}`, -45},
	}

	for _, tt := range testcases {
		got := SumNumbersIgnoreRed(strings.NewReader(tt.input))
		if got != tt.expect {
			t.Fatalf("%s, got: %d, expect: %d",
				tt.input, got, tt.expect)
		}
	}
}
