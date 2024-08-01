package main

func LowsetHouseNumber(target int64) ([]int64, int64) {
	houses := make([]int64, target/10+1)
	for step := 1; step < len(houses); step++ {
		for i := step; i < len(houses); i += step {
			houses[i] += int64(step * 10)
		}
	}

	for i, v := range houses {
		if v >= target {
			return houses, int64(i)
		}
	}

	panic("unreachable")
}

func LowsetHouseNumberV2(target int64) int64 {
	houses := make([]int64, target/11+1)
	for step := 1; step < len(houses); step++ {
		for i := step; i < min(step*50+1, len(houses)); i += step {
			houses[i] += int64(step * 11)
		}
	}

	for i, v := range houses {
		if v >= target {
			return int64(i)
		}
	}

	panic("unreachable")
}
