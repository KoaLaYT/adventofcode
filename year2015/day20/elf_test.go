package main

import (
	"slices"
	"testing"
)

func TestLowestHouseNumber(t *testing.T) {
	expect := []int64{0, 10, 30, 40, 70, 60, 120, 80, 150, 130}
	got, _ := LowsetHouseNumber(100)
	if slices.Equal(got, expect) {
		t.Fatalf("got: %d, expect: %d", got, expect)
	}
}
