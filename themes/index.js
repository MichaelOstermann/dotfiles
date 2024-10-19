import Handlebars from 'handlebars'
import theme from './src/theme'
import palettes from './src/palettes'

const nvim = Handlebars.compile(await Bun.file('./src/templates/nvim.lua').text())
const wezterm = Handlebars.compile(await Bun.file('./src/templates/wezterm.lua').text())

palettes.map(function(palette) {
    Bun.write(`../.config/nvim/colors/${palette.name}.lua`, nvim(theme(palette)))
    Bun.write(`../.config/wezterm/themes/${palette.name}.lua`, wezterm(theme(palette)))
})
