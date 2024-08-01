package main

import (
	"encoding/json"
	"fmt"
	"io"
)

func SumNumbersIgnoreRed(r io.Reader) int {
	decoder := json.NewDecoder(r)

	t, err := decoder.Token()
	if err == io.EOF {
		return 0
	}
	if err != nil {
		panic(err)
	}

	switch tt := t.(type) {
	case json.Delim:
		if tt == '{' {
			return sumObjectIgnoreRed(decoder)
		} else if tt == '[' {
			return sumArray(decoder)
		}
	case float64:
		return int(tt)
	}

	return 0
}

func sumArray(decoder *json.Decoder) int {
	sum := 0
	for {
		t, err := decoder.Token()
		if err == io.EOF {
			return sum
		}
		if err != nil {
			panic(err)
		}

		switch tt := t.(type) {
		case json.Delim:
			if tt == '{' {
				sum += sumObjectIgnoreRed(decoder)
			} else if tt == '[' {
				sum += sumArray(decoder)
			} else if tt == ']' {
				return sum
			} else {
				panic(fmt.Errorf("[array] Unmatched token `%v`", tt))
			}
		case float64:
			sum += int(tt)
		}
	}
}

func sumObjectIgnoreRed(decoder *json.Decoder) int {
	sum := 0
	isValue := false

	for {
		t, err := decoder.Token()
		if err == io.EOF {
			return sum
		}
		if err != nil {
			panic(err)
		}

		switch tt := t.(type) {
		case json.Delim:
			isValue = false
			if tt == '[' {
				sum += sumArray(decoder)
			} else if tt == '{' {
				sum += sumObjectIgnoreRed(decoder)
			} else if tt == '}' {
				return sum
			} else {
				panic(fmt.Errorf("[object] Unmatched token `%v`", tt))
			}
		case string:
			if tt == "red" && isValue {
				skipTillEnd(decoder)
				return 0
			}
			isValue = !isValue
		case float64:
			isValue = false
			sum += int(tt)
		case bool:
		case nil:
			isValue = false
		}
	}
}

func skipTillEnd(decoder *json.Decoder) {
	count := 1
	for {
		t, err := decoder.Token()
		if err != nil {
			panic(err)
		}

		switch tt := t.(type) {
		case json.Delim:
			if tt == '{' {
				count += 1
			} else if tt == '}' {
				count -= 1
			}
		}

		if count == 0 {
			return
		}
	}
}

func SumNumbers(r io.Reader) int {
	sum := 0

	decoder := json.NewDecoder(r)
	for {
		t, err := decoder.Token()
		if err == io.EOF {
			return sum
		}
		if err != nil {
			panic(err)
		}

		switch tt := t.(type) {
		case float64:
			sum += int(tt)
		}
	}
}
