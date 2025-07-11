using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class set_shader_uniforms : MonoBehaviour
{
    private Vector4 mousePos;

    void Start()
    {
    }

    void OnValidate()
    {
        //Shader.SetGlobalFloat("_GammaCorrect", Gamma_Correct ? 1 : 0);
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
