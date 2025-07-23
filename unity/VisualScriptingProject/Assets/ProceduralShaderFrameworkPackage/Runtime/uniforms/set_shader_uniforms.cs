using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class set_shader_uniforms : MonoBehaviour
{
    private Vector2 lastMousePos;
    private Vector2 accumulatedMouseDelta = new Vector2(Screen.width * 0.5f, Screen.height * 0.5f);
    private bool isDragging = false;

    [Header("Ray Origin Movement")]
    public bool allowMovement = false;
    public float movementSpeed = 10f;
    public Vector3 rayOrigin = new Vector3(0, 0, 10);

    void Start()
    {
        Shader.SetGlobalVector("_rayOrigin", rayOrigin);
        Shader.SetGlobalFloat("_raymarchStoppingCriterium", 50);

        Shader.SetGlobalVector("_mousePoint", accumulatedMouseDelta);
        Shader.SetGlobalVector("_Mouse", accumulatedMouseDelta);
    }

    void onValidate()
    {
        Shader.SetGlobalVector("_rayOrigin", rayOrigin);
    }

    void Update()
    {
        if (!allowMovement)
        {
            Shader.SetGlobalVector("_mousePoint", accumulatedMouseDelta);
            Shader.SetGlobalVector("_Mouse", accumulatedMouseDelta);
        }

        // --- Mouse drag rotation ---
        if (Input.GetMouseButtonDown(0))
        {
            lastMousePos = Input.mousePosition;
            isDragging = true;
        }
        else if (Input.GetMouseButtonUp(0))
        {
            isDragging = false;
        }

        if (isDragging)
        {
            Vector2 currentMousePos = Input.mousePosition;
            Vector2 delta = currentMousePos - lastMousePos;
            lastMousePos = currentMousePos;

            // Accumulate and normalize
            accumulatedMouseDelta += delta;


            Shader.SetGlobalVector("_mousePoint", accumulatedMouseDelta);
            Shader.SetGlobalVector("_Mouse", accumulatedMouseDelta);
        }

        Vector3 direction = Vector3.zero;

        if (Input.GetKey(KeyCode.S)) direction += Vector3.forward;
        if (Input.GetKey(KeyCode.W)) direction += Vector3.back;
        if (Input.GetKey(KeyCode.A)) direction += Vector3.left;
        if (Input.GetKey(KeyCode.D)) direction += Vector3.right;
        if (Input.GetKey(KeyCode.E)) direction += Vector3.up;
        if (Input.GetKey(KeyCode.Q)) direction += Vector3.down;

        if (direction != Vector3.zero)
        {
            if (Input.GetKey(KeyCode.LeftShift))
            {
                direction *= 2;
            }
            rayOrigin += direction * movementSpeed * Time.deltaTime;
        }

        Shader.SetGlobalVector("_rayOrigin", rayOrigin);
    }
}