export class Passport {
  kv: Map<string, string> = new Map()

  static from(input: string): Passport {
    const parts = input.split(/\s+/)

    const passport = new Passport()
    for (const part of parts) {
      if (!part) continue

      const [key, val] = part.split(':')
      if (!key || !val) continue

      passport.kv.set(key, val)
    }

    return passport
  }

  get(key: string) {
    return this.kv.get(key) || ''
  }

  isValid() {
    const requirdKeys = ['byr', 'iyr', 'eyr', 'hgt', 'hcl', 'ecl', 'pid']
    for (const key of requirdKeys) {
      const v = this.kv.get(key)
      if (!v) return false
    }
    return true
  }

  isStrictValid() {
    if (!this.isValid()) return false

    return (
      this.isByrValid() &&
      this.isIyrValid() &&
      this.isEyrValid() &&
      this.isHgtValid() &&
      this.isHclValid() &&
      this.isEclValid() &&
      this.isPidValid()
    )
  }

  private isByrValid() {
    const v = Number(this.get('byr'))
    return 1920 <= v && v <= 2002
  }

  private isIyrValid() {
    const v = Number(this.get('iyr'))
    return 2010 <= v && v <= 2020
  }

  private isEyrValid() {
    const v = Number(this.get('eyr'))
    return 2020 <= v && v <= 2030
  }

  private isHgtValid() {
    const raw = this.get('hgt')
    if (raw.endsWith('cm')) {
      const v = Number(raw.slice(0, -2))
      return 150 <= v && v <= 193
    }
    if (raw.endsWith('in')) {
      const v = Number(raw.slice(0, -2))
      return 59 <= v && v <= 76
    }
    return false
  }

  private isHclValid() {
    const v = this.get('hcl')

    if (v.length !== 7) return false
    if (v[0] !== '#') return false

    for (const e of v.slice(1)) {
      const isDigit = '0' <= e && e <= '9'
      const isHex = 'a' <= e && e <= 'f'
      if (!isDigit && !isHex) {
        return false
      }
    }

    return true
  }

  private isEclValid() {
    const v = this.get('ecl')
    return ['amb', 'blu', 'brn', 'gry', 'grn', 'hzl', 'oth'].includes(v)
  }

  private isPidValid() {
    const v = this.get('pid')
    if (v.length !== 9) return false

    for (const e of v) {
      const isDigit = '0' <= e && e <= '9'
      if (!isDigit) return false
    }

    return true
  }
}

export const internal = {
  async countValid(filename: string) {
    const input = await Bun.file(filename).text()
    const parts = input.split('\n\n')

    let count = 0
    for (const part of parts) {
      const passport = Passport.from(part)
      if (passport.isValid()) count += 1
    }
    return count
  },

  async countStrictValid(filename: string) {
    const input = await Bun.file(filename).text()
    const parts = input.split('\n\n')

    let count = 0
    for (const part of parts) {
      const passport = Passport.from(part)
      if (passport.isStrictValid()) count += 1
    }
    return count
  },
}

export const solution = {
  async p1() {
    return await internal.countValid('./day04/input.txt')
  },

  async p2() {
    return await internal.countStrictValid('./day04/input.txt')
  },
}
