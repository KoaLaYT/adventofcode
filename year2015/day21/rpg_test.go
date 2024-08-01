package main

import "testing"

func TestFight(t *testing.T) {
	boss := NewCharacter(12, 7, 2)
	player := NewCharacter(8, 5, 5)

	if !player.Fight(boss) {
		t.Fatalf("expect player won, but lose")
	}

	if player.hitpoints != 2 {
		t.Fatalf("player left hitpoints, got: %d, expect: 2", player.hitpoints)
	}
}
