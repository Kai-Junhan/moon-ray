test "render_basic" {
  let (world, cam) = three_spheres_scene()
  let pixels = render_scene(width=4, height=4, samples_per_pixel=2, max_depth=2, world=world, cam=cam)
  assert_eq(pixels.length(), 16)
}
test "camera_default" {
  let cam = Camera::default(aspect_ratio=1.0)
  assert_eq(cam.origin.x, 0.0)
}
test "camera_ray" {
  let cam = Camera::default(aspect_ratio=1.0)
  let r = cam.get_ray(0.5, 0.5)
  assert_true(r.dir.z < -0.5)
}
test "demo_mirror_corridor" {
  let (_world, _cam) = mirror_corridor_scene()
  assert_true(true)
}
test "demo_crystal_garden" {
  let (_world, _cam) = crystal_garden_scene()
  assert_true(true)
}
test "demo_sunrise_valley" {
  let (_world, _cam) = sunrise_valley_scene()
  assert_true(true)
}
test "demo_prism_lab" {
  let (_world, _cam) = prism_lab_scene()
  assert_true(true)
}
test "demo_city_at_night" {
  let (_world, _cam) = city_at_night_scene()
  assert_true(true)
}