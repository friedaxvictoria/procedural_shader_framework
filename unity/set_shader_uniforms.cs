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

    int numSDFs = 0;
    Vector4[] positions = new Vector4[10];
    Vector4[] sizes = new Vector4[10];
    float[] radii = new float[10];
    float[] types = new float[10];


    void addSphere(Vector3 position, float radius)
    {
        positions[numSDFs] = new Vector4(position.x, position.y, position.z, 1);
        sizes[numSDFs] = new Vector4(0, 0, 0, 1);
        radii[numSDFs] = radius;
        types[numSDFs] = 0;
        numSDFs++;
    }

    void addCube(Vector3 position, Vector3 size, float radius)
    {
        positions[numSDFs] = (new Vector4(position.x, position.y, position.z, 1));
        sizes[numSDFs] = (new Vector4(size.x, size.y, size.z, 1));
        radii[numSDFs] = (radius);
        types[numSDFs] = (1);
        numSDFs++;
    }

    void addTorus(Vector3 position, Vector3 size)
    {
        positions[numSDFs] = (new Vector4(position.x, position.y, position.z, 1));
        sizes[numSDFs] = (new Vector4(size.x, size.y, size.z, 1));
        radii[numSDFs] = (0);
        types[numSDFs] = (2);
        numSDFs++;
    }

    void Start()
    {
        addSphere(new Vector3(0, 0, 0), 1);
        //addCube(new Vector3(1.9f, 0, 0), new Vector3(1, 1, 1), 0.2f);
        //addCube(new Vector3(-1.9f, 0, 0), new Vector3(1, 1, 1), 0.2f);
        addTorus(new Vector3(-1.9f, 0, 0), new Vector3(1, 3, .5f));
        addTorus(new Vector3(1.9f, 0, 0), new Vector3(1, 3, .5f));


        Shader.SetGlobalVectorArray("_sdfPosition", positions);
        Shader.SetGlobalVectorArray("_sdfSize", sizes);
        Shader.SetGlobalFloatArray("_sdfRadius", radii);
        Shader.SetGlobalFloatArray("_sdfType", types);
    }

    void OnValidate()
    {
        Shader.SetGlobalFloat("_GammaCorrect", Gamma_Correct ? 1 : 0);
        Shader.SetGlobalTexture("_MainTex", MainTex);
        Shader.SetGlobalFloat("_Resolution", Resolution);
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
