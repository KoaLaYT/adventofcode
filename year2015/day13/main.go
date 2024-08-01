package main

import "koalayt/adventofcode/year2015/internal"

func main() {
	f := internal.OpenInputFile()
	defer f.Close()

	feast := ParseFeast(f)

	internal.Solve("Part One", func() int {
		return feast.Optimal()
	})

	internal.Solve("Part One", func() int {
		feast.AddMyself("KoaLaYT")
		return feast.Optimal()
	})
}
