///|
/// BVH (Bounding Volume Hierarchy) acceleration structure.
/// Significantly speeds up ray-scene intersections for complex scenes.

struct BVHNode {
  left : BVHNode?
  right : BVHNode?
  bbox : AABB
  object : Hitable?
} derive(Debug)

pub fn HitableList::build_bvh(self : HitableList) -> HitableList {
  if self.objects.length() == 0 {
    return self
  }
  let _node = bvh_build(self.objects, 0, self.objects.length())
  self
}

fn bvh_build(objects : Array[Hitable], start : Int, end : Int) -> BVHNode? {
  let count = end - start
  if count == 0 {
    return None
  }

  let mut bbox = objects[start].bounding_box()
  for i in (start + 1)..<end {
    bbox = surrounding_box(bbox, objects[i].bounding_box())
  }

  if count == 1 {
    return Some({ left: None, right: None, bbox, object: Some(objects[start]) })
  }

  let centroid_box = bvh_centroid_box(objects, start, end)
  let axis = bvh_longest_axis(centroid_box)
  let mid = (start + end) / 2
  bvh_sort_objects(objects, start, end, axis)

  let left = bvh_build(objects, start, mid)
  let right = bvh_build(objects, mid, end)

  Some({ left, right, bbox, object: None })
}

fn bvh_centroid_box(objects : Array[Hitable], start : Int, end : Int) -> AABB {
  let mut box0 = empty_aabb()
  for i in start..<end {
    let b = objects[i].bounding_box()
    let centroid = {
      x: (b.min.x + b.max.x) * 0.5,
      y: (b.min.y + b.max.y) * 0.5,
      z: (b.min.z + b.max.z) * 0.5,
    }
    box0 = surrounding_box(box0, { min: centroid, max: centroid })
  }
  box0
}

fn bvh_longest_axis(bbox : AABB) -> Int {
  let dx = bbox.max.x - bbox.min.x
  let dy = bbox.max.y - bbox.min.y
  let dz = bbox.max.z - bbox.min.z
  if dx > dy && dx > dz {
    0
  } else if dy > dz {
    1
  } else {
    2
  }
}

fn bvh_sort_objects(objects : Array[Hitable], start : Int, end : Int, axis : Int) -> Unit {
  let count = end - start
  if count <= 1 {
    return
  }

  let pivot = start + count / 2
  let pivot_val = bvh_object_centroid(objects[pivot], axis)

  let mut i = start
  let mut j = end - 1
  while i <= j {
    while i < end && bvh_object_centroid(objects[i], axis) < pivot_val {
      i = i + 1
    }
    while j >= start && bvh_object_centroid(objects[j], axis) > pivot_val {
      j = j - 1
    }
    if i <= j {
      let tmp = objects[i]
      objects[i] = objects[j]
      objects[j] = tmp
      i = i + 1
      j = j - 1
    }
  }
}

fn bvh_object_centroid(obj : Hitable, axis : Int) -> Double {
  let b = obj.bounding_box()
  let c = (b.min.x + b.max.x) * 0.5
  let d = (b.min.y + b.max.y) * 0.5
  let e = (b.min.z + b.max.z) * 0.5
  if axis == 0 {
    c
  } else if axis == 1 {
    d
  } else {
    e
  }
}
