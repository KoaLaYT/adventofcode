package main

import (
	"context"
	"crypto/md5"
	"encoding/hex"
	"fmt"
	"hash"
	"io"
	"math"
	"runtime"
	"strings"
	"sync"
)

type Miner struct {
	secret    string
	difficult int
	h         hash.Hash
}

func NewMiner(secret string, difficult int) *Miner {
	return &Miner{
		secret:    secret,
		difficult: difficult,
		h:         md5.New(),
	}
}

func (m *Miner) Mine() (string, int) {
	prefix := strings.Repeat("0", m.difficult)

	for i := 1; i > 0; i++ {
		m.h.Reset()
		io.WriteString(m.h, m.secret)
		io.WriteString(m.h, fmt.Sprintf("%d", i))
		result := m.h.Sum(nil)
		hash := hex.EncodeToString(result)

		if strings.HasPrefix(hash, prefix) {
			return hash, i
		}
	}

	panic("Can not mine")
}

type ConcurrentMiner struct {
	secret    string
	difficult int

	mu          sync.Mutex
	maybeResult int
}

func NewConcurrentMiner(secret string, difficult int) *ConcurrentMiner {
	return &ConcurrentMiner{
		secret:      secret,
		difficult:   difficult,
		mu:          sync.Mutex{},
		maybeResult: math.MaxInt,
	}
}

func (cm *ConcurrentMiner) Mine() (string, int) {
	workers := runtime.NumCPU() - 2
	resultChan := make(chan int, workers)
	ctx, cancel := context.WithCancel(context.Background())
	defer cancel()

	var wg sync.WaitGroup
	wg.Add(workers)
	for i := 1; i <= workers; i++ {
		go cm.mineWorker(ctx, cancel, i, workers, resultChan, &wg)
	}
	wg.Wait()
	close(resultChan)

	min := math.MaxInt
	for i := range resultChan {
		if i < min {
			min = i
		}
	}

	h := md5.New()
	io.WriteString(h, cm.secret)
	io.WriteString(h, fmt.Sprintf("%d", min))
	result := h.Sum(nil)
	hash := hex.EncodeToString(result)

	return hash, min
}

func (cm *ConcurrentMiner) mineWorker(
	ctx context.Context, cancel context.CancelFunc,
	start, step int,
	resultChan chan<- int,
	wg *sync.WaitGroup,
) {
	defer wg.Done()
	defer cancel()

	prefix := strings.Repeat("0", cm.difficult)
	h := md5.New()

	for i := start; i > 0; i += step {
		select {
		case <-ctx.Done():
			cm.mu.Lock()
			maybeResult := cm.maybeResult
			cm.mu.Unlock()
			for j := i; j < maybeResult; j += step {
				if cm.found(h, j, prefix) {
					resultChan <- j
					break
				}
			}
			return
		default:
			if cm.found(h, i, prefix) {
				resultChan <- i
				cm.mu.Lock()
				if i < cm.maybeResult {
					cm.maybeResult = i
				}
				cm.mu.Unlock()
				return
			}
		}
	}
}

func (cm *ConcurrentMiner) found(h hash.Hash, i int, prefix string) bool {
	h.Reset()

	io.WriteString(h, cm.secret)
	io.WriteString(h, fmt.Sprintf("%d", i))
	result := h.Sum(nil)
	hash := hex.EncodeToString(result)

	return strings.HasPrefix(hash, prefix)
}
