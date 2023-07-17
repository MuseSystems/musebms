// See the Tailwind configuration guide for advanced usage
// https://tailwindcss.com/docs/configuration

const plugin = require("tailwindcss/plugin")
const fs = require("fs")
const path = require("path")
const colors = require("tailwindcss/colors")

module.exports = {
  content: [
    "./js/**/*.js",
    "../lib/*_web.ex",
    "../lib/*_web/**/*.*ex",
    "../../../../../components/system/mscmp_syst_forms/**/*.*ex"
  ],
  theme: {
    extend: {
      colors: {
        "color-deemphasis": colors.gray["200"],
        "color-reference": colors.gray["300"],
        "color-normal": colors.neutral["800"],
        "color-emphasis": colors.neutral["900"],
        "color-alert": colors.red["800"],
        "color-warning": colors.yellow["600"],
        "color-approve": colors.lime["700"],
        "color-deny": colors.orange["700"],
        "color-info": colors.indigo["600"],
        "color-deemphasis-inverted": colors.gray["800"],
        "color-reference-inverted": colors.gray["700"],
        "color-normal-inverted": colors.neutral["100"],
        "color-emphasis-inverted": colors.neutral["100"],
        "color-alert-inverted": colors.red["200"],
        "color-warning-inverted": colors.yellow["200"],
        "color-approve-inverted": colors.lime["300"],
        "color-deny-inverted": colors.orange["300"],
        "color-info-inverted": colors.indigo["200"]
      }
    },
    fontFamily: {
      'sans': ['Helvetica', 'Arial', 'sans-serif']
    }
  },
  plugins: [
    require("@tailwindcss/forms"),
    // Allows prefixing tailwind classes with LiveView classes to add rules
    // only when LiveView classes are applied, for example:
    //
    //     <div class="phx-click-loading:animate-ping">
    //
    plugin(({addVariant}) => addVariant("phx-no-feedback", [".phx-no-feedback&", ".phx-no-feedback &"])),
    plugin(({addVariant}) => addVariant("phx-click-loading", [".phx-click-loading&", ".phx-click-loading &"])),
    plugin(({addVariant}) => addVariant("phx-submit-loading", [".phx-submit-loading&", ".phx-submit-loading &"])),
    plugin(({addVariant}) => addVariant("phx-change-loading", [".phx-change-loading&", ".phx-change-loading &"])),

    // Embeds Hero Icons (https://heroicons.com) into your app.css bundle
    // See your `CoreComponents.icon/1` for more information.
    //
    plugin(function({matchComponents, theme}) {
      let iconsDir = path.join(__dirname, "../priv/hero_icons/optimized")
      let values = {}
      let icons = [
        ["", "/24/outline"],
        ["-solid", "/24/solid"],
        ["-mini", "/20/solid"]
      ]
      icons.forEach(([suffix, dir]) => {
        fs.readdirSync(path.join(iconsDir, dir)).map(file => {
          let name = path.basename(file, ".svg") + suffix
          values[name] = {name, fullPath: path.join(iconsDir, dir, file)}
        })
      })
      matchComponents({
        "hero": ({name, fullPath}) => {
          let content = fs.readFileSync(fullPath).toString().replace(/\r?\n|\r/g, "")
          return {
            [`--hero-${name}`]: `url('data:image/svg+xml;utf8,${content}')`,
            "-webkit-mask": `var(--hero-${name})`,
            "mask": `var(--hero-${name})`,
            "background-color": "currentColor",
            "vertical-align": "middle",
            "display": "inline-block",
            "width": theme("spacing.5"),
            "height": theme("spacing.5")
          }
        }
      }, {values})
    })
  ]
}
