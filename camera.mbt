///|
/// Camera model with configurable position, look-at, and defocus blur.

pub(all) struct Camera {
  origin : Vec3
  lower_left_corner : Vec3
  horizontal : Vec3
  vertical : Vec3
  u : Vec3
  v : Vec3
  w : Vec3
  lens_radius : Double
  time0 : Double
  time1 : Double
} derive(Debug)

pub fn Camera::new(
  lookfrom~ : Vec3,
  lookat~ : Vec3,
  vup~ : Vec3,
  vfov~ : Double,
  aspect_ratio~ : Double,
  aperture~ : Double,
  focus_dist~ : Double,
  time0~ : Double,
  time1~ : Double
) -> Camera {
  let theta = vfov * @math.PI / 180.0
  let h = @math.tan(theta / 2.0)
  let viewport_height = 2.0 * h
  let viewport_width = aspect_ratio * viewport_height

  let w_dir = (lookfrom - lookat).normalize()
  let u_dir = vup.cross(w_dir).normalize()
  let v_dir = w_dir.cross(u_dir)

  let origin = lookfrom
  let horizontal = u_dir.mul_scalar(viewport_width * focus_dist)
  let vertical = v_dir.mul_scalar(viewport_height * focus_dist)
  let lower_left_corner = origin - horizontal.div_scalar(2.0) - vertical.div_scalar(2.0) - w_dir.mul_scalar(focus_dist)

  {
    origin, lower_left_corner, horizontal, vertical,
    u: u_dir, v: v_dir, w: w_dir,
    lens_radius: aperture / 2.0,
    time0, time1,
  }
}

pub fn Camera::default(aspect_ratio~ : Double) -> Camera {
  Camera::new(
    lookfrom={ x: 0.0, y: 0.0, z: 0.0 },
    lookat={ x: 0.0, y: 0.0, z: -1.0 },
    vup={ x: 0.0, y: 1.0, z: 0.0 },
    vfov=90.0, aspect_ratio=aspect_ratio, aperture=0.0, focus_dist=1.0,
    time0=0.0, time1=0.0,
  )
}

pub fn Camera::get_ray(self : Camera, s : Double, t : Double) -> Ray {
  let (rd, _) = default_rng().random_in_unit_disk()
  let offset = self.u.mul_scalar(rd.x * self.lens_radius) + self.v.mul_scalar(rd.y * self.lens_radius)
  let (tm, _) = default_rng().random_double_range(min=self.time0, max=self.time1)
  Ray::new(
    orig=self.origin + offset,
    dir=self.lower_left_corner + self.horizontal.mul_scalar(s) + self.vertical.mul_scalar(t) - self.origin - offset,
    tm=tm,
  )
}
