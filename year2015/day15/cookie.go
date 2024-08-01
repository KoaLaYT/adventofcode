package main

import (
	"bufio"
	"fmt"
	"io"
	"koalayt/adventofcode/year2015/internal"
	"regexp"
)

type Ingredient struct {
	name       string
	capacity   int64
	durability int64
	flavor     int64
	texture    int64
	calories   int64
}

func ParseIngredient(s string) Ingredient {
	r := regexp.MustCompile(`^(\w+): capacity (-?\d+), durability (-?\d+), flavor (-?\d+), texture (-?\d+), calories (-?\d+)$`)
	matches := r.FindAllStringSubmatch(s, -1)
	for _, m := range matches {
		return Ingredient{
			name:       m[1],
			capacity:   internal.MustAtoi[int64](m[2]),
			durability: internal.MustAtoi[int64](m[3]),
			flavor:     internal.MustAtoi[int64](m[4]),
			texture:    internal.MustAtoi[int64](m[5]),
			calories:   internal.MustAtoi[int64](m[6]),
		}
	}
	panic(fmt.Errorf("Can not parse ingredient from %s", s))
}

type Cookie struct {
	ingredients []Ingredient
}

func ParseCookie(r io.Reader) Cookie {
	var ingredients []Ingredient

	scanner := bufio.NewScanner(r)
	for scanner.Scan() {
		txt := scanner.Text()
		ingredients = append(ingredients, ParseIngredient(txt))
	}

	return Cookie{ingredients}
}

func (c Cookie) scoreAndCalories(formula map[string]int64) (int64, int64) {
	var capacity, durability, flavor, texture, calories int64 = 0, 0, 0, 0, 0

	for _, ingredient := range c.ingredients {
		teaspoons := formula[ingredient.name]
		capacity += ingredient.capacity * teaspoons
		durability += ingredient.durability * teaspoons
		flavor += ingredient.flavor * teaspoons
		texture += ingredient.texture * teaspoons
		calories += ingredient.calories * teaspoons
	}

	if capacity <= 0 || durability <= 0 || flavor <= 0 || texture <= 0 {
		return 0, calories
	}

	return capacity * durability * flavor * texture, calories
}

func (c Cookie) FindHighestScore() (map[string]int64, int64) {
	formula := make(map[string]int64)
	bestFormula := make(map[string]int64)
	return c.findHighestScore(0, 100, formula, bestFormula, 0, -1)
}

func (c Cookie) FindHighestScoreWithCalories(calories int64) (map[string]int64, int64) {
	formula := make(map[string]int64)
	bestFormula := make(map[string]int64)
	return c.findHighestScore(0, 100, formula, bestFormula, 0, calories)
}

func copyFormula(formula map[string]int64) map[string]int64 {
	dst := make(map[string]int64, len(formula))
	for k, v := range formula {
		dst[k] = v
	}
	return dst
}

func (c Cookie) findHighestScore(
	idx int, left int,
	formula map[string]int64,
	bestFormula map[string]int64,
	maxScore int64,
	targetCalories int64,
) (map[string]int64, int64) {
	if left == 0 {
		score, calories := c.scoreAndCalories(formula)
		if targetCalories > 0 && calories != targetCalories {
			return bestFormula, maxScore
		}
		if score > maxScore {
			return copyFormula(formula), score
		}
		return bestFormula, maxScore
	}

	if idx < len(c.ingredients) {
		ingredient := c.ingredients[idx]
		for i := 0; i <= left; i++ {
			formula[ingredient.name] = int64(i)
			newFormula, score := c.findHighestScore(idx+1, left-i, formula, bestFormula, maxScore, targetCalories)
			formula[ingredient.name] = 0
			if score > maxScore {
				maxScore = score
				bestFormula = newFormula
			}
		}
	}

	return bestFormula, maxScore
}
