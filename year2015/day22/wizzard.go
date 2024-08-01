package main

import (
	"fmt"
	"math"
	"slices"
)

type Boss struct {
	hitpoints    int
	maxHitpoints int
	damage       int
	armor        int
}

func NewBoss(hitpoints, damage int) *Boss {
	return &Boss{hitpoints, hitpoints, damage, 0}
}

func (b *Boss) Respawn() {
	b.hitpoints = b.maxHitpoints
}

func (b *Boss) String() string {
	return fmt.Sprintf("Boss (hp: %d, damage: %d, armor: %d)", b.hitpoints, b.damage, b.armor)
}

type Wizzard struct {
	hitpoints    int
	maxHitpoints int
	mana         int
	initalMana   int
	armor        int
}

func NewWizzard(hitpoints, mana int) *Wizzard {
	return &Wizzard{
		hitpoints,
		hitpoints,
		mana,
		mana,
		0,
	}
}

func (w *Wizzard) Respawn() {
	w.hitpoints = w.maxHitpoints
	w.mana = w.initalMana
	w.armor = 0
}

func (w *Wizzard) String() string {
	return fmt.Sprintf("Wizzard (hp: %d, mp: %d, armor: %d)", w.hitpoints, w.mana, w.armor)
}

type Simulator struct {
	w       *Wizzard
	b       *Boss
	effects []Effect
	spells  []Spell
}

func NewSimulator(w *Wizzard, b *Boss) *Simulator {
	spells := []Spell{
		NewMagicMissle(),
		NewDrain(),
		NewShield(),
		NewPoison(),
		NewRecharge(),
	}
	return &Simulator{
		w:       w,
		b:       b,
		effects: nil,
		spells:  spells,
	}
}

func (s *Simulator) Reset() {
	s.w.Respawn()
	s.b.Respawn()
	s.effects = nil
}

func (s *Simulator) LeastManaToWin(part2 bool) ([]string, int) {
	spells := make([]int, 9)
	totalSpells := len(s.spells)
	leastMana := math.MaxInt
	var leastSpellNames []string

	count := 0
	for {
		count += 1
		s.Reset()
		mana := 0
		var spellNames []string
		for _, i := range spells {
			spell := s.spells[i]
			spellNames = append(spellNames, spell.Name())
			mana += spell.Cost()
			hasWon, canContinue := s.run(spell, part2)
			if canContinue {
				continue
			}

			if hasWon && mana < leastMana {
				leastMana = mana
				leastSpellNames = spellNames
			}
			break
		}

		i := 0
		for i < len(spells) {
			spells[i] += 1
			if spells[i] == totalSpells {
				spells[i] = 0
				i += 1
			} else {
				break
			}
		}
		if i == len(spells) {
			break
		}
	}

	return leastSpellNames, leastMana
}

func (s *Simulator) canCast(spell Spell) bool {
	for _, e := range s.effects {
		if spell.Name() == e.SpellName() {
			return false
		}
	}
	return true
}

func (s *Simulator) applyEffects() (hasWon bool, shouldContinue bool) {
	for _, effect := range s.effects {
		effect.Affect()
		if s.b.hitpoints <= 0 {
			return true, false
		}
	}
	s.effects = slices.DeleteFunc(s.effects, func(e Effect) bool { return e.Expired() })
	return false, true
}

func (s *Simulator) run(spell Spell, part2 bool) (hasWon bool, shouldContinue bool) {
	// players turn
	if part2 {
		s.w.hitpoints -= 1
		if s.w.hitpoints <= 0 {
			hasWon = false
			shouldContinue = false
			return
		}
	}
	if hasWon, shouldContinue = s.applyEffects(); !shouldContinue {
		return
	}
	if !s.canCast(spell) {
		hasWon = false
		shouldContinue = false
		return
	}
	s.w.mana -= spell.Cost()
	s.w.hitpoints += spell.Heal()
	s.b.hitpoints -= spell.Damage()
	if effect := spell.Effect(s.w, s.b); effect != nil {
		s.effects = append(s.effects, effect)
	}
	if s.w.mana < 0 {
		hasWon = false
		shouldContinue = false
		return
	}

	if s.b.hitpoints <= 0 {
		hasWon = true
		shouldContinue = false
		return
	}

	// boss turn
	if hasWon, shouldContinue = s.applyEffects(); !shouldContinue {
		return
	}
	s.w.hitpoints -= max(1, s.b.damage-s.w.armor)
	if s.w.hitpoints <= 0 {
		hasWon = false
		shouldContinue = false
		return
	}

	shouldContinue = true
	return
}

