package main

import (
	"io"
	"koalayt/adventofcode/year2015/internal"
	"log"
)

func main() {
	f := internal.OpenInputFile()
	defer f.Close()

	{
		c := ParseCircuit(f)

		internal.Solve("Part One (Recursive)", func() uint16 {
			return c.ResolveV1("a")
		})

		internal.Solve("Part Two (Recursive)", func() uint16 {
			v := c.ResolveV1("a")
			c.Set("b", v)
			c.Reset()
			return c.ResolveV1("a")
		})
	}

	_, err := f.Seek(0, io.SeekStart)
	if err != nil {
		log.Fatal(err)
	}

	{
		c := ParseCircuit(f)

		internal.Solve("Part One (Iterative)", func() uint16 {
			return c.ResolveV2("a")
		})

		internal.Solve("Part Two (Iterative)", func() uint16 {
			v := c.ResolveV2("a")
			c.Set("b", v)
			c.Reset()
			return c.ResolveV2("a")
		})
	}
}
