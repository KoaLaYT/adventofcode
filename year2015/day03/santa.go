package main

import "fmt"

type Direction int

const (
	Unknown Direction = iota
	Up
	Right
	Down
	Left
)

func ParseDirection(b byte) Direction {
	switch b {
	case '^':
		return Up
	case '>':
		return Right
	case 'v':
		return Down
	case '<':
		return Left
	default:
		return Unknown
	}
}

type Position struct {
	x, y int
}

func (p Position) String() string {
	return fmt.Sprintf("%d,%d", p.x, p.y)
}

type Santa struct {
	visited  map[string]bool
	withRobo bool
	poss     []Position
	turn     int
}

func newSanta(withRobo bool) *Santa {
	visited := make(map[string]bool)
	startPos := Position{0, 0}

	visited[startPos.String()] = true

	return &Santa{
		visited:  visited,
		withRobo: withRobo,
		poss:     []Position{startPos, startPos},
		turn:     0,
	}
}

func NewSanta() *Santa {
	return newSanta(false)
}

func NewSantaWithRobo() *Santa {
	return newSanta(true)
}

func (s *Santa) Move(d Direction) {
	switch d {
	case Up:
		s.poss[s.turn].y += 1
	case Right:
		s.poss[s.turn].x += 1
	case Down:
		s.poss[s.turn].y -= 1
	case Left:
		s.poss[s.turn].x -= 1
	default:
		return
	}

	s.visited[s.poss[s.turn].String()] = true

	if s.withRobo {
		s.turn = (s.turn + 1) % 2
	}
}

func (s *Santa) Visited() int {
	return len(s.visited)
}

func (s *Santa) Deliver(dirs []byte) {
	for _, d := range dirs {
		s.Move(ParseDirection(d))
	}
}
