// tailwind.config.ts
import type { Config } from "tailwindcss";

export default {
  // The 'content' property is not needed in Tailwind v4
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
    },
  },
  plugins: [],
} satisfies Config;
