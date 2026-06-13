export default {
  plugins: {
    "@tailwindcss/postcss": {
      optimize: process.env.NODE_ENV !== "development" ? undefined : false,
    },
  },
};
