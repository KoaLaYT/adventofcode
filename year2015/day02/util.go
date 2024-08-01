package main

import (
	"fmt"
	"koalayt/adventofcode/year2015/internal"
	"strings"
)

func Parse(s string) (l, w, h int) {
	parts := strings.Split(s, "x")

	if len(parts) != 3 {
		panic(fmt.Sprintf("Bad string: %s", s))
	}

	l = internal.MustAtoi[int](parts[0])
	w = internal.MustAtoi[int](parts[1])
	h = internal.MustAtoi[int](parts[2])

	return
}
