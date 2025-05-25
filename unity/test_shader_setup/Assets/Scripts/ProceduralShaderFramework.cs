using UnityEngine;
using UnityEditor;
using System.Collections.Generic;

// [ExecuteAlways]  // works in Editor without Play mode (optional)
public class ProceduralShaderFramework : MonoBehaviour
{
    public bool updateShader = false;

    public enum NoiseType { None, SimpleNoise, PerlinNoise }
    public enum LightingType { None, BasicLighting, ToonLighting }
    public enum GeometryType { None, Ripple, Twist }
    public enum AnimationType { None, PulsatingColor, WigglingVertices }


    [Header("Shader Parts")]
    public NoiseType noiseType = NoiseType.None;
    public LightingType lightingType = LightingType.None;
    public GeometryType geometryType = GeometryType.None;
    public AnimationType animationType = AnimationType.None;

    public Shader defaultShader;

    [Header("Noise Shaders")]
    public Shader simpleNoiseShader;
    public Shader perlinNoiseShader;

    [Header("Lighting Shaders")]
    public Shader basicLightingShader;
    public Shader toonLightingShader;

    [Header("Geometry Shaders")]
    public Shader rippleGeometryShader;
    public Shader twistGeometryShader;

    [Header("Animation Shaders")]
    public Shader pulsatingColorShader;
    public Shader wigglingVerticesShader;

    [Header("Complete Shaders")]
    public List<CompleteShaderEntry> completeShaders = new List<CompleteShaderEntry>();

    [System.Serializable]
    public class CompleteShaderEntry
    {
        public Shader shader;
        public bool use;
    }

    private Renderer rend;

    private void OnValidate()
    {
        if (updateShader)
        {
            updateShader = false;
            UpdateShader();
        }
    }

    void Awake()
    {
        rend = GetComponent<Renderer>();
    }

    void Start()
    {
        UpdateShader();
    }

    public void UpdateShader()
    {
        if (rend == null)
            rend = GetComponent<Renderer>();

        Shader selectedShader = null;

        // Check complete shaders
        foreach (var entry in completeShaders)
        {
            if (entry.use)
            {
                selectedShader = entry.shader;
                break;
            }
        }

        // Fallback to part shaders
        if (selectedShader == null)
        {
            if (noiseType != NoiseType.None)
                selectedShader = GetNoiseShader(noiseType);
            else if (lightingType != LightingType.None)
                selectedShader = GetLightingShader(lightingType);
            else if (geometryType != GeometryType.None)
                selectedShader = GetGeometryShader(geometryType);
            else if (animationType != AnimationType.None)
                selectedShader = GetAnimationShader(animationType);
        }

        if (selectedShader != null)
        {
            rend.sharedMaterial.shader = selectedShader;  // use sharedMaterial in editor
        }
        else
        {
            Debug.Log("No valid shader selected.");
            rend.sharedMaterial.shader = defaultShader;  // use sharedMaterial in editor
        }
    }

    Shader GetNoiseShader(NoiseType type)
    {
        switch (type)
        {
            case NoiseType.SimpleNoise: return simpleNoiseShader;
            case NoiseType.PerlinNoise: return perlinNoiseShader;
            default: return null;
        }
    }

    Shader GetLightingShader(LightingType type)
    {
        switch (type)
        {
            case LightingType.BasicLighting: return basicLightingShader;
            case LightingType.ToonLighting: return toonLightingShader;
            default: return null;
        }
    }

    Shader GetGeometryShader(GeometryType type)
    {
        switch (type)
        {
            case GeometryType.Ripple: return rippleGeometryShader;
            case GeometryType.Twist: return twistGeometryShader;
            default: return null;
        }
    }

    Shader GetAnimationShader(AnimationType type)
    {
        switch (type)
        {
            case AnimationType.PulsatingColor: return pulsatingColorShader;
            case AnimationType.WigglingVertices: return wigglingVerticesShader;
            default: return null;
        }
    }
}