fn main {
  let (world, cam) = @lib.three_spheres_scene()
  let w = world.build_bvh()
  let pixels = @lib.render_scene_full(
    width=400, height=225,
    samples_per_pixel=100, max_depth=50,
    world=w, cam=cam,
    fog_density=0.0,
    post_process=@lib.default_post_process_config(),
  )
  @lib.write_ppm_tonemapped(width=400, height=225, pixels=pixels)
}
