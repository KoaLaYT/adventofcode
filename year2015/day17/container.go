package main

import (
	"bufio"
	"io"
	"koalayt/adventofcode/year2015/internal"
	"math"
)

type Containers struct {
	liters []int
}

func ParseContainers(r io.Reader) *Containers {
	var liters []int

	scanner := bufio.NewScanner(r)
	for scanner.Scan() {
		txt := scanner.Text()
		v := internal.MustAtoi[int](txt)
		liters = append(liters, v)
	}

	return &Containers{liters}
}

func (c *Containers) Fill(liter int) int {
	combsMap := make(map[int]int)
	return c.fill(liter, 0, 0, 0, combsMap)
}

func (c *Containers) FillMinWays(liter int) int {
	combsMap := make(map[int]int)
	c.fill(liter, 0, 0, 0, combsMap)

	mk := math.MaxInt
	mv := 0
	for k, v := range combsMap {
		if k < mk {
			mk = k
			mv = v
		}
	}

	return mv
}

func (c *Containers) fill(left int, idx int, combs int, combsLen int, combsMap map[int]int) int {
	if left < 0 {
		return combs
	}
	if left == 0 {
		combsMap[combsLen] += 1
		return combs + 1
	}
	if idx >= len(c.liters) {
		return combs
	}

	for i := idx; i < len(c.liters); i++ {
		liter := c.liters[i]
		combs = c.fill(left-liter, i+1, combs, combsLen+1, combsMap)
	}

	return combs
}
