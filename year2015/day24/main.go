package main

import (
	"koalayt/adventofcode/year2015/internal"
	"log"
)

func main() {
	p := &Packages{
		packs: []int{1, 2, 3, 7, 11, 13, 17, 19, 23,
			31, 37, 41, 43, 47, 53, 59, 61, 67, 71,
			73, 79, 83, 89, 97, 101, 103, 107, 109, 113,
		},
	}

	internal.Solve("Part One", func() int {
		qe, groups := p.FindBestBalance(3)
		log.Println("Groups:", groups)
		return qe
	})

	internal.Solve("Part Two", func() int {
		qe, groups := p.FindBestBalance(4)
		log.Println("Groups:", groups)
		return qe
	})
}
