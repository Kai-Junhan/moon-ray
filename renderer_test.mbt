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
