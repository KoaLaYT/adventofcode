const TREE = '#'

export const internal = {
  async getMap(filename: string) {
    const raw = await Bun.file(filename).text()
    return raw.split('\n').filter(Boolean)
  },

  countTrees(map: string[]) {
    let j = 0
    let count = 0
    for (let i = 0; i < map.length; i++) {
      if (map[i]![j] === TREE) count += 1

      j = (j + 3) % map[i]!.length
    }
    return count
  },

  countTreesBySlope(map: string[], slope: { i: number; j: number }) {
    let j = 0
    let count = 0
    for (let i = 0; i < map.length; i += slope.j) {
      if (map[i]![j] === TREE) count += 1

      j = (j + slope.i) % map[i]!.length
    }
    return count
  },
}

export const solution = {
  async p1() {
    const map = await internal.getMap('./day03/input.txt')
    return internal.countTrees(map)
  },

  async p2() {
    const map = await internal.getMap('./day03/input.txt')
    const slopes = [
      { i: 1, j: 1 },
      { i: 3, j: 1 },
      { i: 5, j: 1 },
      { i: 7, j: 1 },
      { i: 1, j: 2 },
    ]
    let result = 1
    for (const slope of slopes) {
      result *= internal.countTreesBySlope(map, slope)
    }
    return result
  },
}
