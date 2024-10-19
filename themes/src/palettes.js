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

// https://github.com/savq/melange-nvim
const melange = {
    bg: '#292522',
    fg: '#ECE1D7',
    blue: '#A3A9CE',
    green: '#85B695',
    magenta: '#CF9BC2',
    orange: '#eaa768',
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
        name: 'moonless-melange',
        mode: 'dark',
        ...melange,
        bg: chroma(melange.bg).darken(0.15),
        fg: chroma.mix(melange.bg, melange.fg, 0.35),
        blue: chroma.mix(melange.bg, melange.blue, 0.70),
        green: chroma.mix(melange.bg, melange.green, 0.50),
        orange: chroma.mix(melange.bg, melange.orange, 0.40),
        magenta: chroma.mix(melange.bg, melange.magenta, 0.50),
        cyan: chroma.mix(melange.bg, melange.cyan, 0.40),
        yellow: chroma.mix(melange.bg, melange.yellow, 0.40),
    },
]
