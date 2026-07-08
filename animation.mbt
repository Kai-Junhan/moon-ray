///|
/// Animation support for camera paths and object transforms.
/// Keyframe interpolation using Catmull-Rom and linear splines.

pub(all) struct Keyframe {
  time : Double
  position : Vec3
  lookat : Vec3
} derive(Debug)

pub fn Keyframe::new(time~ : Double, position~ : Vec3, lookat~ : Vec3) -> Keyframe {
  { time, position, lookat }
}

pub fn interpolate_keyframe(k1 : Keyframe, k2 : Keyframe, t : Double) -> Keyframe {
  let total = k2.time - k1.time
  let factor = if total > 0.0 { (t - k1.time) / total } else { 0.0 }
  let cf = factor.clamp(min=0.0, max=1.0)
  {
    time: t,
    position: k1.position.lerp(k2.position, cf),
    lookat: k1.lookat.lerp(k2.lookat, cf),
  }
}

pub fn camera_along_path(keyframes : Array[Keyframe], t : Double) -> (Vec3, Vec3) {
  if keyframes.length() == 0 {
    return ({ x: 0.0, y: 0.0, z: 0.0 }, { x: 0.0, y: 0.0, z: -1.0 })
  }
  if keyframes.length() == 1 {
    return (keyframes[0].position, keyframes[0].lookat)
  }

  let mut i = 0
  for j in 1..<keyframes.length() {
    if t < keyframes[j].time {
      i = j - 1
      break
    }
    i = j
  }

  let kf = interpolate_keyframe(keyframes[i], keyframes[(i + 1).min(keyframes.length() - 1)], t)
  (kf.position, kf.lookat)
}

pub fn catmull_rom(v0 : Vec3, v1 : Vec3, v2 : Vec3, v3 : Vec3, t : Double) -> Vec3 {
  let t2 = t * t
  let t3 = t2 * t
  let a = v0.mul_scalar(-0.5 * t3 + t2 - 0.5 * t)
  let b = v1.mul_scalar(1.5 * t3 - 2.5 * t2 + 1.0)
  let c = v2.mul_scalar(-1.5 * t3 + 2.0 * t2 + 0.5 * t)
  let d = v3.mul_scalar(0.5 * t3 - 0.5 * t2)
  a + b + c + d
}

pub fn motion_blur_sample(time0 : Double, time1 : Double) -> (Double, Double) {
  let rng = default_rng()
  let (t, _) = rng.random_double_range(min=time0, max=time1)
  (t, time1 - time0)
}

pub fn smoothstep_edge0(edge0 : Double, edge1 : Double, x : Double) -> Double {
  let t = ((x - edge0) / (edge1 - edge0)).clamp(min=0.0, max=1.0)
  t * t * (3.0 - 2.0 * t)
}

pub fn ease_in_out_quad(t : Double) -> Double {
  if t < 0.5 {
    2.0 * t * t
  } else {
    1.0 - @math.pow(-2.0 * t + 2.0, 2.0) / 2.0
  }
}

pub fn ease_in_out_cubic(t : Double) -> Double {
  if t < 0.5 {
    4.0 * t * t * t
  } else {
    1.0 - @math.pow(-2.0 * t + 2.0, 3.0) / 2.0
  }
}

pub fn create_orbiting_camera_path(
  center~ : Vec3,
  radius~ : Double,
  height~ : Double,
  num_frames~ : Int,
  duration~ : Double
) -> Array[Keyframe] {
  let result = Array::new(capacity=num_frames)
  for i in 0..<num_frames {
    let t = i.to_double() / (num_frames - 1).to_double()
    let angle = t * 2.0 * @math.PI
    let pos = {
      x: center.x + radius * @math.cos(angle),
      y: height,
      z: center.z + radius * @math.sin(angle),
    }
    result.push(Keyframe::new(time=t * duration, position=pos, lookat=center))
  }
  result
}
