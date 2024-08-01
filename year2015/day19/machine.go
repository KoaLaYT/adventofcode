package main

import (
	"bufio"
	"io"
	"math"
	"math/rand"
	"strings"
)

type Machine struct {
	replacements [][2]string
}

func NewMachine(r io.Reader) *Machine {
	var replacements [][2]string

	scanner := bufio.NewScanner(r)
	for scanner.Scan() {
		txt := scanner.Text()
		parts := strings.Split(txt, " => ")
		replacements = append(replacements, [2]string{parts[0], parts[1]})
	}

	return &Machine{replacements}
}

func (m *Machine) shuffle() {
	dst := make([][2]string, len(m.replacements))
	perm := rand.Perm(len(m.replacements))
	for i, v := range perm {
		dst[i] = m.replacements[v]
	}
	m.replacements = dst
}

func (m *Machine) Fabrication(input string) (round int, candidates map[int]int, result int) {
	candidates = make(map[int]int)

	valid := 0
	for valid < 100 {
		steps := m.fabricationGreedy(input)
		if steps < math.MaxInt {
			candidates[steps] += 1
			valid += 1
		}
		round += 1
	}

	result = math.MaxInt
	for k := range candidates {
		result = min(result, k)
	}
	return
}

func (m *Machine) fabricationGreedy(input string) int {
	m.shuffle()

	steps := 0
	for {
		if input == "e" {
			return steps
		}

		hasReplaced := false
		for _, replacement := range m.replacements {
			oldStr := replacement[1]
			newStr := replacement[0]

			if !strings.Contains(input, oldStr) {
				continue
			}

			input = strings.Replace(input, oldStr, newStr, 1)
			hasReplaced = true
			break
		}

		if !hasReplaced {
			return math.MaxInt
		}

		steps += 1
	}
}

func (m *Machine) Calibration(input string) int {
	molecules := make(map[string]bool)
	for _, replacement := range m.replacements {
		src := replacement[0]
		dst := replacement[1]
		doReplacement(input, src, dst, molecules)
	}
	return len(molecules)
}

func doReplacement(input, src, dst string, molecules map[string]bool) {
	i := 0

	for i < len(input) {
		idx := strings.Index(input[i:], src)
		if idx == -1 {
			break
		}

		var replaced strings.Builder
		replaced.WriteString(input[:i+idx])
		replaced.WriteString(dst)
		i += idx + len(src)
		replaced.WriteString(input[i:])
		molecules[replaced.String()] = true
	}
}
