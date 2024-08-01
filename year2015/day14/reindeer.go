package main

import (
	"bufio"
	"io"
	"koalayt/adventofcode/year2015/internal"
	"strings"
)

type Reindeer struct {
	name       string
	flySpeed   int
	flySecond  int
	restSecond int

	points   int
	distance int
	fly      int
	rest     int
}

func (r *Reindeer) IsEqual(o *Reindeer) bool {
	return r.name == o.name &&
		r.flySpeed == o.flySpeed &&
		r.flySecond == o.flySecond &&
		r.restSecond == o.restSecond
}

func ParseReindeer(s string) *Reindeer {
	parts := strings.Split(s, " ")
	name := parts[0]
	flySpeed := internal.MustAtoi[int](parts[3])
	flySecond := internal.MustAtoi[int](parts[6])
	restSecond := internal.MustAtoi[int](parts[13])

	return &Reindeer{
		name:       name,
		flySpeed:   flySpeed,
		flySecond:  flySecond,
		restSecond: restSecond,
		points:     0,
		distance:   0,
		fly:        flySecond,
		rest:       restSecond,
	}
}

func (r *Reindeer) RunV2() int {
	if r.fly > 0 {
		r.fly -= 1
		r.distance += r.flySpeed
	} else if r.rest > 0 {
		r.rest -= 1
		if r.rest == 0 {
			r.fly = r.flySecond
			r.rest = r.restSecond
		}
	}
	return r.distance
}

func (r *Reindeer) Run(sec int) int {
	flySecond := r.flySecond
	restSecond := r.restSecond
	distance := 0

	for i := 0; i < sec; i++ {
		if flySecond > 0 {
			flySecond -= 1
			distance += r.flySpeed
			continue
		}

		if restSecond > 0 {
			restSecond -= 1
			if restSecond == 0 {
				flySecond = r.flySecond
				restSecond = r.restSecond
			}
			continue
		}

	}

	return distance
}

func Olympics(r io.Reader, sec int) int {
	longest := 0

	scanner := bufio.NewScanner(r)
	for scanner.Scan() {
		txt := scanner.Text()
		reindeer := ParseReindeer(txt)

		distance := reindeer.Run(sec)
		longest = max(longest, distance)
	}

	return longest
}

func OlympicsV2(r io.Reader, sec int) int {
	var reindeers []*Reindeer
	scanner := bufio.NewScanner(r)
	for scanner.Scan() {
		txt := scanner.Text()
		reindeers = append(reindeers, ParseReindeer(txt))
	}

	for i := 0; i < sec; i++ {
		longest := 0
		for _, reindeer := range reindeers {
			longest = max(longest, reindeer.RunV2())
		}
		for _, reindeer := range reindeers {
			if reindeer.distance == longest {
				reindeer.points += 1
			}
		}
	}

	maxPoints := 0
	for _, reindeer := range reindeers {
		maxPoints = max(maxPoints, reindeer.points)
	}
	return maxPoints
}
