test "render_basic_output" {
  let (world, cam) = three_spheres_scene()
  let pixels = render_scene(width=4, height=4, samples_per_pixel=4, max_depth=4, world=world, cam=cam)
  assert_eq(pixels.length(), 16)
  let full = render_scene_full(width=4, height=4, samples_per_pixel=4, max_depth=4, world=world, cam=cam)
  assert_eq(full.length(), 16)
  assert_true(full[0].x >= 0.0)
  assert_true(full[0].x <= 1.0)
}
test "camera_default_position" {
  let cam = Camera::default(aspect_ratio=1.0)
  assert_eq(cam.origin.x, 0.0)
  assert_eq(cam.origin.y, 0.0)
  assert_eq(cam.origin.z, 0.0)
}
test "camera_ray_direction" {
  let cam = Camera::default(aspect_ratio=1.0)
  let r = cam.get_ray(0.5, 0.5)
  assert_true(r.dir.z < -0.5)
}
test "camera_ray_corners_differ" {
  let cam = Camera::default(aspect_ratio=1.0)
  let r1 = cam.get_ray(0.0, 0.0)
  let r2 = cam.get_ray(1.0, 1.0)
  let diff = (r1.dir.x - r2.dir.x).abs() + (r1.dir.y - r2.dir.y).abs()
  assert_true(diff > 0.01)
}
test "mirror_corridor_scene_has_objects" {
  let (world, _cam) = mirror_corridor_scene()
  assert_true(world.objects.length() > 5)
}
test "crystal_garden_has_lights" {
  let (world, _cam) = crystal_garden_scene()
  let mut has_light = false
  for i in 0..<world.objects.length() {
    let emitted = world.objects[i].match_material(0.0, 0.0, Vec3::new(x=0.0, y=0.0, z=0.0))
    if emitted.length() > 0.1 { has_light = true }
  }
  assert_true(has_light)
}
test "scene_builds_and_renders" {
  let (world, cam) = three_spheres_scene()
  let pixels = render_scene_full(width=4, height=4, samples_per_pixel=4, max_depth=4, world=world, cam=cam)
  assert_eq(pixels.length(), 16)
  assert_true(pixels[0].x >= 0.0 && pixels[0].x <= 1.0)
  assert_true(pixels[8].y >= 0.0 && pixels[8].y <= 1.0)
}
