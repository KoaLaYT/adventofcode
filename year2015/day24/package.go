package main

import (
	"math"
	"slices"
)

type Packages struct {
	packs []int
}

func (p *Packages) FindBestBalance(group int) (int, [][]int) {
	minQE := math.MaxInt
	var result [][]int

	for size := 1; size < len(p.packs)-1; size++ {
		stop := false
		groups := make([][]int, group)
		for i := 0; i < size; i++ {
			groups[0] = append(groups[0], i)
		}

		for {
			target := p.weight(groups[0])
			qe := p.qe(groups[0])
			canBalance := p.arrange(groups, 1, 0, target, 0)
			if canBalance && qe < minQE {
				result = p.copyResult(groups)
				minQE = qe
			}

			stop = p.next(groups[0], size-1)
			if stop {
				break
			}
		}

		if minQE < math.MaxInt {
			break
		}
	}

	return minQE, result
}

func (p *Packages) isPossible(usedIndexes [][]int, divided, target int) bool {
	if divided <= 1 {
		return true
	}

	totalSum := 0
	usedSum := 0
	for i, v := range p.packs {
		for _, used := range usedIndexes {
			if slices.Contains(used, i) {
				usedSum += v
			}
		}
		totalSum += v
	}
	leftSum := totalSum - usedSum

	if leftSum%divided != 0 {
		return false
	}

	return leftSum/divided == target
}

func (p *Packages) arrange(
	groups [][]int,
	gIdx, pIdx int,
	target, current int,
) bool {
	if gIdx >= len(groups) {
		return true
	}

	if current > target {
		return false
	}

	if current == target {
		return p.arrange(groups, gIdx+1, 0, target, 0)
	}

	if len(groups[gIdx]) == 0 && !p.isPossible(groups[:gIdx], len(groups)-gIdx, target) {
		return false
	}

	for i := pIdx; i < len(p.packs); i++ {
		if p.hasGrouped(groups, i) {
			continue
		}

		groups[gIdx] = append(groups[gIdx], i)
		meet := p.arrange(groups, gIdx, i+1, target, current+p.packs[i])
		if meet {
			return true
		}
		groups[gIdx] = groups[gIdx][:len(groups[gIdx])-1]
	}

	return false
}

func (p *Packages) copyResult(groups [][]int) [][]int {
	dst := make([][]int, len(groups))
	for i := range len(groups) {
		dst[i] = make([]int, len(groups[i]))
		copy(dst[i], groups[i])
	}
	return dst
}

func (p *Packages) hasGrouped(groups [][]int, i int) bool {
	for _, g := range groups {
		if slices.Contains(g, i) {
			return true
		}
	}
	return false
}

func (p *Packages) weight(group1Indexes []int) int {
	result := 0
	for _, i := range group1Indexes {
		result += p.packs[i]
	}
	return result
}

func (p *Packages) qe(group1Indexes []int) int {
	result := 1
	for _, i := range group1Indexes {
		result *= p.packs[i]
	}
	return result
}

func (p *Packages) next(s []int, i int) (stop bool) {
	if i < 0 {
		stop = true
		return
	}

	s[i] += 1
	if s[i] >= len(p.packs) {
		s[i] = 0
		stop = p.next(s, i-1)
	} else {
		overflow := false
		for j := i + 1; j < len(s); j++ {
			if s[j] == 0 {
				s[j] = s[j-1] + 1
			}
			if s[j] >= len(p.packs) {
				overflow = true
				break
			}
		}
		if overflow {
			for j := i + 1; j < len(s); j++ {
				s[j] = 0
			}
			s[i] = 0
			stop = p.next(s, i-1)
		}
	}
	return
}
