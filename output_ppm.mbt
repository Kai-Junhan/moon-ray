///|
/// PPM (Portable Pixmap) image output to stdout.
/// For file output, pipe: `moon run cmd/main > output.ppm`

/// Output a PPM P3 (text) format image to stdout.
pub fn write_ppm_stdout(
  width~ : Int,
  height~ : Int,
  pixels~ : Array[Vec3],
  samples_per_pixel~ : Int
) -> Unit {
  // PPM header
  println("P3")
  println("\{width} \{height}")
  println("255")

  let scale = 1.0 / samples_per_pixel.to_double()

  for j in 0..<height {
    for i in 0..<width {
      let idx = j * width + i
      let pixel = pixels[idx]
      let r = clamp((pixel.x * scale).sqrt(), min=0.0, max=0.999)
      let g = clamp((pixel.y * scale).sqrt(), min=0.0, max=0.999)
      let b = clamp((pixel.z * scale).sqrt(), min=0.0, max=0.999)

      let ir = (256.0 * r).to_int()
      let ig = (256.0 * g).to_int()
      let ib = (256.0 * b).to_int()

      println("\{ir} \{ig} \{ib}")
    }
  }
}

/// Clamp value to [min, max].
fn clamp(x : Double, min~ : Double, max~ : Double) -> Double {
  if x < min {
    min
  } else if x > max {
    max
  } else {
    x
  }
}
