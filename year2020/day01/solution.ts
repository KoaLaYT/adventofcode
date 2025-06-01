export const internal = {
  async getList(filename: string) {
    const raw = await Bun.file(filename).text()
    return raw.split('\n').filter(Boolean).map(Number)
  },

  binarySearch(list: number[], target: number) {
    let lo = 0
    let hi = list.length - 1

    while (lo <= hi) {
      let mi = lo + Math.floor((hi - lo) / 2)
      const v = list[mi]!

      if (v === target) {
        return mi
      } else if (v < target) {
        lo = mi + 1
      } else {
        hi = mi - 1
      }
    }

    return -1
  },

  find(list: number[]) {
    list = list.sort((a, b) => a - b)

    for (let i = 0; i < list.length; i++) {
      const num = list[i]!
      const target = 2020 - num
      const j = this.binarySearch(list, target)

      if (j >= 0 && i !== j) {
        return num * target
      }
    }

    throw new Error('not found')
  },

  findTwo(list: number[], i: number, sum: number) {
    list = list.filter((_, ii) => i !== ii)

    for (let j = 0; j < list.length; j++) {
      const num = list[j]!
      const target = sum - num
      const k = this.binarySearch(list, target)
      if (k >= 0 && j !== k) {
        return { found: true, a: num, b: target }
      }
    }

    return { found: false }
  },

  findThree(list: number[]) {
    list = list.sort((a, b) => a - b)

    for (let i = 0; i < list.length; i++) {
      const num = list[i]!
      const left = 2020 - num

      const { found, a, b } = this.findTwo(list, i, left)
      if (found) {
        return num * a! * b!
      }
    }

    throw new Error('not found')
  },
}

export const solution = {
  async p1() {
    const list = await internal.getList('./day01/input.txt')
    return internal.find(list)
  },
  async p2() {
    const list = await internal.getList('./day01/input.txt')
    return internal.findThree(list)
  },
}
