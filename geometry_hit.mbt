///|
/// Hitable geometry using an enum to dispatch on shape type.

pub(all) enum Hitable {
  Sphere(Sphere)
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

/// Find the closest hit among a list of objects.
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
  }
}

/// A list of hitable objects with world-level hit testing.
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

pub fn HitableList::hit(self : HitableList, r : Ray, t_min~ : Double, t_max~ : Double) -> HitRecord? {
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
