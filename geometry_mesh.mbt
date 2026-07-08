///|
/// Mesh geometry from triangle collections.
/// Supports building from indexed vertex and face arrays.

pub(all) struct Mesh {
  vertices : Array[Vec3]
  indices : Array[(Int, Int, Int)]
  material : Material
} derive(Debug)

pub fn Mesh::new(material~ : Material) -> Mesh {
  {
    vertices: Array::new(capacity=1024),
    indices: Array::new(capacity=1024),
    material,
  }
}

pub fn Mesh::add_vertex(self : Mesh, v : Vec3) -> Mesh {
  let verts = self.vertices
  verts.push(v)
  { ..self, vertices: verts }
}

pub fn Mesh::add_triangle(self : Mesh, i0 : Int, i1 : Int, i2 : Int) -> Mesh {
  let idx = self.indices
  idx.push((i0, i1, i2))
  { ..self, indices: idx }
}

pub fn Mesh::build_cube(center~ : Vec3, size~ : Double, material~ : Material) -> Mesh {
  let half = size / 2.0
  let cx = center.x
  let cy = center.y
  let cz = center.z

  let verts = Array::new(capacity=8)
  verts.push({ x: cx - half, y: cy - half, z: cz - half })
  verts.push({ x: cx + half, y: cy - half, z: cz - half })
  verts.push({ x: cx - half, y: cy + half, z: cz - half })
  verts.push({ x: cx + half, y: cy + half, z: cz - half })
  verts.push({ x: cx - half, y: cy - half, z: cz + half })
  verts.push({ x: cx + half, y: cy - half, z: cz + half })
  verts.push({ x: cx - half, y: cy + half, z: cz + half })
  verts.push({ x: cx + half, y: cy + half, z: cz + half })

  let mut mesh = Mesh::new(material=material)
  for i in 0..<8 {
    mesh = mesh.add_vertex(verts[i])
  }

  let faces = Array::new(capacity=12)
  faces.push((0, 2, 3))
  faces.push((0, 3, 1))
  faces.push((4, 5, 7))
  faces.push((4, 7, 6))
  faces.push((0, 4, 6))
  faces.push((0, 6, 2))
  faces.push((1, 3, 7))
  faces.push((1, 7, 5))
  faces.push((0, 1, 5))
  faces.push((0, 5, 4))
  faces.push((2, 6, 7))
  faces.push((2, 7, 3))

  for i in 0..<12 {
    let (a, b, c) = faces[i]
    mesh = mesh.add_triangle(a, b, c)
  }

  mesh
}

pub fn Mesh::build_uv_sphere(center~ : Vec3, radius~ : Double, segments~ : Int, rings~ : Int, material~ : Material) -> Mesh {
  let mut mesh = Mesh::new(material=material)
  let seg = segments.max(3)
  let ring = rings.max(2)

  let vertices = Array::new(capacity=(seg + 1) * (ring + 1))
  for j in 0..=ring {
    let phi = @math.PI * j.to_double() / ring.to_double()
    for i in 0..=seg {
      let theta = 2.0 * @math.PI * i.to_double() / seg.to_double()
      let x = @math.cos(theta) * @math.sin(phi)
      let y = @math.cos(phi)
      let z = @math.sin(theta) * @math.sin(phi)
      vertices.push({ x: x * radius + center.x, y: y * radius + center.y, z: z * radius + center.z })
    }
  }

  for j in 0..<ring {
    for i in 0..<seg {
      let a = j * (seg + 1) + i
      let b = a + seg + 1
      let c = a + 1
      let d = b + 1

      mesh = mesh.add_vertex(vertices[a])
      mesh = mesh.add_vertex(vertices[b])
      mesh = mesh.add_vertex(vertices[c])
      mesh = mesh.add_triangle(a, b, c)

      mesh = mesh.add_vertex(vertices[c])
      mesh = mesh.add_vertex(vertices[b])
      mesh = mesh.add_vertex(vertices[d])
      mesh = mesh.add_triangle(c, b, d)
    }
  }

  mesh
}

pub fn mesh_to_hitable_list(mesh : Mesh) -> HitableList {
  let mut world = HitableList::new()
  for i in 0..<mesh.indices.length() {
    let (i0, i1, i2) = mesh.indices[i]
    let tri = Triangle::new(
      v0=mesh.vertices[i0],
      v1=mesh.vertices[i1],
      v2=mesh.vertices[i2],
      material=mesh.material,
    )
    world = world.add(Hitable::Triangle(tri))
  }
  world
}
