///|
/// Cone geometry tapered along the Y-axis.
/// Defined by base center, base radius, apex point (tip), and height.

pub(all) struct Cone {
  base_center : Vec3
  base_radius : Double
  apex : Vec3
  height : Double
  material : Material
} derive(Debug)

pub fn Cone::new(base_center~ : Vec3, base_radius~ : Double, height~ : Double, material~ : Material) -> Cone {
  let apex = { x: base_center.x, y: base_center.y + height, z: base_center.z }
  { base_center, base_radius, apex, height, material }
}

pub fn Cone::hit_cone(self : Cone, r : Ray, t_min~ : Double, t_max~ : Double) -> HitRecord? {
  let direction = { x: 0.0, y: 1.0, z: 0.0 }
  let apex = self.apex
  let base = self.base_center
  let r_cone = self.base_radius
  let h_cone = self.height

  let cos_a2 = h_cone * h_cone / (h_cone * h_cone + r_cone * r_cone)
  let v = direction
  let w = r.orig - apex
  let dv = r.dir.dot(v)
  let wv = w.dot(v)

  let a = dv * dv - cos_a2 * r.dir.length_squared()
  let b = 2.0 * (dv * wv - cos_a2 * r.dir.dot(w))
  let c_side = wv * wv - cos_a2 * w.length_squared()
  let disc = b * b - 4.0 * a * c_side

  let mut closest_t = t_max
  let mut found = false
  let mut hit_normal = { x: 0.0, y: 0.0, z: 0.0 }

  if disc >= 0.0 && a.abs() > 1.0e-8 {
    let sqrt_disc = disc.sqrt()
    let t0 = (-b - sqrt_disc) / (2.0 * a)
    let t1 = (-b + sqrt_disc) / (2.0 * a)

    let check_t = fn(t_val : Double) -> Unit {
      if t_val < t_min || t_val > t_max {
        return
      }
      let p = r.at(t_val)
      let y_proj = (p - apex).dot(v)
      if y_proj >= 0.0 && y_proj <= h_cone {
        let cone_normal = {
          x: (p.x - apex.x) / r_cone,
          y: r_cone / h_cone,
          z: (p.z - apex.z) / r_cone,
        }.normalize()
        if t_val < closest_t {
          closest_t = t_val
          hit_normal = cone_normal
          found = true
        }
      }
    }
    check_t(t0)
    check_t(t1)
  }

  let base_denom = r.dir.dot(v)
  if base_denom.abs() > 1.0e-8 {
    let t_base = (base.y - r.orig.y) / base_denom
    if t_base >= t_min && t_base <= t_max {
      let p = r.at(t_base)
      if (p.x - base.x) * (p.x - base.x) + (p.z - base.z) * (p.z - base.z) <= r_cone * r_cone {
        if t_base < closest_t {
          closest_t = t_base
          hit_normal = { x: 0.0, y: -1.0, z: 0.0 }
          found = true
        }
      }
    }
  }

  if !found {
    return None
  }

  let p = r.at(closest_t)
  let rec = { p, normal: hit_normal, t: closest_t, front_face: false, material: self.material }
  Some(rec.set_face_normal(r, hit_normal))
}
