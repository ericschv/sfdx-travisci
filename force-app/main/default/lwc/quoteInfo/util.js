export function getMonthsUntil(target) {
  const targetDate = new Date(target)
  const now = new Date()

  let months = (targetDate.getUTCFullYear() - now.getFullYear()) * 12

  months += targetDate.getUTCMonth() - now.getMonth()

  if (targetDate.getUTCDate() < now.getDate()) {
    months--
  }

  return months > 0 ? months : 0
}