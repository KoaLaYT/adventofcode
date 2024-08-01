package main

import "koalayt/adventofcode/year2015/internal"

func main() {
	f := internal.OpenInputFile()
	defer f.Close()

	c := ParseContainers(f)

	internal.Solve("Part One", func() int {
		return c.Fill(150)
	})

	internal.Solve("Part Two", func() int {
		return c.FillMinWays(150)
	})
}
