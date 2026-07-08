///|
/// Axis-Aligned Bounding Box for ray intersection acceleration.

pub(all) struct AABB {
  min : Vec3
  max : Vec3
} derive(Debug)

pub fn AABB::new(min~ : Vec3, max~ : Vec3) -> AABB {
  { min, max }
}

pub fn empty_aabb() -> AABB {
  {
    min: { x: 1.0e30, y: 1.0e30, z: 1.0e30 },
    max: { x: -1.0e30, y: -1.0e30, z: -1.0e30 },
  }
}

pub fn AABB::hit(self : AABB, r : Ray, t_min~ : Double, t_max~ : Double) -> Bool {
  let mut t0 = t_min
  let mut t1 = t_max

  let inv_d = 1.0 / r.dir.x
  let mut t0x = (self.min.x - r.orig.x) * inv_d
  let mut t1x = (self.max.x - r.orig.x) * inv_d
  if inv_d < 0.0 {
    let tmp = t0x
    t0x = t1x
    t1x = tmp
  }
  if t0x > t0 { t0 = t0x }
  if t1x < t1 { t1 = t1x }
  if t0 >= t1 { return false }

  let inv_d_y = 1.0 / r.dir.y
  let mut t0y = (self.min.y - r.orig.y) * inv_d_y
  let mut t1y = (self.max.y - r.orig.y) * inv_d_y
  if inv_d_y < 0.0 {
    let tmp = t0y
    t0y = t1y
    t1y = tmp
  }
  if t0y > t0 { t0 = t0y }
  if t1y < t1 { t1 = t1y }
  if t0 >= t1 { return false }

  let inv_d_z = 1.0 / r.dir.z
  let mut t0z = (self.min.z - r.orig.z) * inv_d_z
  let mut t1z = (self.max.z - r.orig.z) * inv_d_z
  if inv_d_z < 0.0 {
    let tmp = t0z
    t0z = t1z
    t1z = tmp
  }
  if t0z > t0 { t0 = t0z }
  if t1z < t1 { t1 = t1z }
  if t0 >= t1 { return false }

  true
}

pub fn surrounding_box(box0 : AABB, box1 : AABB) -> AABB {
  let small = box0.min.min(box1.min)
  let big = box0.max.max(box1.max)
  { min: small, max: big }
}

pub fn Hitable::bounding_box(self : Hitable) -> AABB {
  match self {
    Sphere(s) => {
      let r = { x: s.radius, y: s.radius, z: s.radius }
      { min: s.center - r, max: s.center + r }
    }
    Plane(_) => {
      let inf = 1.0e30
      { min: { x: -inf, y: -inf, z: -inf }, max: { x: inf, y: inf, z: inf } }
    }
    Triangle(tri) => {
      let v0 = tri.v0
      let v1 = tri.v1
      let v2 = tri.v2
      let min_p = v0.min(v1).min(v2) - { x: 0.001, y: 0.001, z: 0.001 }
      let max_p = v0.max(v1).max(v2) + { x: 0.001, y: 0.001, z: 0.001 }
      { min: min_p, max: max_p }
    }
    BoxShape(bx) => {
      let r = { x: bx.size.x / 2.0, y: bx.size.y / 2.0, z: bx.size.z / 2.0 }
      { min: bx.center - r, max: bx.center + r }
    }
    Cylinder(cyl) => {
      let r = { x: cyl.radius, y: cyl.height / 2.0, z: cyl.radius }
      { min: cyl.center - r, max: cyl.center + r }
    }
    Disk(dk) => {
      let r = { x: dk.radius, y: 0.001, z: dk.radius }
      { min: dk.center - r, max: dk.center + r }
    }
    Cone(cn) => {
      let r = cn.base_radius
      let min_y = cn.base_center.y.min(cn.apex.y)
      let max_y = cn.base_center.y.max(cn.apex.y)
      { min: { x: cn.base_center.x - r, y: min_y, z: cn.base_center.z - r },
        max: { x: cn.base_center.x + r, y: max_y, z: cn.base_center.z + r } }
    }
    Torus(tor) => {
      let big_r = tor.major_radius + tor.minor_radius
      let rv = { x: big_r, y: tor.minor_radius, z: big_r }
      { min: tor.center - rv, max: tor.center + rv }
    }
  }
}
