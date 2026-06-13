# ChemDraw JS Chemistry Visualization

## Setup
```html
<!-- ChemDraw JS (Commercial license required) -->
<script src="chemdraw-js/chemdraw.js"></script>
<link rel="stylesheet" href="chemdraw-js/chemdraw.css">

<!-- Alternative: RDKit.js (Open source) -->
<script src="https://unpkg.com/@rdkit/rdkit/dist/RDKit_minimal.js"></script>

<!-- Alternative: Ketcher (Open source) -->
<script src="https://cdn.jsdelivr.net/npm/ketcher-standalone@latest/dist/ketcher.js"></script>
```

## RDKit.js Implementation
```javascript
// Initialize RDKit
initRDKitModule().then(function(RDKit) {
  // Create molecule from SMILES
  const mol = RDKit.get_mol("CCO");  // Ethanol

  // Generate SVG
  const svg = mol.get_svg();
  document.getElementById('molecule').innerHTML = svg;

  // Calculate properties
  const mw = JSON.parse(mol.get_descriptors()).MolWt;
  console.log(`Molecular weight: ${mw}`);

  mol.delete();
});
```

## Ketcher Editor
```javascript
// Initialize Ketcher
const ketcher = new Ketcher.Ketcher({
  element: document.getElementById('editor'),
  staticResourcesUrl: '/ketcher/static/',
  structServiceProvider: {
    serverUrl: 'https://api.example.com/indigo'
  }
});

// Load molecule
ketcher.setMolecule('CCO');  // SMILES
// Or MOL file
ketcher.setMolecule(molFileContent);

// Get structure
const smiles = await ketcher.getSmiles();
const mol = await ketcher.getMolfile();
```

## 3D Visualization with 3Dmol.js
```html
<script src="https://3Dmol.org/build/3Dmol-min.js"></script>

<script>
// Create viewer
const viewer = $3Dmol.createViewer('mol-3d', {
  backgroundColor: 'white'
});

// Load structure
viewer.addModel(`
HETATM    1  O           1       0.000   0.000   0.000
HETATM    2  H           1       0.757   0.586   0.000
HETATM    3  H           1      -0.757   0.586   0.000
`, 'pdb');

// Style molecule
viewer.setStyle({}, {
  stick: {radius: 0.15},
  sphere: {scale: 0.3}
});
viewer.zoomTo();
viewer.render();
</script>
```

## Chemical Reactions
```javascript
// Using RDKit.js for reactions
const rxn = RDKit.get_rxn("[OH]>>[O-].[H+]");  // Dissociation
const products = rxn.run_reactants(mol);

// Reaction diagram
const rxnSvg = rxn.get_svg();
document.getElementById('reaction').innerHTML = rxnSvg;
```

## NPL-FIM Chemistry Integration
```javascript
// Parse NPL chemistry notation
const nplMol = "benzene{C6H6} + Br2 → bromobenzene{C6H5Br} + HBr";
const reaction = parseNPLChemistry(nplMol);
const ketcherData = reaction.toKetcher();
ketcher.setMolecule(ketcherData);
```

## Property Calculation
```javascript
// Molecular descriptors
const descriptors = JSON.parse(mol.get_descriptors());
console.log({
  formula: descriptors.MolFormula,
  weight: descriptors.MolWt,
  logP: descriptors.ClogP,
  hbondDonors: descriptors.NumHDonors,
  hbondAcceptors: descriptors.NumHAcceptors
});
```