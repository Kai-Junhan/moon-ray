///|
/// Post-processing effects: bloom, vignette, color grading, denoising stubs.

pub fn apply_vignette(pixels : Array[Vec3], width : Int, height : Int, strength~ : Double) -> Array[Vec3] {
  let result = Array::new(capacity=pixels.length())
  let cx = width.to_double() / 2.0
  let cy = height.to_double() / 2.0
  let max_dist = (cx * cx + cy * cy).sqrt()
  for j in 0..<height {
    for i in 0..<width {
      let idx = j * width + i
      let dx = (i.to_double() - cx) / max_dist
      let dy = (j.to_double() - cy) / max_dist
      let dist = (dx * dx + dy * dy).sqrt()
      let factor = 1.0 - strength * dist * dist
      let factor_clamped = factor.max(0.0).min(1.0)
      result.push(pixels[idx].mul_scalar(factor_clamped))
    }
  }
  result
}

pub fn apply_bloom(pixels : Array[Vec3], width : Int, height : Int, threshold~ : Double, intensity~ : Double) -> Array[Vec3] {
  let bloom = Array::new(capacity=pixels.length())
  for j in 0..<height {
    for i in 0..<width {
      let idx = j * width + i
      let lum = sky_luminance(pixels[idx])
      if lum > threshold {
        bloom.push(pixels[idx].mul_scalar(intensity * (lum - threshold) / lum.max(0.001)))
      } else {
        bloom.push({ x: 0.0, y: 0.0, z: 0.0 })
      }
    }
  }

  let kernel_size = 5
  let bloom_blurred = Array::new(capacity=bloom.length())
  for j in 0..<height {
    for i in 0..<width {
      let mut accum = { x: 0.0, y: 0.0, z: 0.0 }
      let mut count = 0.0
      let half = kernel_size / 2
      for dy in -half..=half {
        for dx in -half..=half {
          let nx = i + dx
          let ny = j + dy
          if nx >= 0 && nx < width && ny >= 0 && ny < height {
            let den = dx.to_double() * dx.to_double() + dy.to_double() * dy.to_double()
            let weight = gaussian_filter(den.sqrt(), 3.0)
            accum = accum + bloom[ny * width + nx].mul_scalar(weight)
            count = count + weight
          }
        }
      }
      if count > 0.0 {
        accum = accum.div_scalar(count)
      }
      bloom_blurred.push(accum)
    }
  }

  let result = Array::new(capacity=pixels.length())
  for j in 0..<height {
    for i in 0..<width {
      let idx = j * width + i
      result.push(pixels[idx] + bloom_blurred[idx])
    }
  }
  result
}

pub fn apply_color_grading(
  pixels : Array[Vec3], width : Int, height : Int,
  contrast~ : Double, saturation~ : Double, brightness~ : Double, temperature~ : Double
) -> Array[Vec3] {
  let result = Array::new(capacity=pixels.length())
  let lum_weights = { x: 0.2126, y: 0.7152, z: 0.0722 }
  for j in 0..<height {
    for i in 0..<width {
      let idx = j * width + i
      let color = pixels[idx]

      let scaled = color.mul_scalar(brightness.max(0.0))

      let lum = scaled.x * lum_weights.x + scaled.y * lum_weights.y + scaled.z * lum_weights.z
      let r = lum + (scaled.x - lum) * saturation.max(0.0)
      let g = lum + (scaled.y - lum) * saturation.max(0.0)
      let b = lum + (scaled.z - lum) * saturation.max(0.0)

      let mid = 0.5
      let cr = mid + (r - mid) * contrast.max(0.0)
      let cg = mid + (g - mid) * contrast.max(0.0)
      let cb = mid + (b - mid) * contrast.max(0.0)

      let fr = if temperature != 0.0 { cr + temperature * 0.1 } else { cr }
      let fz = if temperature != 0.0 { cb - temperature * 0.1 } else { cb }

      result.push({ x: fr, y: cg, z: fz })
    }
  }
  result
}

pub fn apply_film_grain(pixels : Array[Vec3], width : Int, height : Int, intensity~ : Double) -> Array[Vec3] {
  let result = Array::new(capacity=pixels.length())
  let mut rng = default_rng()
  for j in 0..<height {
    for i in 0..<width {
      let idx = j * width + i
      let (n, new_rng) = rng.random_double_range(min=-intensity, max=intensity)
      rng = new_rng
      let noise = { x: n, y: n, z: n }
      result.push(pixels[idx] + noise)
    }
  }
  result
}

pub fn edge_aware_denoise_stub(pixels : Array[Vec3], width : Int, height : Int) -> Array[Vec3] {
  let result = Array::new(capacity=pixels.length())
  for j in 0..<height {
    for i in 0..<width {
      let idx = j * width + i
      let mut accum = { x: 0.0, y: 0.0, z: 0.0 }
      let mut total_weight = 0.0
      let center = pixels[idx]
      for dy in -1..=1 {
        for dx in -1..=1 {
          let nx = i + dx
          let ny = j + dy
          if nx >= 0 && nx < width && ny >= 0 && ny < height {
            let neighbor = pixels[ny * width + nx]
            let diff = (center - neighbor).length()
            let color_weight = @math.exp(-diff * 10.0)
            accum = accum + neighbor.mul_scalar(color_weight)
            total_weight = total_weight + color_weight
          }
        }
      }
      if total_weight > 0.0 {
        result.push(accum.div_scalar(total_weight))
      } else {
        result.push(center)
      }
    }
  }
  result
}
