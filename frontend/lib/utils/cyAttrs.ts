type Cy = {
  cy?: string;
  cyId?: string | number;
  cyFor?: string;
  cyValue?: string | number;
  cyScope?: string;
};

export const cyAttrs = ({ cy, cyId, cyFor, cyValue, cyScope }: Cy = {}) => ({
  ...(cy && { "data-cy": cy }),
  ...(cyId !== undefined && { "data-cy-id": String(cyId) }),
  ...(cyFor && { "data-cy-for": String(cyFor) }),
  ...(cyValue !== undefined && { "data-cy-value": String(cyValue) }),
  ...(cyScope && { "data-cy-scope": cyScope }),
});
