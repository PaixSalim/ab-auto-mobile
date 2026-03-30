export function getRealPrice(price: number, percent: number) {
  return price - (price * percent) / 100
}
