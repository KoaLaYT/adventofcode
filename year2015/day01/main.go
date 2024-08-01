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
		log.Fatal("Read: ", err)
	}

	internal.Solve("Part One", func() int {
		return FloorFinder(string(input))
	})

	internal.Solve("Part Two", func() int {
		return FloorFinderV2(string(input))
	})
}
