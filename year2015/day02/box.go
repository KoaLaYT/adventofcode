package main

import (
	"bufio"
	"io"
)

type Box struct {
	l, w, h int
}

func NewBox(l, w, h int) *Box {
	return &Box{l, w, h}
}

func (b *Box) surface() int {
	return 2*b.w*b.l + 2*b.w*b.h + 2*b.h*b.l
}

func (b *Box) smallestSide() int {
	x := b.w * b.l
	y := b.w * b.h
	z := b.h * b.l

	min := x
	if y < min {
		min = y
	}
	if z < min {
		min = z
	}
	return min
}

func (b *Box) WrappingPaper() int {
	return b.surface() + b.smallestSide()
}

func (b *Box) RibbonFeet() int {
	x := b.w + b.l
	y := b.w + b.h
	z := b.h + b.l

	min := x
	if y < min {
		min = y
	}
	if z < min {
		min = z
	}

	return 2*min + b.l*b.w*b.h
}

func CalculateRibbonFeet(r io.Reader) int {
	result := 0

	scanner := bufio.NewScanner(r)
	for scanner.Scan() {
		txt := scanner.Text()
		if len(txt) == 0 {
			continue
		}

		l, w, h := Parse(txt)
		b := NewBox(l, w, h)
		result += b.RibbonFeet()
	}

	return result
}

func CalculateWrappingPaper(r io.Reader) int {
	result := 0

	scanner := bufio.NewScanner(r)
	for scanner.Scan() {
		txt := scanner.Text()
		if len(txt) == 0 {
			continue
		}

		l, w, h := Parse(txt)
		b := NewBox(l, w, h)
		result += b.WrappingPaper()
	}

	return result
}
