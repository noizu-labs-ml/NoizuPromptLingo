// Cypress test attribute utility following the guidelines docs/testing/cypress-attributes.md
type Cy = {
  cy?: string;
  cyId?: string;
  cyFor?: string;
  cyValue?: string | number;
  cyScope?: string;
};

export const cyAttrs = ({ cy, cyId, cyFor, cyValue, cyScope }: Cy = {}) => ({
  ...(cy && { 'data-cy': cy }),
  ...(cyId && { 'data-cy-id': String(cyId) }),
  ...(cyFor && { 'data-cy-for': String(cyFor) }),
  ...(cyValue !== undefined && { 'data-cy-value': cyValue }),
  ...(cyScope && { 'data-cy-scope': cyScope }),
});
