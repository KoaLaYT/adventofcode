package main

import (
	"strings"
	"testing"
)

func TestGridUpdate(t *testing.T) {
	initial := `
.#.#.#
...##.
#....#
..#...
#.#..#
####..`
	g := NewGrid(strings.NewReader(initial))

	expects := []string{
		`
..##..
..##.#
...##.
......
#.....
#.##..
`,
		`
..###.
......
..###.
......
.#....
.#....
`,
		`
...#..
......
...#..
..##..
......
......
`,
		`
......
......
..##..
..##..
......
......
`,
	}

	for i, expect := range expects {
		g.UpdateOne()
		got := g.Print()

		if got != expect {
			t.Fatalf("Round %d, got: %s, expect: %s", i+1, got, expect)
		}
	}

	expect := 4
	got := g.OnLights()
	if got != expect {
		t.Fatalf("got: %d, expect: %d", got, expect)
	}
}

func TestGridUpdateV2(t *testing.T) {
	initial := `
.#.#.#
...##.
#....#
..#...
#.#..#
####..`
	expect := 17
	g := NewGrid(strings.NewReader(initial))
	g.UpdateV2(5)
	got := g.OnLights()

	if got != expect {
		t.Fatalf("got: %d, expect: %d", got, expect)
	}
}
