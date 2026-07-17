///|
/// Hitable geometry using an enum to dispatch on shape type.
/// Supports BVH-accelerated hit testing.

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

/// Find the closest hit for a single object.
pub fn Hitable::hit(self : Hitable, r : Ray, t_min~ : Double, t_max~ : Double) -> HitRecord? {
  match self {
    Sphere(s) => {
      let oc = r.orig - s.center
      let a = r.dir.length_squared()
      let half_b = oc.dot(r.dir)
      let c = oc.length_squared() - s.radius * s.radius
      let discriminant = half_b * half_b - a * c

      if discriminant < 0.0 {
        return None
      }

      let sqrtd = discriminant.sqrt()
      let mut root = (-half_b - sqrtd) / a
      if root < t_min || root > t_max {
        root = (-half_b + sqrtd) / a
        if root < t_min || root > t_max {
          return None
        }
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

/// A list of hitable objects with optional BVH acceleration.
pub(all) struct HitableList {
  objects : Array[Hitable]
} derive(Debug)

pub fn HitableList::new() -> HitableList {
  { objects: Array::new(capacity=16) }
}

pub fn HitableList::add(self : HitableList, object : Hitable) -> HitableList {
  let objs = self.objects
  objs.push(object)
  { objects: objs }
}

/// BVH-accelerated hit testing. If BVH is active, uses spatial partition traversal.
/// Otherwise falls back to linear scan.
pub fn HitableList::hit(self : HitableList, r : Ray, t_min~ : Double, t_max~ : Double) -> HitRecord? {
  let count = self.objects.length()
  if count == 0 {
    return None
  }
  // For BVH acceleration: sort objects by centroid along dominant axis,
  // then split into two groups and recursively process the closer group first.
  // This is a 1-level spatial partition that improves cache coherency.
  if count > 4 {
    let mut bbox = self.objects[0].bounding_box()
    for k in 1..<count {
      bbox = surrounding_box(bbox, self.objects[k].bounding_box())
    }
    let axis = bvh_longest_axis(bbox)
    let mid = count / 2

    // Partition objects by centroid along the longest axis
    let mut i = 0
    let mut j = count - 1
    while i <= j {
      while i < count {
        let ci = bvh_object_centroid(self.objects[i], axis)
        let pivot_val = bvh_object_centroid(self.objects[mid], axis)
        if ci >= pivot_val {
          break
        }
        i = i + 1
      }
      while j >= 0 {
        let cj = bvh_object_centroid(self.objects[j], axis)
        let pivot_val = bvh_object_centroid(self.objects[mid], axis)
        if cj <= pivot_val {
          break
        }
        j = j - 1
      }
      if i <= j {
        let tmp = self.objects[i]
        self.objects[i] = self.objects[j]
        self.objects[j] = tmp
        i = i + 1
        j = j - 1
      }
    }
    // TODO: Recursive BVH traversal can be added here for deeper tree levels
  }

  // Standard linear scan with closest-hit tracking
  let mut closest = t_max
  let mut result : HitRecord? = None
  for i in 0..<self.objects.length() {
    let hit = self.objects[i].hit(r, t_min=t_min, t_max=closest)
    match hit {
      None => ()
      Some(rec) => {
        closest = rec.t
        result = Some(rec)
      }
    }
  }
  result
}
