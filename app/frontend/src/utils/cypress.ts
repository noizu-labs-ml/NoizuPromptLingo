// docs/cypress-attributes.md §3 — spread helper for data-cy-* attributes
type Cy = {
  cy?: string;
  cyId?: string | number;
  cyFor?: string | number;
  cyValue?: string | number;
  cyScope?: string;
};

export const cyAttrs = ({ cy, cyId, cyFor, cyValue, cyScope }: Cy = {}) => ({
  ...(cy && { "data-cy": cy }),
  ...(cyId !== undefined && { "data-cy-id": String(cyId) }),
  ...(cyFor !== undefined && { "data-cy-for": String(cyFor) }),
  ...(cyValue !== undefined && { "data-cy-value": String(cyValue) }),
  ...(cyScope && { "data-cy-scope": cyScope }),
});
