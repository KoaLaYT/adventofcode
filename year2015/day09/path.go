package main

import (
	"bufio"
	"fmt"
	"io"
	"koalayt/adventofcode/year2015/internal"
	"math"
	"slices"
	"strings"
)

type Path struct {
	from, to string
	distance int
}

type Locations struct {
	cities []string
	pathes []Path
}

func ParseLocations(r io.Reader) *Locations {
	cities := make([]string, 0)
	pathes := make([]Path, 0)

	scanner := bufio.NewScanner(r)
	for scanner.Scan() {
		txt := scanner.Text()
		if len(txt) <= 0 {
			continue
		}

		path := ParsePath(txt)
		pathes = append(pathes, path)

		if !slices.Contains(cities, path.from) {
			cities = append(cities, path.from)
		}
		if !slices.Contains(cities, path.to) {
			cities = append(cities, path.to)
		}
	}

	return &Locations{cities, pathes}
}

func (l *Locations) Longest() int {
	visited := make(map[string]bool)
	longest := 0
	for _, city := range l.cities {
		visited[city] = true
		result := l.longest(visited, city, 0, 0)
		delete(visited, city)
		if result > longest {
			longest = result
		}
	}
	return longest
}

func (l *Locations) longest(visited map[string]bool, from string, curDist, maxDist int) int {
	if len(visited) == len(l.cities) {
		return curDist
	}

	for _, to := range l.cities {
		if visited[to] {
			continue
		}

		path := l.findPath(from, to)
		visited[to] = true
		result := l.longest(visited, to, curDist+path.distance, maxDist)
		delete(visited, to)
		if result > maxDist {
			maxDist = result
		}
	}

	return maxDist
}

func (l *Locations) Shortest() int {
	visited := make(map[string]bool)
	shortest := math.MaxInt
	for _, city := range l.cities {
		visited[city] = true
		result := l.shortest(visited, city, 0, math.MaxInt)
		delete(visited, city)
		if result < shortest {
			shortest = result
		}
	}
	return shortest
}

func (l *Locations) shortest(visited map[string]bool, from string, curDist, minDist int) int {
	if curDist >= minDist {
		return minDist
	}

	if len(visited) == len(l.cities) {
		return curDist
	}

	for _, to := range l.cities {
		if visited[to] {
			continue
		}

		path := l.findPath(from, to)
		visited[to] = true
		result := l.shortest(visited, to, curDist+path.distance, minDist)
		delete(visited, to)
		if result < minDist {
			minDist = result
		}
	}

	return minDist
}

func (l *Locations) findPath(from, to string) Path {
	for _, path := range l.pathes {
		if path.from == from && path.to == to {
			return path
		}
		if path.to == from && path.from == to {
			return path
		}
	}
	panic(fmt.Errorf("No path for %s to %s", from, to))
}

func ParsePath(s string) Path {
	p := strings.Split(s, " = ")

	distance := internal.MustAtoi[int](p[1])

	pp := strings.Split(p[0], " to ")

	return Path{pp[0], pp[1], distance}
}
