package main

import (
	"io"
	"koalayt/adventofcode/year2015/internal"
	"log"
)

func main() {
	log.SetOutput(io.Discard)

	f := internal.OpenInputFile()
	defer f.Close()

	c := NewComputer(f)

	internal.Solve("Part One", func() int {
		c.Restart()
		c.Run()
		return c.Register('b')
	})

	internal.Solve("Part Two", func() int {
		c.Restart()
		c.SetRegister('a', 1)
		c.Run()
		return c.Register('b')
	})
}
