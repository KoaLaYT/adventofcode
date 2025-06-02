import { expect, test } from 'bun:test'
import { internal } from './solution'

test('countTrees', async () => {
  const map = await internal.getMap('./day03/example.txt')
  const got = internal.countTrees(map)
  expect(got).toBe(7)
})

test('countTreesBySlope', async () => {
  const map = await internal.getMap('./day03/example.txt')
  const testCases = [
    {
      slope: { i: 1, j: 1 },
      expect: 2,
    },
    {
      slope: { i: 3, j: 1 },
      expect: 7,
    },
    {
      slope: { i: 5, j: 1 },
      expect: 3,
    },
    {
      slope: { i: 7, j: 1 },
      expect: 4,
    },
    {
      slope: { i: 1, j: 2 },
      expect: 2,
    },
  ]

  for (const testCase of testCases) {
    const got = internal.countTreesBySlope(map, testCase.slope)
    expect(got).toBe(testCase.expect)
  }
})
