// tailwind.config.js
module.exports = {
  content: [
    "./app/**/*.{js,ts,jsx,tsx}",
    "./components/**/*.{js,ts,jsx,tsx}",
  ],
  theme: {
    extend: {
      colors: {
        primary: "var(--color-primary)",
        alert: "var(--color-alert)",
      },
      fontFamily: {
        inter: ["Inter", "sans-serif"], // or roboto if you switch back
      },
    },
  },
  plugins: [],
};
