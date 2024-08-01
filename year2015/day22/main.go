package main

import (
	"koalayt/adventofcode/year2015/internal"
	"log"
	"strings"
)

func main() {
	wizzard := NewWizzard(50, 500)
	boss := NewBoss(51, 9)

	s := NewSimulator(wizzard, boss)

	internal.Solve("Part One", func() int {
		spells, result := s.LeastManaToWin(false)
		log.Println("Spells:", logSpells(spells))
		return result
	})

	internal.Solve("Part Two", func() int {
		spells, result := s.LeastManaToWin(true)
		log.Println("Spells:", logSpells(spells))
		return result
	})
}

func logSpells(spells []string) string {
	var sb strings.Builder

	sb.WriteByte('[')
	for i, spell := range spells {
		if i > 0 {
			sb.WriteString(", ")
		}
		sb.WriteString(spell)
	}
	sb.WriteByte(']')

	return sb.String()
}
