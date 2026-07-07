///|
/// Ray representation: origin + t * direction.

pub(all) struct Ray {
  orig : Vec3
  dir : Vec3
  tm : Double
} derive(Debug)

pub fn Ray::new(orig~ : Vec3 = { x: 0.0, y: 0.0, z: 0.0 }, dir~ : Vec3 = { x: 0.0, y: 0.0, z: 1.0 }, tm~ : Double = 0.0) -> Ray {
  { orig, dir, tm }
}

/// Get point along the ray at parameter t.
pub fn Ray::at(self : Ray, t : Double) -> Vec3 {
  self.orig + self.dir.mul_scalar(t)
}
