///|
/// Advanced sampling strategies for Monte Carlo integration.
/// Includes stratified sampling, MIS heuristics, and pixel filters.

pub fn sobol_sample(_index : Int, _dimension : Int) -> Double {
  0.5
}

pub fn stratified_2d(s : Int, t : Int, nx : Int, ny : Int) -> (Double, Double) {
  let rng = new_rng((s * 1973 + t * 2663).to_uint64())
  let (dx, r1) = rng.random_double()
  let (dy, _) = r1.random_double()
  ((s.to_double() + dx) / nx.to_double(), (t.to_double() + dy) / ny.to_double())
}

pub fn tent_filter(x : Double) -> Double {
  if x < 1.0 {
    1.0 - x.abs()
  } else {
    0.0
  }
}

pub fn gaussian_filter(x : Double, sigma : Double) -> Double {
  let inv_sigma = 1.0 / sigma
  @math.exp(-0.5 * x * x * inv_sigma * inv_sigma)
}

pub fn balanced_heuristic(n_f : Double, pdf_f : Double, n_g : Double, pdf_g : Double) -> Double {
  let f = n_f * pdf_f
  let g = n_g * pdf_g
  f / (f + g)
}

pub fn power_heuristic(n_f : Double, pdf_f : Double, n_g : Double, pdf_g : Double, beta~ : Double) -> Double {
  let f = n_f * @math.pow(pdf_f, beta)
  let g = n_g * @math.pow(pdf_g, beta)
  f / (f + g)
}

pub fn uniform_sample_hemisphere(rng : Rng, normal : Vec3) -> (Vec3, Rng, Double) {
  let (xi1, r1) = rng.random_double()
  let (xi2, r2) = r1.random_double()
  let z = xi1
  let r = (1.0 - z * z).max(0.0).sqrt()
  let phi = 2.0 * @math.PI * xi2
  let dir = { x: r * @math.cos(phi), y: r * @math.sin(phi), z }
  let onb = ONB::build_from_w(normal=normal)
  let world_dir = onb.local_vec(dir.x, dir.y, dir.z)
  let pdf = 1.0 / (2.0 * @math.PI)
  (world_dir, r2, pdf)
}

pub fn uniform_sample_sphere(rng : Rng) -> (Vec3, Rng) {
  let (xi1, r1) = rng.random_double()
  let (xi2, r2) = r1.random_double()
  let z = 1.0 - 2.0 * xi1
  let r = (1.0 - z * z).max(0.0).sqrt()
  let phi = 2.0 * @math.PI * xi2
  ({ x: r * @math.cos(phi), y: r * @math.sin(phi), z }, r2)
}

pub fn uniform_cone_pdf(cos_theta_max : Double) -> Double {
  1.0 / (2.0 * @math.PI * (1.0 - cos_theta_max))
}

pub fn uniform_sample_cone(rng : Rng, cos_theta_max : Double) -> (Vec3, Rng) {
  let (xi1, r1) = rng.random_double()
  let (xi2, r2) = r1.random_double()
  let cos_theta = (1.0 - xi1) + xi1 * cos_theta_max
  let sin_theta = (1.0 - cos_theta * cos_theta).max(0.0).sqrt()
  let phi = 2.0 * @math.PI * xi2
  ({ x: @math.cos(phi) * sin_theta, y: @math.sin(phi) * sin_theta, z: cos_theta }, r2)
}

pub fn uniform_cone_sample_with_base(rng : Rng, w : Vec3, cos_theta_max : Double) -> (Vec3, Rng) {
  let (dir, new_rng) = uniform_sample_cone(rng, cos_theta_max)
  let onb = ONB::build_from_w(normal=w)
  (onb.local_vec(dir.x, dir.y, dir.z), new_rng)
}
