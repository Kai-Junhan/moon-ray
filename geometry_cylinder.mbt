///|
/// Cylinder geometry aligned along the Y-axis.

pub(all) struct Cylinder {
  center : Vec3
  radius : Double
  height : Double
  material : Material
} derive(Debug)

pub fn Cylinder::new(center~ : Vec3, radius~ : Double, height~ : Double, material~ : Material) -> Cylinder {
  { center, radius, height, material }
}

pub fn Cylinder::hit_cylinder(self : Cylinder, r : Ray, t_min~ : Double, t_max~ : Double) -> HitRecord? {
  let half_h = self.height / 2.0
  let y_min = self.center.y - half_h
  let y_max = self.center.y + half_h

  let a = r.dir.x * r.dir.x + r.dir.z * r.dir.z
  if a.abs() < 1.0e-8 {
    return None
  }

  let oc = { x: r.orig.x - self.center.x, y: 0.0, z: r.orig.z - self.center.z }
  let half_b = r.dir.x * oc.x + r.dir.z * oc.z
  let c = oc.x * oc.x + oc.z * oc.z - self.radius * self.radius
  let discriminant = half_b * half_b - a * c

  if discriminant < 0.0 {
    return None
  }

  let sqrtd = discriminant.sqrt()
  let mut t = (-half_b - sqrtd) / a
  let mut y_at_t = r.orig.y + t * r.dir.y

  let mut hit = false
  if t >= t_min && t <= t_max && y_at_t >= y_min && y_at_t <= y_max {
    hit = true
  } else {
    t = (-half_b + sqrtd) / a
    y_at_t = r.orig.y + t * r.dir.y
    if t >= t_min && t <= t_max && y_at_t >= y_min && y_at_t <= y_max {
      hit = true
    }
  }

  if !hit {
    return None
  }

  let p = r.at(t)
  let outward_normal = { x: (p.x - self.center.x) / self.radius, y: 0.0, z: (p.z - self.center.z) / self.radius }
  let rec = { p, normal: outward_normal, t, front_face: false, material: self.material }
  Some(rec.set_face_normal(r, outward_normal))
}
