using UnityEngine;

struct GrassBlade {
    public Vector3 position;
    public Vector3 scale;
    public Vector3 rotation;
}

public class GrassRenderer : MonoBehaviour
{
    public Camera mainCamera;
    public ComputeShader computeShader;
    public Material grassMaterial;
    [SerializeField] private int gridSize = 80;
    [SerializeField] private float cellSize = 0.16f;
    [SerializeField] private float bladeSize = 1.0f;    
    private int grassBladesNum;
    private ComputeBuffer grassBladeBuffer;
    private GrassBlade[] grassBladeData;
    private Matrix4x4[] grassBladeMatrixs;
    RenderParams grassRenderParams;
    private Mesh grassBladeMesh_lowLOD;
    private Mesh grassBladeMesh_highLOD;
    // TODO: implement the LOD system depends on the distance from the camera
    private Matrix4x4[] grassBladeMatrixs_lowLOD, grassBladeMatrixs_hightHOD;
    private int highLODCounter, lowLODCounter;

    void Start()
    {
        grassBladesNum = gridSize * gridSize;
        
        grassBladeMesh_lowLOD = GrassBladeMesh.CreateGrassBladeMesh_LowLOD();
        grassBladeMesh_highLOD = GrassBladeMesh.CreateGrassBladeMesh_HighLOD();

        grassBladeData = new GrassBlade[grassBladesNum];
        grassBladeBuffer = new ComputeBuffer(grassBladesNum, sizeof(float) * 9);
        computeShader.SetBuffer(0, "grassBlades", grassBladeBuffer);
        computeShader.SetInt("GridSize", gridSize);
        computeShader.SetFloat("CellSize", cellSize);

        int threadGroups = Mathf.CeilToInt(grassBladesNum / 128f);
        computeShader.Dispatch(0, threadGroups, 1, 1);
        grassBladeBuffer.GetData(grassBladeData);

        grassRenderParams = new RenderParams(grassMaterial);

        grassBladeMatrixs = new Matrix4x4[grassBladesNum];
    }

    void Update()
    {
        for (int i = 0; i < grassBladesNum; i ++) {
            grassBladeMatrixs[i]  = Matrix4x4.TRS(grassBladeData[i].position, Quaternion.Euler(grassBladeData[i].rotation), grassBladeData[i].scale * bladeSize);
        }
        Graphics.RenderMeshInstanced(grassRenderParams, grassBladeMesh_highLOD, 0, grassBladeMatrixs);
    }

    void OnDestroy()
    {
        if (grassBladeBuffer != null) {
            grassBladeBuffer.Release();
            grassBladeBuffer = null;
        }
    }
}
