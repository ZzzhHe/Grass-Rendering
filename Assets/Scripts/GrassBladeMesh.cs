using UnityEngine;

public class GrassBladeMesh
{
    public static Mesh CreateGrassBladeMesh_LowLOD() {
        Mesh mesh = new Mesh();

        // Define vertices
        Vector3[] vertices = new Vector3[]{
            new Vector3(-0.125f, 0, 0),    // Vertex 0: Left base
            new Vector3(0.125f, 0, 0),     // Vertex 1: Right base
            new Vector3(-0.075f, 1f, 0), // Vertex 2: Second left
            new Vector3(0.075f, 1f, 0),  // Vertex 3: Second right
            new Vector3(-0.02f, 2f, 0),// Vertex 4: Third left
            new Vector3(0.2f, 2f, 0), // Vertex 5: Third right
            new Vector3(0, 3, 0)          // Vertex 6: Apex
        };

        // Define each triangle's indices
        int[] indices = new int[]{
            0, 1, 2,  // Triangle 1: Base to second level left
            1, 3, 2,  // Triangle 2: Base right to second level
            2, 3, 4,  // Triangle 3: Second level to third level left
            3, 5, 4,  // Triangle 4: Second right to third level
            4, 5, 6   // Triangle 5: Top triangle
        };

        // UVs for each vertex
        Vector2[] uvs = new Vector2[]{
            new Vector2(0, 0),
            new Vector2(1, 0),
            new Vector2(0, 0.33f),
            new Vector2(1, 0.33f),
            new Vector2(0, 0.66f),
            new Vector2(1, 0.66f),
            new Vector2(0.5f, 1)
        };

        mesh.vertices = vertices;
        mesh.triangles = indices;
        mesh.uv = uvs;

        mesh.RecalculateNormals();

        return mesh;
    }

    public static Mesh CreateGrassBladeMesh_HighLOD() {
        Mesh mesh = new Mesh();

        Vector3[] vertices = new Vector3[]{
            new Vector3(-0.125f, 0, 0),     // Vertex 0: Left base
            new Vector3(0.125f, 0, 0),      // Vertex 1: Right base
            new Vector3(-0.12f, 0.4f, 0),   // Vertex 2: First segment left
            new Vector3(0.12f, 0.4f, 0),    // Vertex 3: First segment right
            new Vector3(-0.1f, 0.8f, 0),    // Vertex 4: Second segment left
            new Vector3(0.1f, 0.8f, 0),     // Vertex 5: Second segment right
            new Vector3(-0.08f, 1.2f, 0),   // Vertex 6: Third segment left
            new Vector3(0.08f, 1.2f, 0),    // Vertex 7: Third segment right
            new Vector3(-0.06f, 1.6f, 0),   // Vertex 8: Fourth segment left
            new Vector3(0.06f, 1.6f, 0),    // Vertex 9: Fourth segment right
            new Vector3(-0.03f, 2f, 0),     // Vertex 10: Fifth segment left
            new Vector3(0.03f, 2f, 0),      // Vertex 11: Fifth segment right
            new Vector3(-0.015f, 2.5f, 0),  // Vertex 12: Near apex left
            new Vector3(0.015f, 2.5f, 0),   // Vertex 13: Near apex right
            new Vector3(0, 3f, 0)           // Vertex 14: Apex
        };

        int[] indices = new int[]{
            0, 2, 1,   // Triangle 1
            1, 2, 3,   // Triangle 2
            2, 4, 3,   // Triangle 3
            3, 4, 5,   // Triangle 4
            4, 6, 5,   // Triangle 5
            5, 6, 7,   // Triangle 6
            6, 8, 7,   // Triangle 7
            7, 8, 9,   // Triangle 8
            8, 10, 9,  // Triangle 9
            9, 10, 11, // Triangle 10
            10, 12, 11, // Triangle 11
            11, 12, 13, // Triangle 12
            12, 14, 13  // Triangle 13
        };

        Vector2[] uvs = new Vector2[]{
            new Vector2(0, 0),        // Vertex 0: Left base
            new Vector2(1, 0),        // Vertex 1: Right base
            new Vector2(0, 0.1333f),  // Vertex 2: First segment left
            new Vector2(1, 0.1333f),  // Vertex 3: First segment right
            new Vector2(0, 0.2666f),  // Vertex 4: Second segment left
            new Vector2(1, 0.2666f),  // Vertex 5: Second segment right
            new Vector2(0, 0.4f),      // Vertex 6: Third segment left
            new Vector2(1, 0.4f),      // Vertex 7: Third segment right
            new Vector2(0, 0.5333f),  // Vertex 8: Fourth segment left
            new Vector2(1, 0.5333f),  // Vertex 9: Fourth segment right
            new Vector2(0, 0.6666f),  // Vertex 10: Fifth segment left
            new Vector2(1, 0.6666f),  // Vertex 11: Fifth segment right
            new Vector2(0, 0.8333f),  // Vertex 12: Near apex left
            new Vector2(1, 0.8333f),  // Vertex 13: Near apex right
            new Vector2(0.5f, 1)      // Vertex 14: Apex
        };

        mesh.vertices = vertices;
        mesh.triangles = indices;
        mesh.uv = uvs;

        mesh.RecalculateNormals();

        return mesh;
    }
}
