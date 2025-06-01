import assert from 'node:assert'

export const internal = {
  async getInputs(filename: string) {
    const raw = await Bun.file(filename).text()
    return raw.split('\n').filter(Boolean)
  },

  count(password: string, alpha: string) {
    const map = new Map<string, number>()

    for (const ele of password) {
      const v = map.get(ele) || 0
      map.set(ele, v + 1)
    }

    return map.get(alpha) || 0
  },

  isValid(input: string) {
    const matcher = input.match(/(\d+)-(\d+) ([a-z]): ([a-z]+)/)
    assert(matcher, `unknown input: <${input}>`)

    const [low, high] = [Number(matcher[1]), Number(matcher[2])]
    const target = matcher[3]!
    const password = matcher[4]!

    const count = this.count(password, target)

    return low <= count && count <= high
  },

  isValid2(input: string) {
    const matcher = input.match(/(\d+)-(\d+) ([a-z]): ([a-z]+)/)
    assert(matcher, `unknown input: <${input}>`)

    const [p1, p2] = [Number(matcher[1]) - 1, Number(matcher[2]) - 1]
    const target = matcher[3]!
    const password = matcher[4]!

    const b1 = password[p1] === target && password[p2] !== target
    const b2 = password[p1] !== target && password[p2] === target

    return b1 || b2
  },
}

export const solution = {
  async p1() {
    const inputs = await internal.getInputs('./day02/input.txt')
    let count = 0
    for (const input of inputs) {
      if (internal.isValid(input)) {
        count += 1
      }
    }
    return count
  },
  async p2() {
    const inputs = await internal.getInputs('./day02/input.txt')
    let count = 0
    for (const input of inputs) {
      if (internal.isValid2(input)) {
        count += 1
      }
    }
    return count
  },
}
