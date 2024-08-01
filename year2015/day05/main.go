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
		return CountNiceString(f)
	})

	_, err := f.Seek(0, io.SeekStart)
	if err != nil {
		log.Fatal(err)
	}

	internal.Solve("Part Two", func() int {
		return CountNiceStringV2(f)
	})
}
