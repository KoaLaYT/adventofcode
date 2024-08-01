package main

import (
	"bufio"
	"fmt"
	"io"
	"koalayt/adventofcode/year2015/internal"
	"strings"
)

type GridV2 struct {
	row, col int
	lights   [][]int
}

func NewGridV2(row, col int) *GridV2 {
	lights := make([][]int, row)
	for i := 0; i < row; i++ {
		lights[i] = make([]int, col)
	}

	return &GridV2{
		row:    row,
		col:    col,
		lights: lights,
	}
}

func (g *GridV2) Brightness() int {
	result := 0
	for i := 0; i < g.row; i++ {
		for j := 0; j < g.col; j++ {
			result += g.lights[i][j]
		}
	}
	return result
}

func (g *GridV2) ExecOne(ins Instruction) {
	for i := ins.rowStart; i <= ins.rowEnd; i++ {
		for j := ins.colStart; j <= ins.colEnd; j++ {
			switch ins.action {
			case TurnOn:
				g.lights[i][j] += 1
			case Toggle:
				g.lights[i][j] += 2
			case TurnOff:
				g.lights[i][j] -= 1
				if g.lights[i][j] < 0 {
					g.lights[i][j] = 0
				}
			}
		}
	}
}

func (g *GridV2) ExecAll(r io.Reader) {
	scanner := bufio.NewScanner(r)
	for scanner.Scan() {
		txt := scanner.Text()
		if len(txt) <= 0 {
			continue
		}
		inst := ParseInstruction(txt)
		g.ExecOne(inst)
	}
}

type Grid struct {
	row, col int
	lights   [][]bool
}

func NewGrid(row, col int) *Grid {
	lights := make([][]bool, row)
	for i := 0; i < row; i++ {
		lights[i] = make([]bool, col)
	}

	return &Grid{
		row:    row,
		col:    col,
		lights: lights,
	}
}

func (g *Grid) Litted() int {
	result := 0
	for i := 0; i < g.row; i++ {
		for j := 0; j < g.col; j++ {
			if g.lights[i][j] {
				result += 1
			}
		}
	}
	return result
}

func (g *Grid) ExecOne(ins Instruction) {
	for i := ins.rowStart; i <= ins.rowEnd; i++ {
		for j := ins.colStart; j <= ins.colEnd; j++ {
			switch ins.action {
			case TurnOn:
				g.lights[i][j] = true
			case Toggle:
				g.lights[i][j] = !g.lights[i][j]
			case TurnOff:
				g.lights[i][j] = false
			}
		}
	}
}

func (g *Grid) ExecAll(r io.Reader) {
	scanner := bufio.NewScanner(r)
	for scanner.Scan() {
		txt := scanner.Text()
		if len(txt) <= 0 {
			continue
		}
		inst := ParseInstruction(txt)
		g.ExecOne(inst)
	}
}

type Action int

const (
	Unknown Action = iota
	TurnOn
	Toggle
	TurnOff
)

type Instruction struct {
	action           Action
	rowStart, rowEnd int
	colStart, colEnd int
}

func (i Instruction) Equal(o Instruction) bool {
	return i.action == o.action &&
		i.rowStart == o.rowStart &&
		i.rowEnd == o.rowEnd &&
		i.colStart == o.colStart &&
		i.colEnd == o.colEnd
}

func ParseInstruction(s string) Instruction {
	action := Unknown
	ss := s[:]
	if strings.HasPrefix(s, "toggle ") {
		action = Toggle
		ss = s[7:]
	}
	if strings.HasPrefix(s, "turn off ") {
		action = TurnOff
		ss = s[9:]
	}
	if strings.HasPrefix(s, "turn on ") {
		action = TurnOn
		ss = s[8:]
	}

	parts := strings.Split(ss, " through ")
	if action == Unknown || len(parts) != 2 {
		panic(fmt.Sprintf("Bad instruction: %s", s))
	}

	colStart, rowStart := parseNum(parts[0])
	colEnd, rowEnd := parseNum(parts[1])

	return Instruction{
		action,
		rowStart, rowEnd,
		colStart, colEnd,
	}
}

func parseNum(s string) (int, int) {
	parts := strings.Split(s, ",")
	if len(parts) != 2 {
		panic(fmt.Sprintf("Can not parse num from %s", s))
	}

	a := internal.MustAtoi[int](parts[0])
	b := internal.MustAtoi[int](parts[1])

	return a, b
}
