///|
/// Disk geometry (flat circular disk).

pub(all) struct Disk {
  center : Vec3
  normal : Vec3
  radius : Double
  material : Material
} derive(Debug)

pub fn Disk::new(center~ : Vec3, normal~ : Vec3, radius~ : Double, material~ : Material) -> Disk {
  { center, normal: normal.normalize(), radius, material }
}

pub fn Disk::hit_disk(self : Disk, r : Ray, t_min~ : Double, t_max~ : Double) -> HitRecord? {
  let denom = self.normal.dot(r.dir)
  if denom.abs() < 1.0e-8 {
    return None
  }
  let t = (self.center - r.orig).dot(self.normal) / denom
  if t < t_min || t > t_max {
    return None
  }
  let p = r.at(t)
  if (p - self.center).length_squared() > self.radius * self.radius {
    return None
  }
  let outward_normal = self.normal
  let rec = { p, normal: outward_normal, t, front_face: false, material: self.material }
  Some(rec.set_face_normal(r, outward_normal))
}
