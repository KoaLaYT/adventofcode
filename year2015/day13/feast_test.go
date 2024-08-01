package main

import (
	"strings"
	"testing"
)

func TestOptimal(t *testing.T) {
	f := &Feast{
		people: []string{"Alice", "Bob", "Carol", "David"},
		arrangements: []Arrangement{
			{"Alice", "Bob", 54},
			{"Alice", "Carol", -79},
			{"Alice", "David", -2},
			{"Bob", "Alice", 83},
			{"Bob", "Carol", -7},
			{"Bob", "David", -63},
			{"Carol", "Alice", -62},
			{"Carol", "Bob", 60},
			{"Carol", "David", 55},
			{"David", "Alice", 46},
			{"David", "Bob", -7},
			{"David", "Carol", 41},
		},
	}
	expect := 330
	got := f.Optimal()
	if got != expect {
		t.Fatalf("got: %d, expect: %d", got, expect)
	}
}

func TestParseArrangement(t *testing.T) {
	type testcase struct {
		input  string
		expect Arrangement
	}

	testcases := []testcase{
		{
			`Alice would gain 54 happiness units by sitting next to Bob.`,
			Arrangement{"Alice", "Bob", 54},
		},
		{
			`Alice would lose 1 happiness units by sitting next to David.`,
			Arrangement{"Alice", "David", -1},
		},
	}

	for _, tt := range testcases {
		got := ParseArrangement(tt.input)
		if !got.IsEqual(tt.expect) {
			t.Fatalf("%s, got: %v, expect: %v", tt.input, got, tt.expect)
		}
	}
}

func TestParseFeast(t *testing.T) {
	input := `
Alice would gain 54 happiness units by sitting next to Bob.
Alice would lose 79 happiness units by sitting next to Carol.
Alice would lose 2 happiness units by sitting next to David.
Bob would gain 83 happiness units by sitting next to Alice.
Bob would lose 7 happiness units by sitting next to Carol.
Bob would lose 63 happiness units by sitting next to David.
Carol would lose 62 happiness units by sitting next to Alice.
Carol would gain 60 happiness units by sitting next to Bob.
Carol would gain 55 happiness units by sitting next to David.
David would gain 46 happiness units by sitting next to Alice.
David would lose 7 happiness units by sitting next to Bob.
David would gain 41 happiness units by sitting next to Carol.
`
	expect := 330

	f := ParseFeast(strings.NewReader(input))
	got := f.Optimal()
	if got != expect {
		t.Fatalf("got: %d, expect: %d", got, expect)
	}
}
