export function debug(...args) {
  if (!args.length) return

  const debuggableArgs = args.map((arg) => {
    if (typeof arg === "object") {
      const normalizedObj = {}
      for (const [key, value] of Object.entries(arg)) {
        if (typeof value === "function") {
          normalizedObj[key] = "<redacted fn>"
        } else {
          normalizedObj[key] = value
        }
      }

      return JSON.parse(JSON.stringify(normalizedObj))
    } else {
      return arg
    }
  })

  console.log(...debuggableArgs)
}
