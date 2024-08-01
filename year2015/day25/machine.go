package main

const MUL int64 = 252533
const REM int64 = 33554393

func GenCode(row, col int) int64 {
	i, j := 1, 1
	var code int64 = 20151125

	for i != row || j != col {
		code = (code * MUL) % REM

		i -= 1
		if i <= 0 {
			i = j + 1
			j = 1
		} else {
			j += 1
		}
	}

	return code
}
