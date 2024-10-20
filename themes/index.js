import Handlebars from 'handlebars'
import theme from './src/theme'
import palettes from './src/palettes'

const nvim = Handlebars.compile(await Bun.file('./src/templates/nvim.lua').text())
const wezterm = Handlebars.compile(await Bun.file('./src/templates/wezterm.lua').text())

palettes.map(function(palette) {
    Bun.write(`./dist/nvim/${palette.name}.lua`, nvim(theme(palette)))
    Bun.write(`./dist/wezterm/${palette.name}.lua`, wezterm(theme(palette)))
})
