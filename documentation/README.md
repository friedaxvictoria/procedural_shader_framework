
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
│   ├── godot.md               →  Godot integration hub
│   ├── unity.md               →  Unity integration hub
│   ├── unreal.md               →  Unreal integration hub
│   ├── unity/
│   │   └── tie_fighter_unity.md
│   ├── godot/
│   │   └── raymarching_sdf.md
│   ├── unreal/
│   │   └── (future entries)
│   └── engine_template.md      → Template for engine integration docs to follw 
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
- **geometry/** - Geometric transformations and rendering techniques, and we can add similar sub structure like, noise/ ..... for their specific 
- **shader_template.md** - Standardized template for all shader entries, for the code snippets to be added into the corresponding shader page, I have included both way, 
                           directly including in the page or either add a link to the github repo. 

### 🎮 Engine Integration (`engines/`)
- **unity/** - folder to put Unity-specific implementations
- **godot/** - folder to put Godot-specific implementations
- **unreal/** - folder to put Unreal-specific implementations
- **engine_template.md** - Template for engine-specific documentation
- **godot.md** -- landing page for godot details
- **unity.md** -- landing page for unity details
- **unreal.md** -- landing page for unreal details

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
