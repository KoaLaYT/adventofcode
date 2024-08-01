package main

import (
	"fmt"
	"strings"
)

func LookAndSay(s string, round int) string {
	for i := 0; i < round; i++ {
		s = LookAndSayOneRound(s)
	}
	return s
}

func LookAndSayOneRound(s string) string {
	var sb strings.Builder

	i := 0
	for i < len(s) {
		j := count(s, i)
		sb.WriteString(fmt.Sprintf("%d", j-i))
		sb.WriteByte(s[i])
		i = j
	}

	return sb.String()
}

func count(s string, i int) int {
	b := s[i]
	for i < len(s) {
		if b != s[i] {
			break
		}
		i += 1
	}
	return i
}
