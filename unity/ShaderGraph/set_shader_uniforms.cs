using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class set_shader_uniforms : MonoBehaviour
{
    private Vector4 mousePos;
    [SerializeField]
    public bool Gamma_Correct = false;
    [SerializeField]
    public float Resolution = 1;
    [SerializeField]
    public Texture MainTex;
    [SerializeField]
    public Vector3 rayOrigin = new Vector3(0,0,7);
    public enum NoiseType
    {
        None,
        FBM
    }

    public NoiseType noiseType = new NoiseType();

    void Start()
    {
    }

    void OnValidate()
    {
        Shader.SetGlobalFloat("_GammaCorrect", Gamma_Correct ? 1 : 0);
        Shader.SetGlobalTexture("_MainTex", MainTex);
        Shader.SetGlobalFloat("_Resolution", Resolution);
        Shader.SetGlobalVector("_RayOrigin", rayOrigin);
        Shader.SetGlobalFloat("_NoiseType", (int)noiseType);
    }

    // Update is called once per frame
    void Update()
    {
        if (Input.GetButton("Fire1"))
        {
            mousePos = Input.mousePosition;
            Shader.SetGlobalVector("_mousePoint", new Vector2(mousePos.x, mousePos.y));
            Shader.SetGlobalVector("_Mouse", new Vector2(mousePos.x, mousePos.y));
        }

    }
}
