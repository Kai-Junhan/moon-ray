///|
/// BVH (Bounding Volume Hierarchy) with recursive traversal.
/// Builds a spatial partition tree and integrates with HitableList.

struct BVHNode {
  bbox : AABB
  left : BVHNode?
  right : BVHNode?
  object : Hitable?
} derive(Debug)

fn bvh_object_centroid(obj : Hitable, axis : Int) -> Double {
  let b = obj.bounding_box()
  let c = (b.min.x + b.max.x) * 0.5
  let d = (b.min.y + b.max.y) * 0.5
  let e = (b.min.z + b.max.z) * 0.5
  if axis == 0 { c } else if axis == 1 { d } else { e }
}

/// Recursive BVH tree builder.
fn bvh_build(objects : Array[Hitable], start : Int, end : Int) -> BVHNode? {
  let count = end - start
  if count == 0 {
    return None
  }

  // Compute bounding box of all objects in range
  let mut bbox = objects[start].bounding_box()
  for i in (start + 1)..<end {
    bbox = surrounding_box(bbox, objects[i].bounding_box())
  }

  if count == 1 {
    return Some({ left: None, right: None, bbox, object: Some(objects[start]) })
  }

  // Choose split axis: longest side of centroid bounding box
  let centroid_box = bvh_centroid_range(objects, start, end)
  let dx = centroid_box.max.x - centroid_box.min.x
  let dy = centroid_box.max.y - centroid_box.min.y
  let dz = centroid_box.max.z - centroid_box.min.z
  let axis = if dx > dy && dx > dz { 0 } else if dy > dz { 1 } else { 2 }

  // Sort objects by centroid along chosen axis
  let mid = (start + end) / 2
  bvh_partition(objects, start, end, axis, mid)

  let left = bvh_build(objects, start, mid)
  let right = bvh_build(objects, mid, end)

  Some({ left, right, bbox, object: None })
}

fn bvh_centroid_range(objects : Array[Hitable], start : Int, end : Int) -> AABB {
  let c0 = bvh_object_centroid(objects[start], 0)
  let c1 = bvh_object_centroid(objects[start], 1)
  let c2 = bvh_object_centroid(objects[start], 2)
  let mut min_x = c0; let mut max_x = c0
  let mut min_y = c1; let mut max_y = c1
  let mut min_z = c2; let mut max_z = c2
  for i in (start + 1)..<end {
    let cx = bvh_object_centroid(objects[i], 0)
    let cy = bvh_object_centroid(objects[i], 1)
    let cz = bvh_object_centroid(objects[i], 2)
    if cx < min_x { min_x = cx }
    if cx > max_x { max_x = cx }
    if cy < min_y { min_y = cy }
    if cy > max_y { max_y = cy }
    if cz < min_z { min_z = cz }
    if cz > max_z { max_z = cz }
  }
  { min: Vec3::new(x=min_x, y=min_y, z=min_z), max: Vec3::new(x=max_x, y=max_y, z=max_z) }
}

/// Partition objects so that objects [start, pivot] have centroid <= median.
fn bvh_partition(objects : Array[Hitable], start : Int, end : Int, axis : Int, pivot : Int) -> Unit {
  let mut left = start
  let mut right = end - 1
  let pivot_val = bvh_object_centroid(objects[pivot], axis)
  while left <= right {
    while left < end && bvh_object_centroid(objects[left], axis) < pivot_val {
      left = left + 1
    }
    while right >= start && bvh_object_centroid(objects[right], axis) > pivot_val {
      right = right - 1
    }
    if left <= right {
      let tmp = objects[left]
      objects[left] = objects[right]
      objects[right] = tmp
      left = left + 1
      right = right - 1
    }
  }
}

/// Recursive BVH hit traversal.
pub fn bvh_hit(node : BVHNode, objects : Array[Hitable], r : Ray, t_min~ : Double, t_max~ : Double) -> HitRecord? {
  if !(node.bbox.hit(r, t_min=t_min, t_max=t_max)) {
    return None
  }
  match node.object {
    Some(obj) => obj.hit(r, t_min=t_min, t_max=t_max)
    None => {
      let mut best = t_max
      let mut result : HitRecord? = None
      match node.left {
        Some(ln) => {
          let hit = bvh_hit(ln, objects, r, t_min=t_min, t_max=best)
          match hit {
            Some(rec) => { best = rec.t; result = Some(rec) }
            None => ()
          }
        }
        None => ()
      }
      match node.right {
        Some(rn) => {
          let hit = bvh_hit(rn, objects, r, t_min=t_min, t_max=best)
          match hit {
            Some(rec) => { result = Some(rec) }
            None => ()
          }
        }
        None => ()
      }
      result
    }
  }
}

/// Build BVH from an array of objects. Returns the root node.
/// Mutates the objects array by sorting for spatial locality.
pub fn bvh_build_from(objects : Array[Hitable]) -> BVHNode? {
  bvh_build(objects, 0, objects.length())
}
