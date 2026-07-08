test "vec3_add" {
  let a = Vec3::new(x=1.0, y=2.0, z=3.0)
  let b = Vec3::new(x=4.0, y=5.0, z=6.0)
  let c = a + b
  assert_eq(c.x, 5.0)
  assert_eq(c.y, 7.0)
  assert_eq(c.z, 9.0)
}

test "vec3_sub" {
  let a = Vec3::new(x=5.0, y=5.0, z=5.0)
  let b = Vec3::new(x=1.0, y=2.0, z=3.0)
  let c = a - b
  assert_eq(c.x, 4.0)
}
test "vec3_dot" {
  let a = Vec3::new(x=1.0, y=0.0, z=0.0)
  let b = Vec3::new(x=0.0, y=1.0, z=0.0)
  assert_eq(a.dot(b), 0.0)
}
test "vec3_cross" {
  let a = Vec3::new(x=1.0, y=0.0, z=0.0)
  let b = Vec3::new(x=0.0, y=1.0, z=0.0)
  let c = a.cross(b)
  assert_eq(c.z, 1.0)
}
test "vec3_length" {
  let v = Vec3::new(x=3.0, y=4.0, z=0.0)
  assert_eq(v.length(), 5.0)
}
test "vec3_normalize" {
  let v = Vec3::new(x=3.0, y=0.0, z=0.0)
  let n = v.normalize()
  assert_eq(n.x, 1.0)
}
test "reflect_45" {
  let v = Vec3::new(x=1.0, y=-1.0, z=0.0)
  let n = Vec3::new(x=0.0, y=1.0, z=0.0)
  let r = reflect(v, n)
  assert_eq(r.x, 1.0)
  assert_eq(r.y, 1.0)
}
test "vec3_lerp" {
  let a = Vec3::new(x=0.0, y=0.0, z=0.0)
  let b = Vec3::new(x=10.0, y=10.0, z=10.0)
  let c = a.lerp(b, 0.5)
  assert_eq(c.x, 5.0)
}
