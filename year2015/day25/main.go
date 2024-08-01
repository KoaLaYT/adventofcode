package main

import "koalayt/adventofcode/year2015/internal"

func main() {
	row, col := 2981, 3075

	internal.Solve("Part One", func() int64 {
		return GenCode(row, col)
	})
}
