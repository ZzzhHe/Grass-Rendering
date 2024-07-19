using UnityEngine;

public class GrassBladeMesh
{
    public static Mesh CreateGrassBladeMesh() {
        Mesh mesh = new Mesh();

        // Define vertices
        Vector3[] vertices = new Vector3[]{
            new Vector3(-1/8f, 0, 0),    // Vertex 0: Left base
            new Vector3(1/8f, 0, 0),     // Vertex 1: Right base
            new Vector3(-1/12f, 1/3f, 0), // Vertex 2: Second left
            new Vector3(1/12f, 1/3f, 0),  // Vertex 3: Second right
            new Vector3(-1/24f, 2/3f, 0),// Vertex 4: Third left
            new Vector3(1/24f, 2/3f, 0), // Vertex 5: Third right
            new Vector3(0, 1, 0)          // Vertex 6: Apex
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
}
