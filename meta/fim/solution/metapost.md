# MetaPost Graphics Language

## Setup
```bash
# Usually included with TeX
apt-get install texlive-metapost
# Compile
mpost figure.mp
# Creates figure.1, figure.2, etc.

# Convert to SVG
mpost --mem=mpost --tex=latex figure.mp
pdf2svg figure.pdf figure.svg
```

## Basic Drawing
```metapost
beginfig(1);
  % Unit settings
  u := 1cm;

  % Path definition
  path p;
  p := (0,0)--(2u,0)--(1u,1.5u)--cycle;

  % Draw and fill
  fill p withcolor 0.8white;
  draw p withpen pencircle scaled 2pt;

  % Points and labels
  dotlabel.bot("$A$", (0,0));
  dotlabel.bot("$B$", (2u,0));
  dotlabel.top("$C$", (1u,1.5u));
endfig;
```

## Curves and Transformations
```metapost
beginfig(2);
  % Bezier curve
  path curve;
  curve := (0,0){right}..(1cm,2cm){up}..(2cm,1cm){right};
  draw curve withcolor blue;

  % Transformed copies
  for i=1 upto 3:
    draw curve rotated (30i) withcolor (0.2+0.2i)*green;
  endfor;

  % Arrow
  drawarrow (0,0)--(3cm,0);
  label.rt("$x$", (3cm,0));
endfig;
```

## Mathematical Plots
```metapost
beginfig(3);
  % Function plotting
  path sine;
  sine := (0,0)
  for x=0.1 step 0.1 until 6.28:
    ..(x*1cm, sin(x)*1cm)
  endfor;
  draw sine withcolor red;

  % Grid
  for i=-3 upto 3:
    draw (0,i*cm)--(6cm,i*cm) withcolor 0.8white;
  endfor;
endfig;
```

## NPL-FIM Export
```javascript
// Convert NPL path to MetaPost
const path = npl.parsePath("M0,0 C1,2 2,1 3,0");
const mp = path.toMetaPost();
// Output: (0,0){right}..(1cm,2cm)..(3cm,0)
```