
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
"""

readme_path = "/mnt/data/README.md"
with open(readme_path, "w") as f:
    f.write(readme_content)

readme_path
