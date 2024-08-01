package main

import (
	"bufio"
	"io"
)

func CountStringCode(s string) int {
	return len(s)
}

func CountStringMemory(s string) int {
	result := 0
	i := 1
	for i < len(s)-1 {
		if s[i] == '\\' {
			if s[i+1] == '\\' {
				result += 1
				i += 2
				continue
			} else if s[i+1] == '"' {
				result += 1
				i += 2
				continue
			} else if s[i+1] == 'x' {
				result += 1
				i += 4
				continue
			}
		}

		result += 1
		i += 1
	}
	return result
}

func CountDiff(r io.Reader) int {
	result := 0

	scanner := bufio.NewScanner(r)
	for scanner.Scan() {
		txt := scanner.Text()
		if len(txt) <= 0 {
			continue
		}

		code := CountStringCode(txt)
		memory := CountStringMemory(txt)

		result += code - memory
	}

	return result
}

func CountDiffV2(r io.Reader) int {
	result := 0

	scanner := bufio.NewScanner(r)
	for scanner.Scan() {
		txt := scanner.Text()
		if len(txt) <= 0 {
			continue
		}

		result += CountEncodedDiff(txt)
	}

	return result
}

func CountEncodedDiff(s string) int {
	result := 4

	i := 1
	for i < len(s)-1 {
		if s[i] == '\\' {
			if s[i+1] == '\\' {
				result += 2
				i += 2
				continue
			} else if s[i+1] == '"' {
				result += 2
				i += 2
				continue
			} else if s[i+1] == 'x' {
				result += 1
				i += 4
				continue
			}
		}

		i += 1
	}

	return result
}
