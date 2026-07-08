///|
/// Plane geometry: infinite plane defined by center point and normal.

pub(all) struct Plane {
  center : Vec3
  normal : Vec3
  material : Material
} derive(Debug)

pub fn Plane::new(center~ : Vec3, normal~ : Vec3, material~ : Material) -> Plane {
  { center, normal: normal.normalize(), material }
}

pub fn Plane::hit_plane(self : Plane, r : Ray, t_min~ : Double, t_max~ : Double) -> HitRecord? {
  let denom = self.normal.dot(r.dir)
  if denom.abs() < 1.0e-8 {
    return None
  }
  let t = (self.center - r.orig).dot(self.normal) / denom
  if t < t_min || t > t_max {
    return None
  }
  let p = r.at(t)
  let outward_normal = self.normal
  let rec = { p, normal: outward_normal, t, front_face: false, material: self.material }
  Some(rec.set_face_normal(r, outward_normal))
}
