package main

import (
	"bufio"
	"fmt"
	"io"
	"koalayt/adventofcode/year2015/internal"
	"strings"
)

type WireKind int

const (
	Unknown WireKind = iota
	Direct
	AndGate
	OrGate
	LeftShift
	RightShift
	Complement
)

type Wire struct {
	id   string
	kind WireKind
	deps []string
}

type Circuit struct {
	wires    map[string]Wire
	resolved map[string]uint16
}

func (c *Circuit) Set(name string, value uint16) {
	c.wires[name] = Wire{
		id:   name,
		kind: Direct,
		deps: []string{fmt.Sprintf("%d", value)},
	}
}

func (c *Circuit) Reset() {
	c.resolved = make(map[string]uint16)
}

// iterative
func (c *Circuit) ResolveV2(name string) uint16 {
	stack := []string{name}

	for len(stack) > 0 {
		topWire := c.wires[stack[len(stack)-1]]
		var depsValue []uint16
		for _, dep := range topWire.deps {
			v, ok := c.resolved[dep]
			if ok {
				depsValue = append(depsValue, v)
			} else if dep[0] >= '0' && dep[0] <= '9' {
				vv := internal.MustAtoi[int](dep)
				depsValue = append(depsValue, uint16(vv))
			} else {
				stack = append(stack, dep)
			}
		}
		if len(depsValue) == len(topWire.deps) {
			var value uint16
			switch topWire.kind {
			case Direct:
				value = depsValue[0]
			case AndGate:
				value = depsValue[0] & depsValue[1]
			case OrGate:
				value = depsValue[0] | depsValue[1]
			case LeftShift:
				value = depsValue[0] << depsValue[1]
			case RightShift:
				value = depsValue[0] >> depsValue[1]
			case Complement:
				value = ^depsValue[0]
			default:
				panic(fmt.Errorf("Unknown wire: %v", topWire))
			}
			c.resolved[topWire.id] = value
			stack = stack[:len(stack)-1]
		}
	}

	return c.resolved[name]
}

// recursive
func (c *Circuit) ResolveV1(name string) uint16 {
	v, ok := c.resolved[name]
	if ok {
		return v
	}

	if name[0] >= '0' && name[0] <= '9' {
		v := internal.MustAtoi[int](name)
		c.resolved[name] = uint16(v)
		return uint16(v)
	}

	wire := c.wires[name]
	depsValue := make([]uint16, len(wire.deps))
	for i, dep := range wire.deps {
		depsValue[i] = c.ResolveV1(dep)
	}

	var value uint16
	switch wire.kind {
	case Direct:
		value = depsValue[0]
	case AndGate:
		value = depsValue[0] & depsValue[1]
	case OrGate:
		value = depsValue[0] | depsValue[1]
	case LeftShift:
		value = depsValue[0] << depsValue[1]
	case RightShift:
		value = depsValue[0] >> depsValue[1]
	case Complement:
		value = ^depsValue[0]
	default:
		panic(fmt.Errorf("Unknown wire: %v", wire))
	}

	c.resolved[name] = value
	return value
}

func ParseWire(s string) Wire {
	badInputErr := fmt.Errorf("Bad input: %s", s)
	p := strings.Split(s, " -> ")
	if len(p) != 2 {
		panic(badInputErr)
	}

	pp := strings.Split(p[0], " ")

	if len(pp) == 1 {
		return Wire{id: p[1], kind: Direct, deps: []string{pp[0]}}
	}

	if len(pp) == 2 {
		if pp[0] != "NOT" {
			panic(badInputErr)
		}
		return Wire{id: p[1], kind: Complement, deps: []string{pp[1]}}
	}

	if len(pp) == 3 {
		kind := Unknown
		switch pp[1] {
		case "AND":
			kind = AndGate
		case "OR":
			kind = OrGate
		case "RSHIFT":
			kind = RightShift
		case "LSHIFT":
			kind = LeftShift
		}

		if kind == Unknown {
			panic(badInputErr)
		}

		return Wire{id: p[1], kind: kind, deps: []string{pp[0], pp[2]}}
	}

	panic(badInputErr)
}

func ParseCircuit(r io.Reader) *Circuit {
	c := &Circuit{
		wires:    make(map[string]Wire),
		resolved: make(map[string]uint16),
	}

	scanner := bufio.NewScanner(r)
	for scanner.Scan() {
		txt := scanner.Text()
		if len(txt) <= 0 {
			continue
		}

		wire := ParseWire(txt)
		c.wires[wire.id] = wire
	}

	return c
}
