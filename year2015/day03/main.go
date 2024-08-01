package main

import (
	"io"
	"koalayt/adventofcode/year2015/internal"
	"log"
)

func main() {
	f := internal.OpenInputFile()
	defer f.Close()

	input, err := io.ReadAll(f)
	if err != nil {
		log.Fatal(err)
	}

	internal.Solve("Part One", func() int {
		s := NewSanta()
		s.Deliver(input)
		return s.Visited()
	})

	internal.Solve("Part Two", func() int {
		s := NewSantaWithRobo()
		s.Deliver(input)
		return s.Visited()
	})
}
