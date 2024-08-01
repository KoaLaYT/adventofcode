package main

import "testing"

func TestSimulator(t *testing.T) {
	{
		w := &Wizzard{
			hitpoints:    10,
			maxHitpoints: 10,
			mana:         250,
		}
		b := &Boss{
			hitpoints:    13,
			maxHitpoints: 13,
			damage:       8,
		}

		s := &Simulator{w: w, b: b}
		_, _ = s.run(NewPoison(), false)
		hasWon, _ := s.run(NewMagicMissle(), false)
		if !hasWon {
			t.Fatalf("expect won, %v", s)
		}
	}

	{
		w := &Wizzard{
			hitpoints:    10,
			maxHitpoints: 10,
			mana:         250,
		}
		b := &Boss{
			hitpoints:    14,
			maxHitpoints: 14,
			damage:       8,
		}

		s := &Simulator{w: w, b: b}
		s.run(NewRecharge(), false)
		s.run(NewShield(), false)
		s.run(NewDrain(), false)
		s.run(NewPoison(), false)
		hasWon, _ := s.run(NewMagicMissle(), false)
		if !hasWon {
			t.Fatalf("expect won, %v", s)
		}
	}
}
