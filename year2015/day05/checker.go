package main

import (
	"bufio"
	"io"
)

var Vowels = "aeiou"
var Disallowed = []string{"ab", "cd", "pq", "xy"}

func CountNiceStringV2(r io.Reader) int {
	count := 0

	scanner := bufio.NewScanner(r)
	for scanner.Scan() {
		s := scanner.Text()
		if len(s) <= 0 {
			continue
		}

		if IsNiceStringV2(s) {
			count += 1
		}
	}

	return count
}

func CountNiceString(r io.Reader) int {
	count := 0

	scanner := bufio.NewScanner(r)
	for scanner.Scan() {
		s := scanner.Text()
		if len(s) <= 0 {
			continue
		}

		if IsNiceString(s) {
			count += 1
		}
	}

	return count
}

func IsNiceStringV2(s string) bool {
	if len(s) < 3 {
		return false
	}

	// rule 1
	meetRule1 := false
loop:
	for i := 0; i < len(s)-1; i++ {
		s1 := s[i : i+2]
		for j := i + 2; j < len(s)-1; j++ {
			s2 := s[j : j+2]
			if s1 == s2 {
				meetRule1 = true
				break loop
			}
		}
	}

	// rule 2
	meetRule2 := false
	for i := 2; i < len(s); i++ {
		if s[i-2] == s[i] {
			meetRule2 = true
			break
		}
	}

	return meetRule1 && meetRule2
}

func IsNiceString(s string) bool {
	if len(s) < 2 {
		return false
	}

	vowels := 0
	hasDoubleLetter := false

	if isVowel(s[0]) {
		vowels += 1
	}

	for i := 1; i < len(s); i++ {
		a := s[i-1]
		b := s[i]

		if hasDisallowed(a, b) {
			return false
		}

		if isVowel(b) {
			vowels += 1
		}

		if a == b {
			hasDoubleLetter = true
		}
	}

	return vowels >= 3 && hasDoubleLetter
}

func isVowel(b byte) bool {
	for _, v := range []byte(Vowels) {
		if b == v {
			return true
		}
	}
	return false
}

func hasDisallowed(a, b byte) bool {
	for _, s := range Disallowed {
		bb := []byte(s)
		if a == bb[0] && b == bb[1] {
			return true
		}
	}
	return false
}
