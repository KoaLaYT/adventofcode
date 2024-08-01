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
		grid := NewGrid(1000, 1000)
		grid.ExecAll(f)
		return grid.Litted()
	})

	_, err := f.Seek(0, io.SeekStart)
	if err != nil {
		log.Fatal(err)
	}

	internal.Solve("Part Two", func() int {
		grid := NewGridV2(1000, 1000)
		grid.ExecAll(f)
		return grid.Brightness()
	})
}
