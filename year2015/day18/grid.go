package main

import (
	"bufio"
	"io"
	"strings"
)

type Grid struct {
	lights [2][][]bool
	front  int // 0 or 1
	size   int
}

func NewGrid(r io.Reader) *Grid {
	lights1 := make([][]bool, 0)
	lights2 := make([][]bool, 0)

	scanner := bufio.NewScanner(r)
	for scanner.Scan() {
		txt := scanner.Bytes()
		if len(txt) <= 0 {
			continue
		}

		currRow := make([]bool, len(txt))
		nextRow := make([]bool, len(txt))
		for i, b := range txt {
			if b == '#' {
				currRow[i] = true
			}
		}
		lights1 = append(lights1, currRow)
		lights2 = append(lights2, nextRow)
	}

	return &Grid{
		lights: [2][][]bool{lights1, lights2},
		front:  0,
		size:   len(lights1),
	}
}

func (g *Grid) FixOnCorner() {
	src := g.lights[g.front]
	src[0][0] = true
	src[0][g.size-1] = true
	src[g.size-1][0] = true
	src[g.size-1][g.size-1] = true
}

func (g *Grid) OnLights() int {
	ons := 0
	src := g.lights[g.front]
	for i := 0; i < g.size; i++ {
		for j := 0; j < g.size; j++ {
			if src[i][j] {
				ons += 1
			}
		}
	}
	return ons
}

func (g *Grid) Update(round int) {
	for i := 0; i < round; i++ {
		g.UpdateOne()
	}
}

func (g *Grid) UpdateV2(round int) {
	g.FixOnCorner()
	for i := 0; i < round; i++ {
		g.UpdateOne()
		g.FixOnCorner()
	}
}

func (g *Grid) UpdateOne() {
	currFront := g.front
	nextFront := (g.front + 1) % 2
	src := g.lights[currFront]
	dst := g.lights[nextFront]
	g.front = nextFront

	for i := 0; i < g.size; i++ {
		for j := 0; j < g.size; j++ {
			if src[i][j] {
				dst[i][j] = g.ruleOn(src, i, j)
			} else {
				dst[i][j] = g.ruleOff(src, i, j)
			}
		}
	}
}

func (g *Grid) Print() string {
	var sb strings.Builder
	sb.WriteByte('\n')

	src := g.lights[g.front]

	for i := 0; i < g.size; i++ {
		for j := 0; j < g.size; j++ {
			if src[i][j] {
				sb.WriteByte('#')
			} else {
				sb.WriteByte('.')
			}
		}
		sb.WriteByte('\n')
	}

	return sb.String()
}

func (g *Grid) isOn(src [][]bool, i, j int) bool {
	if i < 0 || i >= g.size || j < 0 || j >= g.size {
		return false
	}

	return src[i][j]
}

func (g *Grid) countOns(src [][]bool, i, j int) int {
	on := 0

	if g.isOn(src, i-1, j-1) {
		on += 1
	}
	if g.isOn(src, i-1, j) {
		on += 1
	}
	if g.isOn(src, i-1, j+1) {
		on += 1
	}
	if g.isOn(src, i, j-1) {
		on += 1
	}
	if g.isOn(src, i, j+1) {
		on += 1
	}
	if g.isOn(src, i+1, j-1) {
		on += 1
	}
	if g.isOn(src, i+1, j) {
		on += 1
	}
	if g.isOn(src, i+1, j+1) {
		on += 1
	}

	return on
}

func (g *Grid) ruleOff(src [][]bool, i, j int) bool {
	return g.countOns(src, i, j) == 3
}

func (g *Grid) ruleOn(src [][]bool, i, j int) bool {
	ons := g.countOns(src, i, j)
	return ons == 2 || ons == 3
}
