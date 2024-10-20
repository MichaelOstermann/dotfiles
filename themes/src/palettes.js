import chroma from 'chroma-js'

const tokyonight = {
    bg: '#1F2029',
    fg: '#7481B9',
    // https://github.com/folke/tokyonight.nvim/blob/main/lua/tokyonight/colors/storm.lua
    blue: '#7AA2F7',
    green: '#9ECE6A',
    magenta: '#BB9AF7',
    orange: '#FF9E64',
    purple: '#9D7CD8',
    red: '#F7768E',
    cyan: '#1ABC9C',
    yellow: '#E0AF68',
}

// https://github.com/nacholaciar/tokyo-midnight
const tokyomidnight = {
    bg: '#212127',
    fg: '#c0caf5',
    blue: "#7aa2f7",
    green: "#41a6b5",
    magenta: "#bb9af7",
    orange: "#ff9e64",
    purple: "#9d7cd8",
    red: "#f7768e",
    cyan: "#7dcfff",
    yellow: "#e0af68",
}

// https://github.com/savq/melange-nvim
const melange = {
    bg: '#292522',
    fg: '#ECE1D7',
    blue: '#A3A9CE',
    green: '#85B695',
    // magenta: '#CF9BC2',
    // orange: '#eaa768',
    magenta: '#eaa768',
    orange: '#CF9BC2',
    red: '#D47766',
    cyan: '#89B3B6',
    yellow: '#EBC06D',
}

export default [
    {
        name: 'moonless-tokyonight',
        mode: 'dark',
        ...tokyonight,
        blue: chroma.mix(tokyonight.bg, tokyonight.blue, 0.70),
        green: chroma.mix(tokyonight.bg, tokyonight.green, 0.42),
        magenta: chroma.mix(tokyonight.bg, tokyonight.magenta, 0.50),
        orange: chroma.mix(tokyonight.bg, tokyonight.orange, 0.40),
        red: chroma.mix(tokyonight.bg, tokyonight.red, 0.50),
        cyan: chroma.mix(tokyonight.bg, chroma(tokyonight.blue).set('hsl.h', '-30'), 0.40),
        yellow: chroma.mix(tokyonight.bg, tokyonight.yellow, 0.40),
    },
    {
        name: 'moonless-tokyomidnight',
        mode: 'dark',
        ...tokyomidnight,
        fg: chroma.mix(tokyomidnight.bg, tokyomidnight.fg, 0.5),
        blue: chroma.mix(tokyomidnight.bg, tokyomidnight.blue, 0.5),
        green: chroma.mix(tokyomidnight.bg, tokyomidnight.green, 0.5),
        orange: chroma.mix(tokyomidnight.bg, tokyomidnight.orange, 0.5),
        red: chroma.mix(tokyomidnight.bg, tokyomidnight.red, 0.5),
        magenta: chroma.mix(tokyomidnight.bg, tokyomidnight.magenta, 0.5),
        cyan: chroma.mix(tokyomidnight.bg, tokyomidnight.cyan, 0.5),
        yellow: chroma.mix(tokyomidnight.bg, tokyomidnight.yellow, 0.5),
    },
    {
        name: 'moonless-melange',
        mode: 'dark',
        ...melange,
        fg: chroma.mix(melange.bg, melange.fg, 0.35),
        blue: chroma.mix(melange.bg, melange.blue, 0.70),
        green: chroma.mix(melange.bg, melange.green, 0.50),
        orange: chroma.mix(melange.bg, melange.orange, 0.40),
        magenta: chroma.mix(melange.bg, melange.magenta, 0.50),
        cyan: chroma.mix(melange.bg, melange.cyan, 0.40),
        yellow: chroma.mix(melange.bg, melange.yellow, 0.40),
    },
]
