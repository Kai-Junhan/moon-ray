///|
/// Triangle geometry using Moller-Trumbore intersection.

pub(all) struct Triangle {
  v0 : Vec3
  v1 : Vec3
  v2 : Vec3
  material : Material
} derive(Debug)

pub fn Triangle::new(v0~ : Vec3, v1~ : Vec3, v2~ : Vec3, material~ : Material) -> Triangle {
  { v0, v1, v2, material }
}

pub fn Triangle::hit_triangle(self : Triangle, r : Ray, t_min~ : Double, t_max~ : Double) -> HitRecord? {
  let edge1 = self.v1 - self.v0
  let edge2 = self.v2 - self.v0
  let h = r.dir.cross(edge2)
  let a = edge1.dot(h)

  if a.abs() < 1.0e-8 {
    return None
  }

  let f = 1.0 / a
  let s = r.orig - self.v0
  let u = f * s.dot(h)

  if u < 0.0 || u > 1.0 {
    return None
  }

  let q = s.cross(edge1)
  let v = f * r.dir.dot(q)

  if v < 0.0 || u + v > 1.0 {
    return None
  }

  let t = f * edge2.dot(q)

  if t <= t_min || t >= t_max {
    return None
  }

  let outward_normal = edge1.cross(edge2).normalize()
  let p = r.at(t)
  let rec = { p, normal: outward_normal, t, front_face: false, material: self.material }
  Some(rec.set_face_normal(r, outward_normal))
}
