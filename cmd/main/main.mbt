fn main {
  let (world, cam) = @lib.three_spheres_scene()

  let width = 400
  let height = 225
  let samples = 100
  let max_depth = 50

  let pixels = @lib.render_scene(width=width, height=height, samples_per_pixel=samples, max_depth=max_depth, world=world, cam=cam)
  @lib.write_ppm_stdout(width=width, height=height, pixels=pixels, samples_per_pixel=samples)
}
