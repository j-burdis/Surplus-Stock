const defaultTheme = require('tailwindcss/defaultTheme')

module.exports = {
  content: [
    './public/*.html',
    './app/helpers/**/*.rb',
    './app/javascript/**/*.js',
    './app/views/**/*.{erb,haml,html,slim}'
  ],
  theme: {
    extend: {
      colors: {
        primaryText: '#333333', // Charcoal gray
        secondaryText: '#666666', // Cool gray
        background: '#F8F9FA', // Ivory White
        darkBlue: '#03346E', // Dark blue
        lighterBlue: '#7AB2D3', // Lighter blue
      },
      fontFamily: {
        montserrat: ['Montserrat', 'sans-serif'],
      },
    },
  },
  plugins: [
    // require('@tailwindcss/forms'),
    // require('@tailwindcss/typography'),
    // require('@tailwindcss/container-queries'),
  ]
}
