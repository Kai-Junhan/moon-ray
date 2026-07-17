fn main {
  let pixels = @lib.render_scene_full(
    width=400, height=225,
    samples_per_pixel=100, max_depth=50,
    world=@lib.three_spheres_scene().0, cam=@lib.three_spheres_scene().1,
    fog_density=0.0,
  )
  @lib.write_ppm_tonemapped(width=400, height=225, pixels=pixels)
}