type Effect interface {
	SpellName() string
	Affect()
	Expired() bool
}

type ShieldEffect struct {
	w        *Wizzard
	leftTurn int
}

func (s *ShieldEffect) SpellName() string { return "Shield" }
func (s *ShieldEffect) Affect() {
	s.w.armor = 7
	s.leftTurn -= 1
}
func (s *ShieldEffect) Expired() bool {
	isExpired := s.leftTurn == 0
	if isExpired {
		s.w.armor = 0
	}
	return isExpired
}

type PoisonEffect struct {
	b        *Boss
	leftTurn int
}

func (s *PoisonEffect) SpellName() string { return "Poison" }
func (p *PoisonEffect) Affect() {
	p.b.hitpoints -= 3
	p.leftTurn -= 1
}
func (p *PoisonEffect) Expired() bool { return p.leftTurn == 0 }

type RechargeEffect struct {
	w        *Wizzard
	leftTurn int
}

func (s *RechargeEffect) SpellName() string { return "Recharge" }
func (r *RechargeEffect) Affect() {
	r.w.mana += 101
	r.leftTurn -= 1
}
func (r *RechargeEffect) Expired() bool { return r.leftTurn == 0 }

type Spell interface {
	Name() string
	Cost() int
	Damage() int
	Heal() int
	Effect(w *Wizzard, b *Boss) Effect
}

type MagicMissile struct{}

func NewMagicMissle() MagicMissile                       { return MagicMissile{} }
func (m MagicMissile) Name() string                      { return "Magic Missile" }
func (m MagicMissile) Cost() int                         { return 53 }
func (m MagicMissile) Damage() int                       { return 4 }
func (m MagicMissile) Heal() int                         { return 0 }
func (m MagicMissile) Effect(w *Wizzard, b *Boss) Effect { return nil }

type Drain struct{}

func NewDrain() Drain                             { return Drain{} }
func (m Drain) Name() string                      { return "Drain" }
func (d Drain) Cost() int                         { return 73 }
func (d Drain) Damage() int                       { return 2 }
func (d Drain) Heal() int                         { return 2 }
func (d Drain) Effect(w *Wizzard, b *Boss) Effect { return nil }

type Shield struct{}

func NewShield() Shield                            { return Shield{} }
func (m Shield) Name() string                      { return "Shield" }
func (s Shield) Cost() int                         { return 113 }
func (s Shield) Damage() int                       { return 0 }
func (s Shield) Heal() int                         { return 0 }
func (s Shield) Effect(w *Wizzard, b *Boss) Effect { return &ShieldEffect{w, 6} }

type Poison struct{}

func NewPoison() Poison                            { return Poison{} }
func (m Poison) Name() string                      { return "Poison" }
func (s Poison) Cost() int                         { return 173 }
func (s Poison) Damage() int                       { return 0 }
func (s Poison) Heal() int                         { return 0 }
func (s Poison) Effect(w *Wizzard, b *Boss) Effect { return &PoisonEffect{b, 6} }

type Recharge struct{}

func NewRecharge() Recharge                          { return Recharge{} }
func (m Recharge) Name() string                      { return "Recharge" }
func (s Recharge) Cost() int                         { return 229 }
func (s Recharge) Damage() int                       { return 0 }
func (s Recharge) Heal() int                         { return 0 }
func (s Recharge) Effect(w *Wizzard, b *Boss) Effect { return &RechargeEffect{w, 5} }
