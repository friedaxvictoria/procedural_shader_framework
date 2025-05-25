using UnityEngine;
using UnityEngine.UI;

public class ComputeShaderTest : MonoBehaviour
{

    public ComputeShader computeShader;
    public RawImage renderUImage;

    public RenderTexture renderTexture;


    void Start()
    {
        renderTexture = new RenderTexture(256, 256, 24);
        renderTexture.enableRandomWrite = true;
        renderTexture.Create();

        computeShader.SetTexture(/*computeShader.FindKernel("CSMain")*/ 0, "Result", renderTexture);
        computeShader.SetFloat("resolutionX", renderTexture.width);
        computeShader.SetFloat("_Time", Time.time);
        computeShader.Dispatch(0, renderTexture.width / 8, renderTexture.height / 8, 1);
    }

    private void Update()
    {
        computeShader.SetTexture(/*computeShader.FindKernel("CSMain")*/ 0, "Result", renderTexture);
        computeShader.SetFloat("_Time", Time.time);
        computeShader.Dispatch(0, renderTexture.width / 8, renderTexture.height / 8, 1);
        renderUImage.texture = renderTexture;
    }

}
