import { expect, test } from 'bun:test'
import { internal } from './solution'

test('isValid', () => {
  const testCases = [
    {
      input: '1-3 a: abcde',
      expect: true,
    },
    {
      input: '1-3 b: cedfg',
      expect: false,
    },
    {
      input: '2-9 c: ccccccccc',
      expect: true,
    },
  ]

  for (const testCase of testCases) {
    const got = internal.isValid(testCase.input)
    expect(got, testCase.input).toBe(testCase.expect)
  }
})

test('isValid2', () => {
  const testCases = [
    {
      input: '1-3 a: abcde',
      expect: true,
    },
    {
      input: '1-3 b: cedfg',
      expect: false,
    },
    {
      input: '2-9 c: ccccccccc',
      expect: false,
    },
  ]

  for (const testCase of testCases) {
    const got = internal.isValid2(testCase.input)
    expect(got, testCase.input).toBe(testCase.expect)
  }
})
