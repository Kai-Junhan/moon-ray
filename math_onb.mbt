///|
/// Orthonormal Basis (ONB) for importance sampling.
/// Used to transform vectors from tangent space to world space.

pub(all) struct ONB {
  u : Vec3
  v : Vec3
  w : Vec3
} derive(Debug)

pub fn ONB::build_from_w(normal~ : Vec3) -> ONB {
  let w = normal.normalize()
  let a = if w.x.abs() > 0.9 {
    { x: 0.0, y: 1.0, z: 0.0 }
  } else {
    { x: 1.0, y: 0.0, z: 0.0 }
  }
  let v = w.cross(a).normalize()
  let u = w.cross(v)
  { u, v, w }
}

pub fn ONB::local_vec(self : ONB, a : Double, b : Double, c : Double) -> Vec3 {
  self.u.mul_scalar(a) + self.v.mul_scalar(b) + self.w.mul_scalar(c)
}

pub fn ONB::to_world(self : ONB, local_vec : Vec3) -> Vec3 {
  self.u.mul_scalar(local_vec.x) + self.v.mul_scalar(local_vec.y) + self.w.mul_scalar(local_vec.z)
}
