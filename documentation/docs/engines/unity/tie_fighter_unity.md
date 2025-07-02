# 🎮 TIE Fighter Shader – Unity Integration

- **Engine:** Unity (URP)
- **Shader Source:** [shaders/animation/tie_fighter.md](../../shaders/animation/tie_fighter.md)
- **Integration Type:** Shader Graph (Visual Node Setup)
- **Integrated By:** Mr. ABC

---

## ⚙️ Setup Overview

This shader simulates a looping flight animation using sinusoidal math. To integrate it in Unity:

1. Use **Shader Graph** with **Time** and **Math** nodes.
2. Create a **Material** using this shader.
3. Apply it to a quad, mesh, or post-process object.

---

## 🧩 Shader Graph Overview

### Main Concepts:
- Use `_Time.y` or custom time variable `T` (looping)
- Apply sine and cosine math for motion
- Optional: vertex displacement or UV distortion

### Nodes to Use:
- Time
- Multiply / Add / Sine / Cosine
- Vector Math
- (Optional) Custom Function node for `tiePos()`

---

## 🖼️ Visual Setup

(to add photo and video, look into the shader_template file under `docs/shader/` directory....)