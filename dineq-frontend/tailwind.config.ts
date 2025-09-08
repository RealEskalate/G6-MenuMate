import type { Config } from "tailwindcss";
import defaultTheme from "tailwindcss/defaultTheme";

export default {
  theme: {
    extend: {
      keyframes: {
        fadeInUp: {
          "0%": { opacity: "0", transform: "translateY(20px)" },
          "100%": { opacity: "1", transform: "translateY(0)" },
        },
      },
      animation: {
        fadeInUp: "fadeInUp 0.6s ease forwards",
      },
      fontFamily: {
        body: ["var(--font-body)", ...defaultTheme.fontFamily.sans],
        headings: ["var(--font-headings)", ...defaultTheme.fontFamily.serif],
      },
    },
  },
  plugins: [],
} satisfies Config;
