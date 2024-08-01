package main

import (
	"strings"
	"testing"
)

func TestOlympicsV2(t *testing.T) {
	input := `Comet can fly 14 km/s for 10 seconds, but then must rest for 127 seconds.
Dancer can fly 16 km/s for 11 seconds, but then must rest for 162 seconds.`
	expect := 689
	got := OlympicsV2(strings.NewReader(input), 1000)
	if got != expect {
		t.Fatalf("got: %d, expect: %d", got, expect)
	}
}

func TestParseReindeer(t *testing.T) {
	input := "Vixen can fly 18 km/s for 5 seconds, but then must rest for 84 seconds."
	expect := &Reindeer{
		name:       "Vixen",
		flySpeed:   18,
		flySecond:  5,
		restSecond: 84,
	}
	got := ParseReindeer(input)

	if !got.IsEqual(expect) {
		t.Fatalf("%s, got: %v, expect: %v", input, got, expect)
	}

}

func TestRun(t *testing.T) {
	comet := &Reindeer{
		name:       "Comet",
		flySpeed:   14,
		flySecond:  10,
		restSecond: 127,
	}

	dancer := &Reindeer{
		name:       "Dancer",
		flySpeed:   16,
		flySecond:  11,
		restSecond: 162,
	}

	{
		expect := 140
		got := comet.Run(10)
		if got != expect {
			t.Fatalf("Comet run 10 second, got: %d, expect: %d", got, expect)
		}
	}
	{
		expect := 160
		got := dancer.Run(10)
		if got != expect {
			t.Fatalf("Dancer run 10 second, got: %d, expect: %d", got, expect)
		}
	}

	{
		expect := 1120
		got := comet.Run(1000)
		if got != expect {
			t.Fatalf("Comet run 1000 second, got: %d, expect: %d", got, expect)
		}
	}
	{
		expect := 1056
		got := dancer.Run(1000)
		if got != expect {
			t.Fatalf("Dancer run 1000 second, got: %d, expect: %d", got, expect)
		}
	}
}
