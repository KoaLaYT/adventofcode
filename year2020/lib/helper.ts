async function solve<T>(tag: string, solution: () => Promise<T>) {
  console.log(tag);
  const start = performance.now();
  const result = await solution();
  const end = performance.now();
  console.log("Answer:", result);
  const elapsed = (end - start).toFixed(2);
  console.log(`Took ${elapsed}ms`);
}

export const helper = {
  async solveP1<T>(solution: () => Promise<T>) {
    await solve(">>>> Part One <<<<", solution);
  },
  async solveP2<T>(solution: () => Promise<T>) {
    await solve(">>>> Part Two <<<<", solution);
  },
};
