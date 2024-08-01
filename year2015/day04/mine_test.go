package main

import "testing"

func TestMiner(t *testing.T) {
	type testcase struct {
		secret    string
		difficult int
		expect    int
	}

	testcases := []testcase{
		{"abcdef", 5, 609043},
		{"pqrstuv", 5, 1048970},
	}

	for _, tt := range testcases {
		m := NewMiner(tt.secret, tt.difficult)
		_, result := m.Mine()
		if result != tt.expect {
			t.Fatalf("secret %s, got %d, expect %d",
				tt.secret, result, tt.expect)
		}
	}
}
