package internal

import (
	"fmt"
	"log"
	"os"
	"path/filepath"
	"runtime"
	"strconv"
	"time"
)

var logger = log.New(os.Stdout, "[adventofcode] ", log.Lmsgprefix|log.Ltime)

func OpenInputFile() *os.File {
	_, mainfile, _, ok := runtime.Caller(1)
	if !ok {
		logger.Fatal("Can not found main file info")
	}

	mainDir := filepath.Dir(mainfile)
	inputFilename := filepath.Join(mainDir, "input.txt")

	if len(os.Args) == 2 {
		inputFilename = os.Args[1]
	}

	logger.Println("Use input file:", inputFilename)

	f, err := os.Open(inputFilename)
	if err != nil {
		logger.Fatal(err)
	}

	return f
}

func Solve[T any](label string, solution func() T) {
	start := time.Now()
	logger.Println(">>>>", label, "<<<<")
	result := solution()
	logger.Println("Answer:", result)
	logger.Println("Took:", time.Since(start).Truncate(time.Millisecond))
}

func MustAtoi[T ~int | ~int64](s string) T {
	v, err := strconv.Atoi(s)
	if err != nil {
		z := T(0)
		panic(fmt.Errorf("Convert %s to %T failed: %v", s, z, err))
	}
	return T(v)
}
