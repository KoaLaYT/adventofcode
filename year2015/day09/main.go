package main

import "koalayt/adventofcode/year2015/internal"

func main() {
	f := internal.OpenInputFile()
	defer f.Close()

	l := ParseLocations(f)

	internal.Solve("Part One", func() int {
		return l.Shortest()
	})

	internal.Solve("Part Two", func() int {
		return l.Longest()
	})
}
