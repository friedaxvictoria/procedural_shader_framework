# 🛠️ Engine Integration Overview

Welcome to the **Engine Integration Hub** — your guide to bringing our procedural shaders into real-time engines like **Unity**, **Unreal**, and **Godot**.

Each integration includes:
- Engine setup instructions
- Shader adaptation (GLSL → HLSL/GodotShader)
- Node setups or code breakdowns
- Visual demos and performance tips

---

> 🎨 Want to understand how shaders work under the hood?  
> 👉 [Go to Shader Library](../shaders/shaderPage.md)

---

## 🎮 Unity Integrations

Unity implementations use **Shader Graph** or custom HLSL in the **Universal Render Pipeline (URP)**.

| 🔧 Shader Name | 🧩 Integration Type | 🔗 Link |
|---------------|---------------------|--------|
| ✈️ TIE Fighter | Shader Graph         | [View Integration](unity/tie_fighter_unity.md) |
| *Coming Soon* | —                   | —      |

---

## 🎮 Unreal Engine Integrations

Unreal integrations are built using the **Material Editor**, with node-based logic and optional HLSL custom expressions.

| 🔧 Shader Name | 🧩 Integration Type | 🔗 Link |
|---------------|---------------------|--------|
| *Coming Soon* | —                   | —      |

---

## 🎮 Godot Engine Integrations

Godot integrations are implemented using **GodotShader Language** and `.gdshaderinc` includes, ideal for raymarching and procedural visuals.

| 🔧 Shader Name     | 🧩 Integration Type     | 🔗 Link |
|--------------------|-------------------------|--------|
| 🌀 Raymarching SDF | Godot Shader + Includes | [View Integration](godot/raymarching_sdf.md) |

---

## 🔄 Cross-Engine Notes

While shader logic is shared across engines, implementation details vary:

- **Unity** is best for modular visual editing via Shader Graph.
- **Unreal** offers tighter material performance tuning and post-process control.
- **Godot** excels with raw shader scripting and flexible custom pipelines.

Use the integration pages to compare techniques and results across platforms.

---


