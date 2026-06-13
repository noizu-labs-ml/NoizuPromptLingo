# Design System — Neural Neon

## Style Direction

Bold Expressive (80%) + Minimal Tech (20%). The game aesthetic is electric, competitive, and futuristic. Bold for energy and app-store visual impact; Minimal Tech for the graph editor and data visualizations.

## Color Palette

| Token | Hex | Usage |
|-------|-----|-------|
| Background | `#0A0A0F` | Near-black with blue undertone |
| Surface | `#14141F` | Elevated cards, panels |
| Border | `#2A2A3A` | Subtle structure lines |
| Primary | `#00FFAA` | Electric mint — "synapse" color, wins |
| Secondary | `#FF3366` | Hot pink — aggression, damage, losses |
| Tertiary | `#3366FF` | Electric blue — defense, utility, neutral |
| Accent | `#FFAA00` | Amber — rewards, currency, rank, warnings |
| Text | `#E8E8F0` | Off-white body text |
| Text Muted | `#6B6B80` | Secondary/deemphasized text |

## Typography

| Role | Font | Usage |
|------|------|-------|
| Display | Monument Extended (or Space Grotesk Black) | Fighter names, arena titles, season banners. Uppercase, tight tracking. |
| UI / Body | Inter or DM Sans | Graph labels, stats, menus. Clean at small mobile sizes. |
| Monospace | JetBrains Mono | Node parameters, confidence values, data readouts. |

## Visual Motifs

- **Neural pathways**: Glowing connected-node lines in backgrounds, transitions, loading screens
- **Particle effects**: Sparks, energy trails, data-stream particles on fighter actions
- **Glassmorphism**: Frosted dark glass overlays at ~60% opacity
- **Decision graph as identity**: Player's graph displayed on profiles and in replays
- **Neon glow**: Interactive elements (buttons, active nodes, selected fighters)
- **Scanline textures**: Subtle CRT horizontal lines for "inside the machine" feel

## Motion Language

| Interaction | Animation | Duration |
|-------------|-----------|----------|
| Node connection | Glowing line draws between nodes | 200ms ease-out |
| Battle hit | Screen shake + color flash | 100ms |
| Training generation | Counter tick + graph line extends | 300ms/gen |
| Win | Glow pulse + confetti particles | 800ms spring |
| Loss | Desaturation + static grain | 400ms ease-in |
| Menu transition | Horizontal slide with parallax | 250ms ease-in-out |
