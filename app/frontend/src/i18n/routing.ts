import { defineRouting } from "next-intl/routing";

export const routing = defineRouting({
  locales: ["en", "ps"],
  defaultLocale: "en",
  localePrefix: "never",
  localeDetection: true,
});
