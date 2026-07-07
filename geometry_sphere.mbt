///|
/// Sphere geometry.

pub(all) struct Sphere {
  center : Vec3
  radius : Double
  material : Material
} derive(Debug)

pub fn Sphere::new(center~ : Vec3, radius~ : Double, material~ : Material) -> Sphere {
  { center, radius, material }
}
