package main

import (
	"context"
)

type Character struct {
	hitpoints    int
	maxHispoints int
	damage       int
	armor        int

	usedGold int
	items    []string
}

func NewCharacter(hitpoints, damage, armor int) *Character {
	return &Character{
		hitpoints:    hitpoints,
		maxHispoints: hitpoints,
		damage:       damage,
		armor:        armor,
	}
}

func (c *Character) Respawn() {
	c.hitpoints = c.maxHispoints
	c.usedGold = 0
	c.items = nil
}

func (c *Character) Fight(enemy *Character) bool {
	turn := 0
	for {
		if c.hitpoints <= 0 {
			return false
		}
		if enemy.hitpoints <= 0 {
			return true
		}

		if turn%2 == 0 {
			enemy.hitpoints -= max(1, c.damage-enemy.armor)
		} else {
			c.hitpoints -= max(1, enemy.damage-c.armor)
		}
		turn += 1
	}
}

type ItemKind int

const (
	Weapon ItemKind = iota
	Armor
	Ring
)

type Item struct {
	kind   ItemKind
	name   string
	cost   int
	damage int
	armor  int
}

var weapons = []Item{
	{Weapon, "Dagger", 8, 4, 0},
	{Weapon, "Shortsword", 10, 5, 0},
	{Weapon, "Warhammer", 25, 6, 0},
	{Weapon, "Longsword", 40, 7, 0},
	{Weapon, "Greataxe", 74, 8, 0},
}

var armors = []Item{
	{Armor, "Leather", 13, 0, 1},
	{Armor, "Chainmail", 31, 0, 2},
	{Armor, "Splintmail", 53, 0, 3},
	{Armor, "Bandedmail", 75, 0, 4},
	{Armor, "Platemail", 102, 0, 5},
}

var rings = []Item{
	{Ring, "Damage+1", 25, 1, 0},
	{Ring, "Damage+2", 50, 2, 0},
	{Ring, "Damage+3", 100, 3, 0},
	{Ring, "Defense+1", 20, 0, 1},
	{Ring, "Defense+2", 40, 0, 2},
	{Ring, "Defense+3", 80, 0, 3},
}

func MaxGoldToLose(boss *Character) *Character {
	var maxGoldPlayer *Character

	playerChan := make(chan *Character)
	ctx, cancel := context.WithCancel(context.Background())
	defer cancel()

	go makePlayer(ctx, playerChan)

	for {
		boss.Respawn()
		player := <-playerChan

		if player == nil {
			break
		}

		if maxGoldPlayer != nil && player.usedGold <= maxGoldPlayer.usedGold {
			continue
		}

		if !player.Fight(boss) {
			maxGoldPlayer = player
		}
	}

	return maxGoldPlayer
}

func LeastGoldToWin(boss *Character) *Character {
	var leastGoldPlayer *Character

	playerChan := make(chan *Character)
	ctx, cancel := context.WithCancel(context.Background())
	defer cancel()

	go makePlayer(ctx, playerChan)

	for {
		boss.Respawn()
		player := <-playerChan

		if player == nil {
			break
		}

		if leastGoldPlayer != nil && player.usedGold >= leastGoldPlayer.usedGold {
			continue
		}

		if player.Fight(boss) {
			leastGoldPlayer = player
		}
	}

	return leastGoldPlayer
}

func makePlayer(ctx context.Context, playerChan chan<- *Character) {
	defer close(playerChan)

	var items [][4]int
	// 1 weapon
	for i := range weapons {
		items = append(items, [4]int{i, -1, -1, -1})
	}
	// 1 weapon 1 armor
	for i := range weapons {
		for j := range armors {
			items = append(items, [4]int{i, j, -1, -1})
		}
	}
	// 1 weapon 1 armor 1 ring
	for i := range weapons {
		for j := range armors {
			for k := range rings {
				items = append(items, [4]int{i, j, k, -1})
			}
		}
	}
	// 1 weapon 1 armor 2 rings
	for i := range weapons {
		for j := range armors {
			for k := range rings {
				for l := range rings {
					if l <= k {
						continue
					}
					items = append(items, [4]int{i, j, k, l})
				}
			}
		}
	}
	// 1 weapon 1 ring
	for i := range weapons {
		for j := range rings {
			items = append(items, [4]int{i, -1, j, -1})
		}
	}
	// 1 weapon 2 rings
	for i := range weapons {
		for k := range rings {
			for l := range rings {
				if l <= k {
					continue
				}
				items = append(items, [4]int{i, -1, k, l})
			}
		}
	}

	for len(items) > 0 {
		select {
		case <-ctx.Done():
			return
		default:
			player := &Character{
				hitpoints:    100,
				maxHispoints: 100,
			}

			item := items[0]
			// pick weapon
			player.Equip(weapons[item[0]])
			// pick armor
			if item[1] != -1 {
				player.Equip(armors[item[1]])
			}
			// pick rings
			if item[2] != -1 {
				player.Equip(rings[item[2]])
			}
			if item[3] != -1 {
				player.Equip(rings[item[3]])
			}

			items = items[1:]
			playerChan <- player
		}
	}
}

func (c *Character) Equip(item Item) {
	c.damage += item.damage
	c.armor += item.armor
	c.usedGold += item.cost
	c.items = append(c.items, item.name)
}
