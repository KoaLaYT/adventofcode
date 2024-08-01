package main

import "koalayt/adventofcode/year2015/internal"

func main() {
	oldPasswd := "hxbxwxba"

	internal.Solve("Part One", func() string {
		return NextPasswd(oldPasswd)
	})

	internal.Solve("Part Two", func() string {
		return NextPasswd(NextPasswd(oldPasswd))
	})
}
