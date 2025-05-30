import chroma from 'chroma-js'

const palette = {
    bg: "#1F2029",
    fg: "#7481B9",
    border: "#181921",
    blue: "#6789d0",
    green: "#69884b",
    magenta: "#866fb1",
    orange: "#a36747",
    purple: "#9D7CD8",
    red: "#b05669",
    cyan: "#51909f",
    yellow: "#907149",
}

shades("fg", palette.bg, palette.fg)
shades("blue", palette.bg, palette.blue)
shades("green", palette.bg, palette.green)
shades("magenta", palette.bg, palette.magenta)
shades("orange", palette.bg, palette.orange)
shades("purple", palette.bg, palette.purple)
shades("red", palette.bg, palette.red)
shades("cyan", palette.bg, palette.cyan)
shades("yellow", palette.bg, palette.yellow)

function shades(name, left, right) {
    for (const shade of [50, 100, 200, 300, 400, 500, 600, 700, 800, 900]) {
        palette[`${name}-${shade}`] = chroma.mix(left, right, shade / 1000).toString()
    }
}

function toLua(record) {
    const lines = []
    for (const key in record)
        lines.push(`local ${key.replace("-", "_")} = "${record[key]}"`)
    return lines.join("\n")
}

console.log(toLua(palette))
