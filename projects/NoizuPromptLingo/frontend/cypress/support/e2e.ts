import "./commands";

Cypress.on("uncaught:exception", (err) => {
  // Next.js static export hydration mismatches are expected when Cypress
  // visits routes that weren't pre-rendered via generateStaticParams.
  if (err.message.includes("418") || err.message.includes("Hydration")) {
    return false;
  }
});
