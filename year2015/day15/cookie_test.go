package main

import "testing"

func TestFindFormula(t *testing.T) {
	cookie := Cookie{
		ingredients: []Ingredient{
			{"Butterscotch", -1, -2, 6, 3, 8},
			{"Cinnamon", 2, 3, -2, -1, 3},
		},
	}

	{
		var expect int64 = 62842880
		formula, got := cookie.FindHighestScore()

		if got != expect {
			t.Fatalf("got: %d, expect: %d", got, expect)
		}

		if formula["Butterscotch"] != 44 {
			t.Fatalf("Butterscotch expect 44, got: %d", formula["Butterscotch"])
		}

		if formula["Cinnamon"] != 56 {
			t.Fatalf("Cinnamon expect 56, got: %d", formula["Cinnamon"])
		}
	}

	{
		var expect int64 = 57600000
		formula, got := cookie.FindHighestScoreWithCalories(500)

		if got != expect {
			t.Fatalf("got: %d, expect: %d", got, expect)
		}

		if formula["Butterscotch"] != 40 {
			t.Fatalf("Butterscotch expect 40, got: %d", formula["Butterscotch"])
		}

		if formula["Cinnamon"] != 60 {
			t.Fatalf("Cinnamon expect 60, got: %d", formula["Cinnamon"])
		}
	}
}

func TestParseIngredient(t *testing.T) {
	input := `Chocolate: capacity 0, durability 0, flavor -2, texture 2, calories 8`
	expect := Ingredient{
		"Chocolate",
		0,
		0,
		-2,
		2,
		8,
	}
	got := ParseIngredient(input)

	if got.name != expect.name ||
		got.capacity != expect.capacity ||
		got.durability != expect.durability ||
		got.flavor != expect.flavor ||
		got.texture != expect.texture ||
		got.calories != expect.calories {
		t.Fatalf("got: %v, expect: %v", got, expect)
	}
}
