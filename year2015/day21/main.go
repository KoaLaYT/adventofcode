package main

import (
	"koalayt/adventofcode/year2015/internal"
	"log"
)

func main() {
	boss := NewCharacter(100, 8, 2)

	internal.Solve("Part One", func() int {
		c := LeastGoldToWin(boss)
		log.Println("Items:", c.items)
		return c.usedGold
	})

	internal.Solve("Part Two", func() int {
		c := MaxGoldToLose(boss)
		log.Println("Items:", c.items)
		return c.usedGold
	})
}
