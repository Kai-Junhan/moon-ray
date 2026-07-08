<div align="center">

# moon-ray

**Pure MoonBit Monte Carlo Path Tracer**

─────────────────────

A physically-based rendering engine written entirely in [MoonBit](https://www.moonbitlang.cn/),
featuring 8 geometry types, 7 materials, BVH acceleration, procedural textures,
volume rendering, post-processing, and an interactive web GUI.

*2026 MoonBit Open Source Ecosystem Competition Entry*

─────────────────────

</div>

## Features

### Core Rendering
- **Monte Carlo Path Tracing** — Full global illumination with recursive ray bounces
- **Next Event Estimation** — Direct light sampling with Multiple Importance Sampling (MIS)
- **Russian Roulette Termination** — Unbiased path termination for efficiency
- **Gamma & sRGB Correction** — Proper color output for modern displays

### Geometry (8 Types)
| Type | File | Description |
|------|------|-------------|
| Sphere | `geometry_sphere.mbt` | Ray-sphere intersection |
| Plane | `geometry_plane.mbt` | Infinite plane with normal |
| Triangle | `geometry_triangle.mbt` | Möller–Trumbore intersection |
| Box | `geometry_box.mbt` | Axis-aligned cuboid |
| Cylinder | `geometry_cylinder.mbt` | Y-axis aligned cylinder |
| Disk | `geometry_disk.mbt` | Flat circular disk |
| Cone | `geometry_cone.mbt` | Tapered cone with base |
| Torus | `geometry_torus.mbt` | Donut shape via Newton's method |
| Mesh | `geometry_mesh.mbt` | Triangle mesh with UV sphere & cube builders |

### Materials (7 Types)
| Material | Description |
|----------|-------------|
| Lambertian | Ideal diffuse (matte) surfaces |
| Metal | Specular reflection with configurable fuzz |
| Dielectric | Glass/water with Schlick Fresnel |
| Emissive | Light source (HDR values supported) |
| DiffuseLight | Textured area light |
| Isotropic | Volume-like scattering |
| Textured | Dull surface with texture mapping |

### Acceleration
- **BVH (Bounding Volume Hierarchy)** — Recursive spatial partitioning for scene intersection

### Textures
- Solid color, checkerboard, procedural noise, and image textures

### Camera
- Configurable position, look-at, FOV, aperture (depth of field), and motion blur
- Animation-ready keyframe paths with Catmull-Rom interpolation and easing functions

### Post-Processing
- Reinhard & ACES tone mapping
- Bloom, vignette, film grain, and edge-aware denoising

### Output Formats
- PPM (ASCII text, pipe to stdout)
- BMP (24-bit uncompressed binary)

### Environment
- Gradient sky, Hosek-Wilkie sky model, black-body radiation, sun direction

### Volume Rendering
- Ray marching through constant-density volumes (fog, smoke)
- Exponential fog, layered fog, Beer-Lambert absorption

## Quick Start

### Prerequisites
Install the MoonBit toolchain: https://www.moonbitlang.cn/download/

### Build & Test
```bash
git clone git@github.com:Kai-Junhan/moon-ray.git
cd moon-ray

moon check          # Syntax check — 0 errors
moon test           # Unit tests — 32/32 pass
moon build          # Compile
```

### Render a Scene
```bash
# Default: Three Spheres (400x225, 100 spp)
moon run cmd/main > output.ppm

# Or use the test script
powershell -File test.ps1
```

### Launch Web GUI
```bash
python gui/server.py
# Open http://localhost:8088
```
The GUI provides scene selection, parameter sliders, preset quality levels, and live PPM preview in your browser.

## Demo Scenes (13 Total)

| Scene | Key | Description |
|-------|-----|-------------|
| `three_spheres` | Classic | Diffuse + Metal + Glass |
| `cornell_box` | GI Test | Spherical light box |
| `material_showcase` | Materials | 4 Lamberts + 4 Metals + 3 Dielectrics |
| `random_spheres` | Stress | 121 random objects |
| `geometric` | Multi-Geo | Boxes, cylinders, disks with checker floor |
| `cornell_box_planes` | Planar | Plane-based Cornell box |
| `texture_demo` | Textures | Checker & noise-mapped spheres |
| `triangle_demo` | Triangles | Colored triangle banners |
| `final_demo` | Showcase | 121 mixed shapes with DOF |
| `full_geometry` | All Types | Every geometry type on display |
| `studio_lighting` | Lighting | Three-point studio light setup |
| `depth_of_field` | DOF | Aperture blur on metal spheres |
| `foggy_scene` | Volume | Atmospheric fog effect |

## Project Structure

```
moon-ray/
├── .github/workflows/ci.yml     # GitHub Actions CI
├── .githooks/pre-commit         # Git pre-commit hook
├── gui/                         # Web GUI (HTML/CSS/JS + Python server)
├── cmd/main/                    # CLI entry point
│
├── math_vec3.mbt                # Vec3 + operator overloading
├── math_ray.mbt                 # Ray representation
├── math_random.mbt              # xorshift128+ PRNG + sampling
├── math_aabb.mbt                # Axis-Aligned Bounding Box
├── math_onb.mbt                 # Orthonormal Basis for sampling
├── math_perlin.mbt              # Perlin noise generator
├── texture_base.mbt             # Texture enum (Solid/Checker/Noise/Image)
│
├── geometry_sphere.mbt          # Sphere geometry
├── geometry_plane.mbt           # Plane geometry
├── geometry_triangle.mbt        # Triangle (Möller–Trumbore)
├── geometry_box.mbt             # Axis-aligned box
├── geometry_cylinder.mbt        # Cylinder
├── geometry_disk.mbt            # Disk
├── geometry_cone.mbt            # Cone
├── geometry_torus.mbt           # Torus
├── geometry_mesh.mbt            # Triangle mesh
├── geometry_hit.mbt             # Hitable enum + HitableList
│
├── material.mbt                 # Material enum (7 types) + scattering
├── camera.mbt                   # Camera model + defocus blur
├── renderer.mbt                 # Path tracing core
├── render_sampling.mbt          # Stratified/Sobol/MIS sampling
├── render_config.mbt            # Render parameter management
│
├── bvh.mbt                      # BVH acceleration structure
├── animation.mbt                # Keyframe camera animation
├── environment.mbt              # Sky models & black-body radiation
├── tone_mapping.mbt             # Reinhard/ACES/gamma tone mapping
├── volume_render.mbt            # Participating media & fog
├── post_process.mbt             # Bloom/vignette/denoising
├── scene_loader.mbt             # Scene builder API
│
├── demo_scenes.mbt              # Preset scenes (4)
├── demo_extra.mbt               # Extended scenes (5)
├── demo_extra2.mbt              # Extended scenes (4)
│
├── output_ppm.mbt               # PPM output format
├── output_bmp.mbt               # BMP output format
│
├── *_test.mbt                   # Unit tests (5 files, 32 tests)
├── moon.mod / moon.pkg          # Package configuration
├── test.ps1 / gui.ps1           # Helper scripts
├── README.md
└── LICENSE                      # Apache 2.0
```

## Continuous Integration

On every push, GitHub Actions automatically runs:
- `moon check` — Full syntax verification
- `moon test` — All unit tests
- `moon build` — Compilation check
- Render test — Generates and validates PPM output

## Testing

```bash
moon test          # 32 tests, all passing
```

Coverage includes:
- **Vec3**: dot, cross, length, normalize, reflect, refract, lerp
- **Ray**: at-point computation
- **AABB**: hit/miss detection
- **RNG**: deterministic random generation, unit vectors, hemisphere sampling
- **Geometry**: sphere, plane, box, cylinder, disk, cone, torus, mesh hit tests
- **Materials**: Lambertian scatter, emissive/EmissiveLight, diffuse light
- **Textures**: solid, checker, noise color evaluation
- **Tone mapping**: Reinhard, gamma correction
- **Camera**: ray generation, custom positioning
- **BMP**: header format, output size validation
- **Scene**: object construction, config defaults
- **Animation**: keyframe interpolation, camera paths
- **Volume**: exponential fog, Beer-Lambert absorption

## Packages

Published on [mooncakes.io](https://mooncakes.io) — importable as:
```moonbit
import "Kai-Junhan/moon-ray"
```

## References

This project draws inspiration from:
- [*Ray Tracing in One Weekend*](https://raytracing.github.io/books/RayTracingInOneWeekend.html) — Peter Shirley
- [*Physically Based Rendering*](https://pbr-book.org/) — Pharr, Jakob, Humphreys

## License

Apache License 2.0 — See [LICENSE](LICENSE) for details.

---

<div align="center">

**Built with MoonBit for the 2026 Open Source Ecosystem Competition**

★ Star on [GitHub](https://github.com/Kai-Junhan/moon-ray) — Available on [mooncakes.io](https://mooncakes.io)

</div>
