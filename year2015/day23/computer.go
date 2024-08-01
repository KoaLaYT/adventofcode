package main

import (
	"bufio"
	"fmt"
	"io"
	"koalayt/adventofcode/year2015/internal"
	"log"
)

type Computer struct {
	registers    map[byte]int
	pc           int
	instructions []Instruction
}

func NewComputer(r io.Reader) *Computer {
	var instructions []Instruction

	scanner := bufio.NewScanner(r)
	for scanner.Scan() {
		txt := scanner.Text()
		if len(txt) <= 0 {
			continue
		}
		instructions = append(instructions, ParseInstruction(txt))
	}

	return &Computer{
		registers:    make(map[byte]int),
		pc:           0,
		instructions: instructions,
	}
}

func (c *Computer) Run() {
	for c.pc < len(c.instructions) {
		inst := c.instructions[c.pc]
		oldPC := c.pc
		inst.Exec(c)
		log.Printf("Exec [%v], pc %d -> %d, register %v",
			inst, oldPC, c.pc, c.registers)
	}
}

func (c *Computer) Restart() {
	c.registers = make(map[byte]int)
	c.pc = 0
}

func (c *Computer) SetRegister(r byte, v int) {
	c.registers[r] = v
}

func (c *Computer) Register(r byte) int {
	return c.registers[r]
}

type Instruction interface {
	Exec(c *Computer)
	String() string
	Equal(o Instruction) bool
	Debug() string
}

func ParseInstruction(s string) Instruction {
	switch s[:3] {
	case "hlf":
		return InstHLF{raw: s, register: s[4]}
	case "tpl":
		return InstTPL{raw: s, register: s[4]}
	case "inc":
		return InstINC{raw: s, register: s[4]}
	case "jmp":
		return InstJMP{raw: s, offset: internal.MustAtoi[int](s[4:])}
	case "jie":
		return InstJIE{raw: s, register: s[4], offset: internal.MustAtoi[int](s[7:])}
	case "jio":
		return InstJIO{raw: s, register: s[4], offset: internal.MustAtoi[int](s[7:])}
	default:
		panic(fmt.Errorf("Unknown instruction: %s", s[:3]))
	}
}

type InstHLF struct {
	raw      string
	register byte
}

func (i InstHLF) Exec(c *Computer) {
	c.registers[i.register] /= 2
	c.pc += 1
}
func (i InstHLF) String() string { return i.raw }
func (i InstHLF) Equal(o Instruction) bool {
	switch tt := o.(type) {
	case InstHLF:
		return tt.raw == i.raw && tt.register == i.register
	default:
		return false
	}
}
func (i InstHLF) Debug() string {
	return fmt.Sprintf("hlf (%c)", i.register)
}

type InstTPL struct {
	raw      string
	register byte
}

func (i InstTPL) Exec(c *Computer) {
	c.registers[i.register] *= 3
	c.pc += 1
}
func (i InstTPL) String() string { return i.raw }
func (i InstTPL) Equal(o Instruction) bool {
	switch tt := o.(type) {
	case InstTPL:
		return tt.raw == i.raw && tt.register == i.register
	default:
		return false
	}
}
func (i InstTPL) Debug() string {
	return fmt.Sprintf("tpl (%c)", i.register)
}

type InstINC struct {
	raw      string
	register byte
}

func (i InstINC) Exec(c *Computer) {
	c.registers[i.register] += 1
	c.pc += 1
}
func (i InstINC) String() string { return i.raw }
func (i InstINC) Equal(o Instruction) bool {
	switch tt := o.(type) {
	case InstINC:
		return tt.raw == i.raw && tt.register == i.register
	default:
		return false
	}
}
func (i InstINC) Debug() string {
	return fmt.Sprintf("inc (%c)", i.register)
}

type InstJMP struct {
	raw    string
	offset int
}

func (i InstJMP) Exec(c *Computer) {
	c.pc += i.offset
}
func (i InstJMP) String() string { return i.raw }
func (i InstJMP) Equal(o Instruction) bool {
	switch tt := o.(type) {
	case InstJMP:
		return tt.raw == i.raw && tt.offset == i.offset
	default:
		return false
	}
}
func (i InstJMP) Debug() string {
	return fmt.Sprintf("jmp (%d)", i.offset)
}

type InstJIE struct {
	raw      string
	register byte
	offset   int
}

func (i InstJIE) Exec(c *Computer) {
	if c.registers[i.register]%2 == 0 {
		c.pc += i.offset
	} else {
		c.pc += 1
	}
}
func (i InstJIE) String() string { return i.raw }
func (i InstJIE) Equal(o Instruction) bool {
	switch tt := o.(type) {
	case InstJIE:
		return tt.raw == i.raw &&
			tt.register == i.register &&
			tt.offset == i.offset
	default:
		return false
	}
}
func (i InstJIE) Debug() string {
	return fmt.Sprintf("jie %c, %d", i.register, i.offset)
}

type InstJIO struct {
	raw      string
	register byte
	offset   int
}

func (i InstJIO) Exec(c *Computer) {
	if c.registers[i.register] == 1 {
		c.pc += i.offset
	} else {
		c.pc += 1
	}
}
func (i InstJIO) String() string { return i.raw }
func (i InstJIO) Equal(o Instruction) bool {
	switch tt := o.(type) {
	case InstJIO:
		return tt.raw == i.raw &&
			tt.register == i.register &&
			tt.offset == i.offset
	default:
		return false
	}
}
func (i InstJIO) Debug() string {
	return fmt.Sprintf("jio %c, %d", i.register, i.offset)
}
