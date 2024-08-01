package main

import (
	"bufio"
	"fmt"
	"io"
	"koalayt/adventofcode/year2015/internal"
	"slices"
	"strings"
)

type Arrangement struct {
	person    string
	neighbor  string
	happiness int
}

func (a Arrangement) IsEqual(o Arrangement) bool {
	return a.person == o.person &&
		a.neighbor == o.neighbor &&
		a.happiness == o.happiness
}

func ParseArrangement(s string) Arrangement {
	parts := strings.Split(s[:len(s)-1], " ")
	person := parts[0]
	neighor := parts[10]
	happiness := internal.MustAtoi[int](parts[3])

	switch parts[2] {
	case "lose":
		happiness = -happiness
	case "gain":
		break
	default:
		panic(fmt.Errorf("Bad arrangement %s, expect `gain` or `lose`, got: %s", s, parts[2]))
	}

	return Arrangement{person, neighor, happiness}
}

type Feast struct {
	people       []string
	arrangements []Arrangement
}

func (f *Feast) AddMyself(name string) {
	for _, person := range f.people {
		f.arrangements = append(f.arrangements,
			Arrangement{
				person,
				name,
				0,
			})
		f.arrangements = append(f.arrangements,
			Arrangement{
				name,
				person,
				0,
			})
	}
	f.people = append(f.people, name)
}

func ParseFeast(r io.Reader) *Feast {
	var people []string
	var arrangements []Arrangement

	scanner := bufio.NewScanner(r)
	for scanner.Scan() {
		txt := scanner.Text()
		if len(txt) <= 0 {
			continue
		}

		a := ParseArrangement(txt)
		arrangements = append(arrangements, a)

		if !slices.Contains(people, a.person) {
			people = append(people, a.person)
		}
	}

	return &Feast{people, arrangements}
}

func (f *Feast) Optimal() int {
	seated := make(map[string]bool)
	return f.optimal(seated, nil, 0)
}

func (f *Feast) happiness(order []string) int {
	result := 0

	for i := 0; i < len(order); i++ {
		left := i - 1
		if left < 0 {
			left = len(order) - 1
		}
		right := i + 1
		if right >= len(order) {
			right = 0
		}

		result += f.found(order[i], order[left]).happiness
		result += f.found(order[i], order[right]).happiness
	}

	return result
}

func (f *Feast) found(person, neighbor string) Arrangement {
	for _, a := range f.arrangements {
		if a.person == person && a.neighbor == neighbor {
			return a
		}
	}
	panic(fmt.Errorf("No arrangement found for `%s` and `%s`", person, neighbor))
}

func (f *Feast) optimal(seated map[string]bool, order []string, maxHappiness int) int {
	if len(order) == len(f.people) {
		return max(f.happiness(order), maxHappiness)
	}

	for _, p := range f.people {
		if seated[p] {
			continue
		}

		seated[p] = true
		result := f.optimal(seated, append(order, p), maxHappiness)
		seated[p] = false

		maxHappiness = max(maxHappiness, result)
	}

	return maxHappiness
}
