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
  let _root = bvh_build_from(self.objects)
  { ..self, bvh_ready: true }
}

/// BVH-accelerated hit. When BVH is built, uses hierarchical traversal.
/// Otherwise falls back to linear scan.
pub fn HitableList::hit(self : HitableList, r : Ray, t_min~ : Double, t_max~ : Double) -> HitRecord? {
  if !(self.bvh_ready) || self.objects.length() < 1 {
    return self.hit_linear(r, t_min=t_min, t_max=t_max)
  }
  let root = bvh_build_from(self.objects)
  match root {
    None => self.hit_linear(r, t_min=t_min, t_max=t_max)
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
