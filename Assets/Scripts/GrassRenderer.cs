using UnityEngine;

struct GrassBlade {
    public Vector3 position;
    public Vector3 scale;
    public Vector3 rotation;
}

public class GrassRenderer : MonoBehaviour
{
    public ComputeShader computeShader;
    public Material grassMaterial;
    [SerializeField] private int gridSize;
    [SerializeField] private float bladeWidth = 1/8f;
    [SerializeField] private float bladeHeight = 1.0f;
    
    private int grassBladesNum;
    private ComputeBuffer grassBladeBuffer;
    private GrassBlade[] grassBladeData;
    private Matrix4x4[] grassBladeLocationMatrixs;
    RenderParams grassRenderParams;
    private Mesh grassBladeMesh;
    

    void Start()
    {
        gridSize = 80;
        grassBladesNum = gridSize * gridSize;
        grassBladeMesh = GrassBladeMesh.CreateGrassBladeMesh();
        grassBladeData = new GrassBlade[grassBladesNum];
        grassBladeBuffer = new ComputeBuffer(grassBladesNum, sizeof(float) * 9);
        computeShader.SetBuffer(0, "grassBlades", grassBladeBuffer);

        int threadGroups = Mathf.CeilToInt(grassBladesNum / 128f);
        computeShader.Dispatch(0, threadGroups, 1, 1);
        grassBladeBuffer.GetData(grassBladeData);

        grassRenderParams = new RenderParams(grassMaterial);

        grassBladeLocationMatrixs = new Matrix4x4[grassBladesNum];

        for (int i = 0; i < grassBladesNum; i ++) {
            grassBladeLocationMatrixs[i]  = Matrix4x4.TRS(grassBladeData[i].position, Quaternion.Euler(grassBladeData[i].rotation), grassBladeData[i].scale);
        }
    }

    void Update()
    {
        Graphics.RenderMeshInstanced(grassRenderParams, grassBladeMesh, 0, grassBladeLocationMatrixs);
    }

    void OnDestroy()
    {
        if (grassBladeBuffer != null) {
            grassBladeBuffer.Release();
            grassBladeBuffer = null;
        }
    }
}
