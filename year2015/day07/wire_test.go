package main

import (
	"strings"
	"testing"
)

func TestParseCircuit(t *testing.T) {
	input := `
123 -> x
456 -> y
x AND y -> d
x OR y -> e
x LSHIFT 2 -> f
y RSHIFT 2 -> g
NOT x -> h
NOT y -> i
`
	expect := map[string]uint16{
		"d": 72,
		"e": 507,
		"f": 492,
		"g": 114,
		"h": 65412,
		"i": 65079,
		"x": 123,
		"y": 456,
	}

	{
		c := ParseCircuit(strings.NewReader(input))
		for _, id := range []string{"d", "e", "f", "g", "h", "i", "x", "y"} {
			result := c.ResolveV1(id)
			if result != expect[id] {
				t.Fatalf("%s, got %d, expect %d", id, result, expect[id])
			}
		}
	}
	{
		c := ParseCircuit(strings.NewReader(input))
		for _, id := range []string{"d", "e", "f", "g", "h", "i", "x", "y"} {
			result := c.ResolveV2(id)
			if result != expect[id] {
				t.Fatalf("%s, got %d, expect %d", id, result, expect[id])
			}
		}
	}
}
