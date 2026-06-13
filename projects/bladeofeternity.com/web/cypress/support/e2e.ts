import './commands';

// Next.js dev mode can throw hydration mismatches (e.g. Typekit stylesheet
// link rendered differently between server and client). These are harmless —
// React recovers by re-rendering the tree client-side.
Cypress.on('uncaught:exception', (err) => {
  if (err.message.includes('Hydration')) return false;
  return true;
});
