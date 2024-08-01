package main

const UpFloor byte = '('
const DownFloor byte = ')'

func FloorFinderV2(input string) int {
	floor := 0
	for i, b := range []byte(input) {
		if b == UpFloor {
			floor++
		}
		if b == DownFloor {
			floor--
		}
		if floor == -1 {
			return i + 1
		}
	}
	return 0
}

func FloorFinder(input string) int {
	floor := 0
	for _, b := range []byte(input) {
		if b == UpFloor {
			floor++
		}
		if b == DownFloor {
			floor--
		}
	}
	return floor
}
