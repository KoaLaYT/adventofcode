package main

import "testing"

func TestFindBestBalance(t *testing.T) {
	p := &Packages{
		packs: []int{1, 2, 3, 4, 5, 7, 8, 9, 10, 11},
	}

	{
		qe, groups := p.FindBestBalance(3)
		if qe != 99 {
			t.Fatalf("got: %d, expect 99, groups: %v", qe, groups)
		}
	}
	{
		qe, groups := p.FindBestBalance(4)
		if qe != 44 {
			t.Fatalf("got: %d, expect 44, groups: %v", qe, groups)
		}
	}
}
