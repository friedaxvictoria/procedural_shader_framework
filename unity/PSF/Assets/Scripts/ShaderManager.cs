using UnityEngine;

public class ShaderManager : MonoBehaviour
{
    public Shader customShader;
    private Material materialInstance;

    // [Header("Shader Parameters")]
    // public Color customColor = Color.white; // Select shader color

    void Start()
    {
        if (customShader != null)
        {
            materialInstance = new Material(customShader);
            GetComponent<Renderer>().material = materialInstance;
        }
    }

    void Update()
    {
        if (materialInstance != null)
        {
            float time = Time.time;
            //materialInstance.SetFloat("_TimeValue", time);
            //materialInstance.SetColor("_Color", customColor);
            materialInstance.SetVector("_iResolution", new Vector3(Screen.width, Screen.height, 0));
            materialInstance.SetFloat("_iTime", Time.time);


        }
    }
}