package main

import (
	"koalayt/adventofcode/year2015/internal"
	"log"
)

func main() {
	f := internal.OpenInputFile()
	defer f.Close()

	c := ParseCookie(f)

	internal.Solve("Part One", func() int64 {
		formula, score := c.FindHighestScore()
		log.Println("Formula:", formula)
		return score
	})

	internal.Solve("Part Two", func() int64 {
		formula, score := c.FindHighestScoreWithCalories(500)
		log.Println("Formula:", formula)
		return score
	})
}
