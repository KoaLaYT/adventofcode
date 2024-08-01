package main

func incrPasswd(prev string) string {
	i := len(prev) - 1

	p := []byte(prev)
	for i >= 0 {
		if p[i] == 'z' {
			p[i] = 'a'
			i -= 1
			continue
		}

		p[i] += 1
		break
	}

	return string(p)
}

func NextPasswd(prev string) string {
	next := prev
	for {
		next = incrPasswd(next)

		if !meetRule1(next) {
			continue
		}

		if !meetRule2(next) {
			continue
		}

		if !meetRule3(next) {
			continue
		}

		return next
	}
}

func meetRule1(s string) bool {
	for i := 0; i < len(s)-2; i++ {
		if s[i] == s[i+1]-1 &&
			s[i+1] == s[i+2]-1 {
			return true
		}
	}
	return false
}

func meetRule2(s string) bool {
	for i := 0; i < len(s); i++ {
		if s[i] == 'i' || s[i] == 'o' || s[i] == 'l' {
			return false
		}
	}
	return true
}

func meetRule3(s string) bool {
	pairs := make(map[byte]bool)

	for i := 0; i < len(s)-1; i++ {
		if s[i] == s[i+1] {
			pairs[s[i]] = true
		}
	}

	return len(pairs) >= 2
}
