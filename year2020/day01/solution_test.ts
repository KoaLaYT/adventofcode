import { expect, test } from 'bun:test'
import { internal } from './solution'

test('find', async () => {
  const list = await internal.getList('./day01/example.txt')
  const result = internal.find(list)
  expect(result).toBe(514579)
})

test('findThree', async () => {
  const list = await internal.getList('./day01/example.txt')
  const result = internal.findThree(list)
  expect(result).toBe(241861950)
})
