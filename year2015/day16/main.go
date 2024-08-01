package main

import (
	"io"
	"koalayt/adventofcode/year2015/internal"
	"log"
)

func main() {
	f := internal.OpenInputFile()
	defer f.Close()

	compounds := map[string]int{
		"children":    3,
		"cats":        7,
		"samoyeds":    2,
		"pomeranians": 3,
		"akitas":      0,
		"vizslas":     0,
		"goldfish":    5,
		"trees":       3,
		"cars":        2,
		"perfumes":    1,
	}

	internal.Solve("Part One", func() int {
		a := FindAunt(f, compounds)
		log.Println(a)
		return a.id
	})

	if _, err := f.Seek(0, io.SeekStart); err != nil {
		log.Fatal(err)
	}

	internal.Solve("Part Two", func() int {
		a := FindAuntV2(f, compounds)
		log.Println(a)
		return a.id
	})
}
