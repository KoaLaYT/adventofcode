package main

import "koalayt/adventofcode/year2015/internal"

func main() {
	input := "1321131112"

	internal.Solve("Part One", func() int {
		result := LookAndSay(input, 40)
		return len(result)
	})

	internal.Solve("Part Two", func() int {
		result := LookAndSay(input, 50)
		return len(result)
	})
}
