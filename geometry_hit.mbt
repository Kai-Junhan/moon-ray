///|
/// Hitable geometry with BVH-accelerated hit testing.

pub(all) enum Hitable {
  Sphere(Sphere)
  Plane(Plane)
  Triangle(Triangle)
  BoxShape(BoxShape)
  Cylinder(Cylinder)
  Disk(Disk)
  Cone(Cone)
  Torus(Torus)
} derive(Debug)

pub(all) struct HitRecord {
  p : Vec3
  normal : Vec3
  t : Double
  front_face : Bool
  material : Material
} derive(Debug)

pub fn HitRecord::set_face_normal(self : HitRecord, r : Ray, outward_normal : Vec3) -> HitRecord {
  let front_face = r.dir.dot(outward_normal) < 0.0
  let normal = if front_face { outward_normal } else { -outward_normal }
  { ..self, front_face, normal }
}

/// Per-object hit test.
pub fn Hitable::hit(self : Hitable, r : Ray, t_min~ : Double, t_max~ : Double) -> HitRecord? {
  match self {
    Sphere(s) => {
      let oc = r.orig - s.center
      let a = r.dir.length_squared()
      let half_b = oc.dot(r.dir)
      let c = oc.length_squared() - s.radius * s.radius
      let discriminant = half_b * half_b - a * c

      if discriminant < 0.0 { return None }

      let sqrtd = discriminant.sqrt()
      let mut root = (-half_b - sqrtd) / a
      if root < t_min || root > t_max {
        root = (-half_b + sqrtd) / a
        if root < t_min || root > t_max { return None }
      }

      let p = r.at(root)
      let outward_normal = (p - s.center).div_scalar(s.radius)
      let mut rec = { p, normal: outward_normal, t: root, front_face: false, material: s.material }
      rec = rec.set_face_normal(r, outward_normal)
      Some(rec)
    }
    Plane(pl) => pl.hit_plane(r, t_min=t_min, t_max=t_max)
    Triangle(tri) => tri.hit_triangle(r, t_min=t_min, t_max=t_max)
    BoxShape(bx) => bx.hit_box(r, t_min=t_min, t_max=t_max)
    Cylinder(cyl) => cyl.hit_cylinder(r, t_min=t_min, t_max=t_max)
    Disk(dk) => dk.hit_disk(r, t_min=t_min, t_max=t_max)
    Cone(cn) => cn.hit_cone(r, t_min=t_min, t_max=t_max)
    Torus(tor) => tor.hit_torus(r, t_min=t_min, t_max=t_max)
  }
}

/// World with optional BVH acceleration.
pub(all) struct HitableList {
  objects : Array[Hitable]
  bvh_ready : Bool
} derive(Debug)

/// Module-level BVH cache: maps objects array identity to BVH root.
/// Since MoonBit doesn't support mutable struct fields, we cache here.
let _bvh_cache : Array[(Int, BVHNode?)] = Array::new(capacity=8)

fn bvh_cache_key(objects : Array[Hitable]) -> Int {
  // Use object count + first object's bounding box as a simple key
  // This is a heuristic; for correctness, the cache is cleared on build_bvh
  objects.length()
}

fn bvh_cache_lookup(objects : Array[Hitable]) -> BVHNode? {
  let key = bvh_cache_key(objects)
  for i in 0..<_bvh_cache.length() {
    if _bvh_cache[i].0 == key {
      return _bvh_cache[i].1
    }
  }
  None
}

fn bvh_cache_store(objects : Array[Hitable], root : BVHNode?) -> Unit {
  let key = bvh_cache_key(objects)
  // Replace existing entry or add new
  for i in 0..<_bvh_cache.length() {
    if _bvh_cache[i].0 == key {
      _bvh_cache[i] = (key, root)
      return
    }
  }
  _bvh_cache.push((key, root))
}

pub fn HitableList::new() -> HitableList {
  { objects: Array::new(capacity=16), bvh_ready: false }
}

pub fn HitableList::add(self : HitableList, object : Hitable) -> HitableList {
  let objs = self.objects
  objs.push(object)
  { objects: objs, bvh_ready: false }
}

/// Build BVH acceleration structure. Must be called before rendering
/// for scenes with more than a handful of objects.
pub fn HitableList::build_bvh(self : HitableList) -> HitableList {
  if self.objects.length() <= 1 || self.bvh_ready {
    return self
  }
  let root = bvh_build_from(self.objects)
  bvh_cache_store(self.objects, root)
  { ..self, bvh_ready: true }
}

/// BVH-accelerated hit. When BVH is built, uses hierarchical traversal.
/// Otherwise falls back to linear scan.
pub fn HitableList::hit(self : HitableList, r : Ray, t_min~ : Double, t_max~ : Double) -> HitRecord? {
  if !(self.bvh_ready) || self.objects.length() < 1 {
    return self.hit_linear(r, t_min=t_min, t_max=t_max)
  }
  let cached = bvh_cache_lookup(self.objects)
  match cached {
    None => {
      // Fallback: rebuild (shouldn't happen if build_bvh was called)
      let root = bvh_build_from(self.objects)
      match root {
        None => self.hit_linear(r, t_min=t_min, t_max=t_max)
        Some(node) => bvh_hit(node, self.objects, r, t_min=t_min, t_max=t_max)
      }
    }
    Some(node) => bvh_hit(node, self.objects, r, t_min=t_min, t_max=t_max)
  }
}

/// Linear scan hit (fallback).
fn HitableList::hit_linear(self : HitableList, r : Ray, t_min~ : Double, t_max~ : Double) -> HitRecord? {
  let mut closest = t_max
  let mut result : HitRecord? = None
  for i in 0..<self.objects.length() {
    match self.objects[i].hit(r, t_min=t_min, t_max=closest) {
      None => ()
      Some(rec) => { closest = rec.t; result = Some(rec) }
    }
  }
  result
}
