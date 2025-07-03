
---
# Project Documentation Structure

## Directory Layout

```
docs/
├── index.md                 → Main landing page
├── shaders/                    → Shader library
│   ├── shaderPage.md           → (hidden) overview for all shaders
│   ├── animation/
│   │   └── tie_fighter.md      → Example animation shader
│   ├── geometry/
│   │   └── raymarching_sdf.md  → Example geometry shader
│   └── shader_template.md      → Template for all shader entries
│
├── engines/                    → Engine integration section
│   ├── unity/
│   │   └── tie_fighter_unity.md
│   ├── godot/
│   │   └── raymarching_sdf.md
│   ├── unreal/
│   │   └── (future entries)
│   └── engine_template.md      → Template for engine integration docs
│
├── static/
│   ├── images/                 → GIFs / screenshots
│   └── videos/                 → Preview videos
│
└── mkdocs.yml                  → MkDocs config (site navigation)
```

## Overview

This documentation site is organized into several main sections:

### 📄 Core Pages
- **index.md** - Main landing page and project introduction

### 🎨 Shader Library (`shaders/`)
- **animation/** - Movement and animated effects
- **geometry/** - Geometric transformations and rendering techniques, and we can add similar sub structure line, Noise/ .....
- **shader_template.md** - Standardized template for all shader entries

### 🎮 Engine Integration (`engines/`)
- **unity/** - Unity-specific implementations
- **godot/** - Godot engine examples
- **unreal/** - Unreal Engine integration (planned)
- **engine_template.md** - Template for engine-specific documentation

### 📁 Static Assets (`static/`)
- **images/** - Screenshots, GIFs, and visual examples
- **videos/** - Preview videos and demonstrations

### ⚙️ Configuration
- **mkdocs.yml** - Site navigation and build configuration
---

## ✏️ How to Contribute

### 🔷 For Shader Team

> 📁 `docs/shaders/`

1. Duplicate `shader_template.md`.
2. Fill in:
   - ✅ Description of the shader
   - 🧠 Algorithm explanation
   - 💻 GLSL or HLSL code in fenced block
   - 🎞️ Visual previews (GIF or image)
3. Save in the appropriate subfolder: `animation/`, `geometry/`, etc.
4. Link it inside `shaderPage.md`.

---

### 🧩 For Engine Team

> 📁 `docs/engines/`

1. Duplicate `engine_template.md`.
2. Fill in:
   - 🛠️ Engine name + version
   - 🧩 Integration type (Shader Graph, Material Editor, etc.)
   - 📜 Code snippets or node diagrams
   - 📷 Visual preview (image or video)
3. Save inside the right folder: `unity/`, `godot/`, `unreal/`.
4. Link it from the engine's markdown file (`unity.md`, `godot.md`, etc.)

---

## ✅ Notes

- Use relative links for media stored under `static/`
- Always wrap shader code with triple backticks and specify the language (e.g., `glsl`)
- Keep filenames and paths lowercase and hyphenated (no spaces)
