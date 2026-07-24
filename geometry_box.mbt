///|
/// Axis-aligned box geometry (cuboid).

pub(all) struct BoxShape {
  center : Vec3
  size : Vec3
  material : Material
} derive(Debug)

pub fn BoxShape::new(center~ : Vec3, size~ : Vec3, material~ : Material) -> BoxShape {
  { center, size, material }
}

pub fn BoxShape::hit_box(self : BoxShape, r : Ray, t_min~ : Double, t_max~ : Double) -> HitRecord? {
  let half = { x: self.size.x / 2.0, y: self.size.y / 2.0, z: self.size.z / 2.0 }
  let box_min = self.center - half
  let box_max = self.center + half

  let inv_dir = { x: 1.0 / r.dir.x, y: 1.0 / r.dir.y, z: 1.0 / r.dir.z }

  let mut tmin = (box_min.x - r.orig.x) * inv_dir.x
  let mut tmax = (box_max.x - r.orig.x) * inv_dir.x
  if inv_dir.x < 0.0 {
    let tmp = tmin
    tmin = tmax
    tmax = tmp
  }

  let mut tymin = (box_min.y - r.orig.y) * inv_dir.y
  let mut tymax = (box_max.y - r.orig.y) * inv_dir.y
  if inv_dir.y < 0.0 {
    let tmp = tymin
    tymin = tymax
    tymax = tmp
  }
  tmin = if tymin > tmin { tymin } else { tmin }
  tmax = if tymax < tmax { tymax } else { tmax }

  if tmin >= tmax || tmax < t_min || tmin > t_max {
    return None
  }

  let mut tzmin = (box_min.z - r.orig.z) * inv_dir.z
  let mut tzmax = (box_max.z - r.orig.z) * inv_dir.z
  if inv_dir.z < 0.0 {
    let tmp = tzmin
    tzmin = tzmax
    tzmax = tmp
  }
  tmin = if tzmin > tmin { tzmin } else { tmin }
  tmax = if tzmax < tmax { tzmax } else { tmax }

  if tmin >= tmax || tmax < t_min || tmin > t_max {
    return None
  }

  let t = if tmin > t_min { tmin } else { tmax }
  if t < t_min || t > t_max {
    return None
  }

  let p = r.at(t)
  let outward_normal = box_normal_at(p, box_min, box_max)
  let rec = { p, normal: outward_normal, t, front_face: false, material: self.material }
  Some(rec.set_face_normal(r, outward_normal))
}

fn box_normal_at(p : Vec3, box_min : Vec3, box_max : Vec3) -> Vec3 {
  let eps = 1.0e-4
  if (p.x - box_min.x).abs() < eps {
    { x: -1.0, y: 0.0, z: 0.0 }
  } else if (p.x - box_max.x).abs() < eps {
    { x: 1.0, y: 0.0, z: 0.0 }
  } else if (p.y - box_min.y).abs() < eps {
    { x: 0.0, y: -1.0, z: 0.0 }
  } else if (p.y - box_max.y).abs() < eps {
    { x: 0.0, y: 1.0, z: 0.0 }
  } else if (p.z - box_min.z).abs() < eps {
    { x: 0.0, y: 0.0, z: -1.0 }
  } else {
    { x: 0.0, y: 0.0, z: 1.0 }
  }
}
