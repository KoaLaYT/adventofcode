package main

import (
	"koalayt/adventofcode/year2015/internal"
	"log"
)

func main() {
	secret := "iwrupvqb"

	internal.Solve("Part One", func() int {
		m := NewMiner(secret, 5)
		hash, result := m.Mine()
		log.Println("Hash:", hash)
		return result
	})

	internal.Solve("Part Two", func() int {
		m := NewMiner(secret, 6)
		hash, result := m.Mine()
		log.Println("Hash:", hash)
		return result
	})

	internal.Solve("Part Two (concurrent)", func() int {
		m := NewConcurrentMiner(secret, 6)
		hash, result := m.Mine()
		log.Println("Hash:", hash)
		return result
	})

	internal.Solve("Difficult 7", func() int {
		m := NewMiner(secret, 7)
		hash, result := m.Mine()
		log.Println("Hash:", hash)
		return result
	})

	internal.Solve("Difficult 7 (concurrent)", func() int {
		m := NewConcurrentMiner(secret, 7)
		hash, result := m.Mine()
		log.Println("Hash:", hash)
		return result
	})

	internal.Solve("Difficult 8 (concurrent)", func() int {
		m := NewConcurrentMiner(secret, 8)
		hash, result := m.Mine()
		log.Println("Hash:", hash)
		return result
	})
}
