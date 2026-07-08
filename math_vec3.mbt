///|
/// 3D vector math operations for ray tracing.

pub(all) struct Vec3 {
  x : Double
  y : Double
  z : Double
} derive(Debug)

pub fn Vec3::new(x~ : Double, y~ : Double, z~ : Double) -> Vec3 {
  { x, y, z }
}

///|
/// Arithmetic trait implementations

impl Add for Vec3 with add(self : Vec3, other : Vec3) -> Vec3 {
  { x: self.x + other.x, y: self.y + other.y, z: self.z + other.z }
}

impl Sub for Vec3 with sub(self : Vec3, other : Vec3) -> Vec3 {
  { x: self.x - other.x, y: self.y - other.y, z: self.z - other.z }
}

impl Mul for Vec3 with mul(self : Vec3, other : Vec3) -> Vec3 {
  { x: self.x * other.x, y: self.y * other.y, z: self.z * other.z }
}

impl Neg for Vec3 with neg(self : Vec3) -> Vec3 {
  { x: -self.x, y: -self.y, z: -self.z }
}

///|
/// Scalar operations

pub fn Vec3::mul_scalar(self : Vec3, t : Double) -> Vec3 {
  { x: self.x * t, y: self.y * t, z: self.z * t }
}

pub fn Vec3::div_scalar(self : Vec3, t : Double) -> Vec3 {
  { x: self.x / t, y: self.y / t, z: self.z / t }
}

///|
/// Vector operations

pub fn Vec3::dot(self : Vec3, other : Vec3) -> Double {
  self.x * other.x + self.y * other.y + self.z * other.z
}

pub fn Vec3::cross(self : Vec3, other : Vec3) -> Vec3 {
  { x: self.y * other.z - self.z * other.y,
    y: self.z * other.x - self.x * other.z,
    z: self.x * other.y - self.y * other.x }
}

pub fn Vec3::length(self : Vec3) -> Double {
  self.length_squared().sqrt()
}

pub fn Vec3::length_squared(self : Vec3) -> Double {
  self.x * self.x + self.y * self.y + self.z * self.z
}

pub fn Vec3::normalize(self : Vec3) -> Vec3 {
  let len = self.length()
  if len > 0.0 {
    self.div_scalar(len)
  } else {
    self
  }
}

///|
/// Utility functions

/// Reflect vector v around normal n.
pub fn reflect(v : Vec3, n : Vec3) -> Vec3 {
  v - n.mul_scalar(2.0 * v.dot(n))
}

/// Refract vector uv through surface with normal n and etai_over_etat ratio.
pub fn refract(uv : Vec3, n : Vec3, etai_over_etat : Double) -> Vec3? {
  let cos_theta = (-uv).dot(n).min(1.0)
  let r_out_perp = (uv + n.mul_scalar(cos_theta)).mul_scalar(etai_over_etat)
  let r_out_parallel = n.mul_scalar(-(1.0 - r_out_perp.length_squared()).abs().sqrt())
  Some(r_out_perp + r_out_parallel)
}

pub fn Vec3::near_zero(self : Vec3) -> Bool {
  let s = 1.0e-8
  self.x.abs() < s && self.y.abs() < s && self.z.abs() < s
}

/// Component-wise minimum
pub fn Vec3::min(self : Vec3, other : Vec3) -> Vec3 {
  { x: if self.x < other.x { self.x } else { other.x },
    y: if self.y < other.y { self.y } else { other.y },
    z: if self.z < other.z { self.z } else { other.z } }
}

/// Component-wise maximum
pub fn Vec3::max(self : Vec3, other : Vec3) -> Vec3 {
  { x: if self.x > other.x { self.x } else { other.x },
    y: if self.y > other.y { self.y } else { other.y },
    z: if self.z > other.z { self.z } else { other.z } }
}

/// Linear interpolation
pub fn Vec3::lerp(self : Vec3, other : Vec3, t : Double) -> Vec3 {
  self.mul_scalar(1.0 - t) + other.mul_scalar(t)
}
