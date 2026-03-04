# 📊 Diagrams Gallery

This folder contains professional diagrams visualizing the Hetzner Nextcloud infrastructure.

---

## 📁 Available Diagrams

### 1. Architecture Overview
**File**: `architecture-overview.md`
**Description**: Complete multi-tier architecture showing all components
**Format**: Mermaid (rendered on GitHub)

### 2. Network Flow
**File**: `network-flow.md`
**Description**: Request/response flow from user to application
**Format**: Mermaid sequence diagram

### 3. Security Layers
**File**: `security-layers.md`
**Description**: Defense in depth visualization
**Format**: Mermaid mindmap

### 4. Performance Metrics
**File**: `performance-metrics.md`
**Description**: Resource utilization pie charts
**Format**: Mermaid pie charts

---

## 🖼️ Generating PNG/SVG Exports

### Method 1: Mermaid Live Editor (Recommended)

1. Visit [Mermaid Live Editor](https://mermaid.live/)
2. Copy the Mermaid code from any `.md` file in this folder
3. Paste into the editor
4. Click **Download PNG** or **Download SVG**
5. Save to `/assets/images/` folder

### Method 2: Using Mermaid CLI

```bash
# Install Mermaid CLI
npm install -g @mermaid-js/mermaid-cli

# Generate PNG
mmdc -i architecture-overview.md -o ../assets/images/architecture-overview.png -b white -w 2048 -H 1024

# Generate SVG
mmdc -i architecture-overview.md -o ../assets/images/architecture-overview.svg -b white
```

### Method 3: Using Draw.io

1. Import Mermaid diagram to [Draw.io](https://app.diagrams.net/)
2. Customize colors and styling
3. Export as PNG/SVG/PDF

---

## 📐 Diagram Guidelines

### Color Coding Standard

| Color | Hex Code | Usage |
|-------|----------|-------|
| 🔵 **Blue** | `#1971c2` | Network components |
| 🔴 **Red** | `#c92a2a` | Security/Authentication |
| 🟢 **Green** | `#2f9e44` | Application layer |
| 🟡 **Yellow** | `#f59f00` | Data storage |
| 🟣 **Purple** | `#862e9c` | Secrets/Vault |
| 🟦 **Cyan** | `#0c8599` | VPN/Network |
| ⬜ **White** | `#ffffff` | Background |

### Typography

- **Title**: 20px bold
- **Headings**: 16px bold
- **Body**: 14px regular
- **Code**: Monospace 12px

### Diagram Dimensions

- **Width**: 2048px (2K resolution)
- **Height**: Variable (auto)
- **DPI**: 300 (for print quality)
- **Background**: White (#ffffff)

---

## 🔄 Updating Diagrams

When modifying diagrams:

1. Update the Mermaid code in the `.md` file
2. Re-export PNG/SVG using methods above
3. Commit both source and exported files
4. Update README references if needed

---

## 📊 Current Diagrams

| Diagram | Source | PNG | SVG | Last Updated |
|---------|--------|-----|-----|--------------|
| Architecture Overview | ✅ | 📋 Pending | 📋 Pending | 2026-03-04 |
| Network Flow | ✅ | 📋 Pending | 📋 Pending | 2026-03-04 |
| Security Layers | ✅ | 📋 Pending | 📋 Pending | 2026-03-04 |
| Performance Metrics | ✅ | 📋 Pending | 📋 Pending | 2026-03-04 |
| Deployment Pipeline | 📋 Pending | 📋 Pending | 📋 Pending | - |

---

## 🎨 External Tools

### Recommended Diagramming Tools

1. **[Mermaid Live Editor](https://mermaid.live/)** - Quick Mermaid editing
2. **[Draw.io](https://app.diagrams.net/)** - Advanced diagramming
3. **[Excalidraw](https://excalidraw.com/)** - Hand-drawn style diagrams
4. **[Figma](https://www.figma.com/)** - Professional design
5. **[Lucidchart](https://www.lucidchart.com/)** - Enterprise diagrams

### Icon Resources

- **[Font Awesome](https://fontawesome.com/icons)** - Web icons
- **[Material Design Icons](https://materialdesignicons.com/)** - Material icons
- **[Simple Icons](https://simpleicons.org/)** - Brand icons

---

## 📝 Contributing Diagrams

When adding new diagrams:

1. Create Mermaid source in this folder
2. Export high-quality PNG (2048px width minimum)
3. Add entry to this README
4. Reference in main documentation

---

**Last Updated**: 2026-03-04
**Maintainer**: Ruben Alvarez
