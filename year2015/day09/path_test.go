package main

import (
	"strings"
	"testing"
)

func TestShortest(t *testing.T) {
	l := &Locations{
		cities: []string{"London", "Dublin", "Belfast"},
		pathes: []Path{
			{"London", "Dublin", 464},
			{"London", "Belfast", 518},
			{"Dublin", "Belfast", 141},
		},
	}

	result := l.Shortest()
	if result != 605 {
		t.Fatalf("got: %d, expect 605", result)
	}
}

func TestParseLocations(t *testing.T) {
	input := `
London to Dublin = 464
London to Belfast = 518
Dublin to Belfast = 141`

	l := ParseLocations(strings.NewReader(input))

	{
		result := l.Shortest()
		if result != 605 {
			t.Fatalf("got: %d, expect 605", result)
		}
	}

	{
		result := l.Longest()
		if result != 982 {
			t.Fatalf("got: %d, expect 982", result)
		}
	}
}
