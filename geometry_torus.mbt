///|
/// Torus geometry (donut shape) in the XZ plane.

pub(all) struct Torus {
  center : Vec3
  major_radius : Double
  minor_radius : Double
  material : Material
} derive(Debug)

pub fn Torus::new(center~ : Vec3, major_radius~ : Double, minor_radius~ : Double, material~ : Material) -> Torus {
  { center, major_radius, minor_radius, material }
}

pub fn Torus::hit_torus(self : Torus, r : Ray, t_min~ : Double, t_max~ : Double) -> HitRecord? {
  let orig = r.orig - self.center
  let dir = r.dir
  let r_major = self.major_radius
  let r_minor = self.minor_radius

  let ox = orig.x
  let oy = orig.y
  let oz = orig.z
  let dx = dir.x
  let dy = dir.y
  let dz = dir.z

  let mut min_t = t_max

  for i in 0..=3 {
    let t_est = (t_min + t_max) / 2.0 + (i - 1).to_double() * 0.1
    let mut t = t_est

    for _ in 0..<50 {
      let x = ox + t * dx
      let y = oy + t * dy
      let z = oz + t * dz
      let sum_p_sq = x * x + y * y + z * z

      let f = sum_p_sq * sum_p_sq - 2.0 * sum_p_sq * (r_major * r_major + r_minor * r_minor) +
              4.0 * r_major * r_major * (x * x + z * z) + (r_major * r_major - r_minor * r_minor) * (r_major * r_major - r_minor * r_minor) / sum_p_sq * sum_p_sq

      let fp = 4.0 * sum_p_sq * (dx * x + dy * y + dz * z) -
               4.0 * (r_major * r_major + r_minor * r_minor) * (dx * x + dy * y + dz * z) +
               8.0 * r_major * r_major * (dx * x + dz * z)

      let dt = f / fp.max(1.0e-8)
      t = t - dt
      if dt.abs() < 1.0e-6 {
        break
      }
    }

    if t >= t_min && t < min_t {
      let p = r.at(t) - self.center
      let param_sq = p.x * p.x + p.y * p.y + p.z * p.z + r_major * r_major - r_minor * r_minor
      let normal = {
        x: 4.0 * p.x * param_sq - 8.0 * r_major * r_major * p.x,
        y: 4.0 * p.y * param_sq,
        z: 4.0 * p.z * param_sq - 8.0 * r_major * r_major * p.z,
      }.normalize()
      let local_p = r.at(t)
      if (local_p - self.center).y > -r_minor - 0.01 {
        if (local_p - self.center).length() > r_major * 0.1 {
          min_t = t
          let rec = { p: r.at(t), normal, t, front_face: false, material: self.material }
          let result = rec.set_face_normal(r, normal)
          return Some(result)
        }
      }
    }
  }

  None
}
