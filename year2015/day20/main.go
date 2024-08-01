package main

import (
	"koalayt/adventofcode/year2015/internal"
)

func main() {
	var input int64 = 33100000

	internal.Solve("Part One", func() int64 {
		_, result := LowsetHouseNumber(input)
		return result
	})

	internal.Solve("Part Two", func() int64 {
		return LowsetHouseNumberV2(input)
	})
}
