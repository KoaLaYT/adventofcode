package main

import "testing"

func TestParseAunt(t *testing.T) {
	input := `Sue 22: perfumes: 7, children: 1, pomeranians: 7`
	aunt := ParseAunt(input)

	if aunt.id != 22 {
		t.Fatalf("expect id: 22, got: %d", aunt.id)
	}

	if len(aunt.compounds) != 3 {
		t.Fatalf("expect 3 compounds, got: %d", len(aunt.compounds))
	}

	if aunt.compounds["perfumes"] != 7 ||
		aunt.compounds["children"] != 1 ||
		aunt.compounds["pomeranians"] != 7 {
		t.Fatalf("bad compounds, got: %v", aunt.compounds)
	}
}
