package main

import (
	"bufio"
	"io"
	"koalayt/adventofcode/year2015/internal"
	"regexp"
	"strings"
)

type Aunt struct {
	id        int
	compounds map[string]int
}

func ParseAunt(s string) *Aunt {
	r := regexp.MustCompile(`^Sue (\d+): (.+)$`)
	m := r.FindAllStringSubmatch(s, -1)

	mm := m[0]
	id := internal.MustAtoi[int](mm[1])

	compounds := make(map[string]int)
	p := strings.Split(mm[2], ", ")
	rr := regexp.MustCompile(`^(\w+): (\d+)$`)
	for _, pp := range p {
		c := rr.FindAllStringSubmatch(pp, -1)
		compounds[c[0][1]] = internal.MustAtoi[int](c[0][2])
	}

	return &Aunt{id, compounds}
}

func (a *Aunt) Match(compounds map[string]int) bool {
	for k, v := range compounds {
		vv, exists := a.compounds[k]
		if !exists {
			continue
		}
		if v != vv {
			return false
		}
	}

	return true
}

func (a *Aunt) MatchV2(compounds map[string]int) bool {
	for k, v := range compounds {
		vv, exists := a.compounds[k]
		if !exists {
			continue
		}

		if k == "cats" || k == "trees" {
			if vv <= v {
				return false
			}
		} else if k == "pomeranians" || k == "goldfish" {
			if vv >= v {
				return false
			}
		} else if v != vv {
			return false
		}
	}

	return true
}

func FindAunt(r io.Reader, compounds map[string]int) *Aunt {
	scanner := bufio.NewScanner(r)
	for scanner.Scan() {
		txt := scanner.Text()
		if len(txt) <= 0 {
			continue
		}

		aunt := ParseAunt(txt)
		if aunt.Match(compounds) {
			return aunt
		}
	}

	panic("No aunt matched")
}

func FindAuntV2(r io.Reader, compounds map[string]int) *Aunt {
	scanner := bufio.NewScanner(r)
	for scanner.Scan() {
		txt := scanner.Text()
		if len(txt) <= 0 {
			continue
		}

		aunt := ParseAunt(txt)
		if aunt.MatchV2(compounds) {
			return aunt
		}
	}

	panic("No aunt matched")
}
