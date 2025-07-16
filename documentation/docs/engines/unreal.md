# 🎮 Unreal Engine Shader Integrations

Unreal implementations are built using the **Material Editor**, with node-based logic and optional HLSL custom expressions.

Unreal Engine is a high-fidelity engine used in AAA games and cinematic visuals. It supports complex materials via the **Material Editor** and HLSL expressions.

---

### 🧠 Engine Overview

- **Rendering Pipeline:** Forward+ / Deferred / Lumen  
- **Shader Language:** HLSL (via Material Expressions)  
- **Integration Method:** Material Editor + Custom Nodes  
- **Ideal For:** Photorealism, cinematic FX, AAA games  
- **Real-Time Preview:** ✅ Yes  
- **Visual Editing:** ✅ Highly advanced material graph  

> Unreal’s powerful editor is ideal for performance-heavy and cinematic procedural shaders.

---

!!! info "🎨 Explore All Shaders in This Engine"

    Want to see all procedural shaders adapted for this engine?

    🧠 Get full access to:
    
    - Shader logic and breakdowns  
    - Code previews with syntax highlighting  
    - Demos, GIFs, and video walkthroughs

    👉 **[Browse Shader Gallery →](../shaders/shaderPage.md)**

---

## 🔧 Integration List

| Shader Name | Integration Type | Link |
|-------------|------------------|------|
| *More coming soon* | — | — |

---

## 📌 Notes
- Use **Material Function** assets for modularity.
- Supports Post-Process Materials.
- Good for performance-tuned projects.

---

## 🧠 Material Graph Logic

- Time input (from Blueprint or `Time` node)
- Use `Sine`, `Cosine`, `Add`, `Multiply` nodes
- Material Function to encapsulate `tiePos()` logic