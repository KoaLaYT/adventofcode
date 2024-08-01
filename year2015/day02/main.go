package main

import (
	"io"
	"koalayt/adventofcode/year2015/internal"
	"log"
)

func main() {
	f := internal.OpenInputFile()
	defer f.Close()

	internal.Solve("Part One", func() int {
		return CalculateWrappingPaper(f)
	})

	if _, err := f.Seek(0, io.SeekStart); err != nil {
		log.Fatal(err)
	}

	internal.Solve("Part Two", func() int {
		return CalculateRibbonFeet(f)
	})
}
