import { expect, test } from 'bun:test'
import { internal, Passport } from './solution'

test('Passport:from', () => {
  const input = `ecl:gry pid:860033327 eyr:2020 hcl:#fffffd
byr:1937 iyr:2017 cid:147 hgt:183cm`

  const passport = Passport.from(input)

  const data = [
    { key: 'byr', val: '1937' },
    { key: 'iyr', val: '2017' },
    { key: 'eyr', val: '2020' },
    { key: 'hgt', val: '183cm' },
    { key: 'hcl', val: '#fffffd' },
    { key: 'ecl', val: 'gry' },
    { key: 'pid', val: '860033327' },
    { key: 'cid', val: '147' },
  ]

  for (const fields of data) {
    const got = passport.get(fields.key)
    expect(got).toEqual(fields.val)
  }
})

test('countValid', async () => {
  const got = await internal.countValid('./day04/example.txt')
  expect(got).toEqual(2)
})

test('countStrictValid', async () => {
  const testCases = [
    {
      input: './day04/example1.txt',
      expect: 0,
    },
    {
      input: './day04/example2.txt',
      expect: 4,
    },
  ]

  for (const testCase of testCases) {
    const got = await internal.countStrictValid(testCase.input)
    expect(got).toEqual(testCase.expect)
  }
})
