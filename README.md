<div align="center">

# moon-ray

**Pure MoonBit Monte Carlo Path Tracer**

[![CI](https://github.com/Kai-Junhan/moon-ray/actions/workflows/ci.yml/badge.svg)](https://github.com/Kai-Junhan/moon-ray/actions)
[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](LICENSE)
[![MoonBit](https://img.shields.io/badge/Language-MoonBit-6f42c1)](https://www.moonbitlang.cn/)
[![mooncakes.io](https://img.shields.io/badge/mooncakes.io-v0.4.0-00b894)](https://mooncakes.io)

*2026 MoonBit Open Source Ecosystem Competition*

─────────────────────

A physically-based rendering engine written entirely in [MoonBit](https://www.moonbitlang.cn/).
8 geometry types, 7 PBR materials, BVH acceleration, procedural textures,
volume rendering, post-processing, and an interactive web GUI.

─────────────────────

</div>

<details>
<summary><b>中文介绍</b></summary>

moon-ray 是一个纯 [MoonBit](https://www.moonbitlang.cn/) 实现的蒙特卡洛路径追踪渲染器，
是 **2026 MoonBit 国产基础软件开源大赛** 参赛项目。

基于物理渲染（PBR）理论，从零实现了完整的 Monte Carlo 光线追踪管线。
支持 8 种几何体类型、7 种物理材质、BVH 加速结构、程序化纹理生成、
体积渲染（雾/烟）、后处理特效链以及交互式 Web 图形界面。

内置 13 个演示场景，覆盖经典三球、Cornell Box、材质对比、景深虚化、
大气雾效等效果。项目搭载完整 CI/CD 流水线，32 个单元测试全部通过，
已发布至 [mooncakes.io](https://mooncakes.io) 生态。

</details>

---

## Features / 功能特性

### Rendering / 渲染管线
- **Monte Carlo Path Tracing** — Full global illumination with recursive ray bounces
- **Russian Roulette Termination** — Unbiased early termination for performance
- **Next Event Estimation** — Direct light importance sampling with MIS
- **Gamma & sRGB Correction** — Physically accurate color output

<details><summary>中文</summary>

- **蒙特卡洛路径追踪** — 递归光线弹射，模拟完整全局光照
- **俄罗斯轮盘赌终止** — 无偏的早期路径终止，提升渲染效率
- **次事件估计 (NEE)** — 对光源直接采样，配合多重重要性采样 (MIS)
- **Gamma/sRGB 校正** — 物理准确的色彩输出

</details>

### Geometry / 几何体 (8 Types)

| Type / 类型 | File / 文件 | Description / 描述 |
|-------------|-------------|-------------------|
| Sphere / 球体 | `geometry_sphere.mbt` | Ray-sphere intersection |
| Plane / 平面 | `geometry_plane.mbt` | Infinite plane |
| Triangle / 三角形 | `geometry_triangle.mbt` | Möller–Trumbore algorithm |
| Box / 盒子 | `geometry_box.mbt` | Axis-aligned cuboid |
| Cylinder / 圆柱 | `geometry_cylinder.mbt` | Y-axis aligned |
| Disk / 圆盘 | `geometry_disk.mbt` | Flat circular disk |
| Cone / 圆锥 | `geometry_cone.mbt` | Tapered cone with base cap |
| Torus / 圆环 | `geometry_torus.mbt` | Newton's method solver |
| Mesh / 网格 | `geometry_mesh.mbt` | Triangle mesh with builders |

### Materials / 材质 (7 Types)

| Material / 材质 | Description / 描述 |
|-----------------|-------------------|
| Lambertian | Ideal diffuse (matte) surfaces / 理想漫反射 |
| Metal | Specular reflection with fuzz / 金属反射（可调粗糙度） |
| Dielectric | Glass/water with Schlick Fresnel / 电介质（玻璃/水/钻石） |
| Emissive | Light source (HDR) / 自发光光源 |
| DiffuseLight | Textured area light / 纹理区域光 |
| Isotropic | Volume-like scattering / 各向同性散射 |
| Textured | Dull surface with texture mapping / 纹理映射哑光表面 |

### Acceleration / 加速结构
- **BVH (Bounding Volume Hierarchy)** — Recursive spatial partitioning

### Textures / 纹理
- **Solid** — Uniform color
- **Checker** — Procedural checkerboard with configurable scale
- **Noise** — Hash-based procedural noise
- **Image** — Bitmap texture sampling

### Camera / 相机
- Configurable look-from, look-at, FOV, aperture (depth of field), motion blur
- Keyframe animation paths with Catmull-Rom interpolation and easing functions

### Post-Processing / 后处理
- **Tone Mapping** — Reinhard, ACES filmic, gamma correction
- **Bloom** — Gaussian blur on highlights
- **Vignette** — Edge darkening
- **Film Grain** — Procedural noise overlay
- **Denoising** — Edge-aware bilateral filter (stub)

### Output / 输出格式
- **PPM** — ASCII text (pipe to stdout)
- **BMP** — 24-bit uncompressed binary

### Environment / 环境光
- Gradient sky, Hosek-Wilkie sky model, black-body radiation, sun direction

### Volume / 体积渲染
- Ray marching through constant-density volumes
- Exponential fog, layered fog, Beer-Lambert absorption

---

## Quick Start / 快速开始

### Prerequisites

Install the MoonBit toolchain: https://www.moonbitlang.cn/download/

### Build & Test / 构建与测试

```bash
git clone git@github.com:Kai-Junhan/moon-ray.git
cd moon-ray

moon check          # Syntax check — 0 errors / 语法检查
moon test           # Unit tests — 32/32 pass / 单元测试
moon build          # Compile / 编译
```

### Render / 渲染

```bash
# Default scene: Three Spheres (400×225, 100 spp)
# 默认场景：三球 (400×225, 100 spp)
moon run cmd/main > output.ppm

# Run full test suite / 运行完整测试套件
powershell -File test.ps1
```

### Web GUI / 图形界面

```bash
python gui/server.py
# Open http://localhost:8088

# Or use the PowerShell launcher / 或使用 PowerShell 启动
powershell -File gui.ps1
```

The GUI features: scene selector, parameter sliders, quick presets, live PPM preview.

<details><summary>中文</summary>

图形界面功能：场景选择器、参数滑动条、快速预设级别（低/中/高/超高）、实时 PPM 预览。

</details>

---

## Demo Scenes / 演示场景 (18 Total)

| # | Scene / 场景 | Key | Description / 描述 |
|---|-------------|-----|-------------------|
| 1 | `three_spheres` | Classic / 经典 | Diffuse + Metal + Glass |
| 2 | `cornell_box` | GI Test / 全局光 | Spherical light box |
| 3 | `material_showcase` | Materials / 材质 | 4 Lamberts + 4 Metals + 3 Dielectrics |
| 4 | `random_spheres` | Stress / 压力 | 121 random objects |
| 5 | `geometric` | Multi-Geo / 多几何体 | Boxes, cylinders, disks, checker floor |
| 6 | `cornell_box_planes` | Planar / 平面 | Plane-based Cornell box |
| 7 | `texture_demo` | Textures / 纹理 | Checker & noise spheres |
| 8 | `triangle_demo` | Triangles / 三角 | Colored triangle banners |
| 9 | `final_demo` | Showcase / 展示 | 121 mixed shapes + DOF |
| 10 | `full_geometry` | All Types / 全类型 | Every geometry type on display |
| 11 | `studio_lighting` | Lighting / 布光 | Three-point studio light setup |
| 12 | `depth_of_field` | DOF / 景深 | Aperture blur on metal spheres |
| 13 | `foggy_scene` | Volume / 大气 | Atmospheric fog effect |
| 14 | `mirror_corridor` | Mirror / 镜面 | Infinite reflection corridor |
| 15 | `crystal_garden` | Crystal / 水晶 | Glass prisms with colored lights |
| 16 | `sunrise_valley` | Landscape / 风景 | Stone monoliths at dawn |
| 17 | `prism_lab` | IOR Lab / 折射 | 6 dielectric prisms (water→diamond) |
| 18 | `city_at_night` | City / 城市 | Skyline with emissive windows |

---

## Project Structure / 项目结构

```
moon-ray/
├── .github/workflows/ci.yml     # GitHub Actions CI
├── .githooks/pre-commit         # Git pre-commit hook
├── gui/                         # Web GUI (HTML/CSS/JS + Python server)
├── cmd/main/                    # CLI entry point / CLI 入口
│
├── math_*.mbt                   # Math: Vec3, Ray, RNG, AABB, ONB, Perlin
├── geometry_*.mbt               # Geometry: Sphere, Plane, Triangle, Box,
│                                #   Cylinder, Disk, Cone, Torus, Mesh, Hit
├── texture_base.mbt             # Texture enum / 纹理枚举
├── material.mbt                 # Material enum (7 types) / 材质枚举
├── camera.mbt                   # Camera model + defocus blur / 相机+景深
├── renderer.mbt                 # Path tracing core / 路径追踪核心
├── render_sampling.mbt          # Advanced sampling / 高级采样
├── render_config.mbt            # Render parameter management / 渲染配置
│
├── bvh.mbt                      # BVH acceleration / BVH 加速
├── animation.mbt                # Keyframe camera / 关键帧动画
├── environment.mbt              # Sky & black-body / 天空模型
├── tone_mapping.mbt             # Reinhard/ACES/gamma / 色调映射
├── volume_render.mbt            # Fog & media / 体积渲染
├── post_process.mbt             # Bloom/vignette/denoise / 后处理
├── scene_loader.mbt             # Scene builder API / 场景构建
│
├── demo_scenes.mbt              # Preset scenes × 4 / 预设场景
├── demo_extra.mbt               # Extended scenes × 5 / 扩展场景
├── demo_extra2.mbt              # Extended scenes × 4 / 扩展场景
├── demo_extra3.mbt              # Advanced scenes × 5 / 高级场景
│
├── output_ppm.mbt               # PPM output / PPM 输出
├── output_bmp.mbt               # BMP output / BMP 输出
│
├── *_test.mbt                   # Tests × 5 (32 cases) / 测试
├── moon.mod / moon.pkg          # Package config / 包配置
├── test.ps1 / gui.ps1           # Helper scripts / 辅助脚本
├── README.md
└── LICENSE                      # Apache 2.0
```

---

## CI/CD / 持续集成

On every push, GitHub Actions automatically runs / 每次推送自动执行：

| Step | Status |
|------|--------|
| `moon check` | ✅ 0 errors / 零错误 |
| `moon test` | ✅ 32/32 pass / 全部通过 |
| `moon build` | ✅ Build successful / 编译成功 |
| Render test | ✅ PPM validation / PPM 格式验证 |

---

## Testing / 测试

```bash
moon test                    # 32 tests, all passing / 32 个测试全部通过
```

Coverage includes: Vec3 operations, ray-point computation, AABB hit/miss,
RNG determinism, all 8 geometry types, material emission/scattering,
texture evaluation, tone mapping, camera rays, BMP output, scene construction,
animation interpolation, and volume fog.

<details><summary>中文</summary>

测试覆盖：Vec3 运算、光线求交、AABB 碰撞、随机数确定性、全部 8 种几何体、
材质发射/散射、纹理采样、色调映射、相机光线、BMP 输出、场景构建、
动画插值和体积雾效。

</details>

---

## Packages / 包管理

Published on [mooncakes.io](https://mooncakes.io) — importable as / 可在 mooncakes.io 获取：

```moonbit
import "Kai-Junhan/moon-ray"
```

---

## References / 参考资料

- [_Ray Tracing in One Weekend_](https://raytracing.github.io/books/RayTracingInOneWeekend.html) — Peter Shirley (2020)
  - **License**: CC0 1.0 Universal (Public Domain Dedication)
  - **Referenced sections**:
    - Chapter 6: Surface normals and ray-sphere intersection → `geometry_sphere.mbt`
    - Chapter 8: Diffuse (Lambertian) materials → `material.mbt` (Lambertian variant)
    - Chapter 9: Metal reflection with fuzz → `material.mbt` (Metal variant)
    - Chapter 10: Dielectrics, Snell's law, Schlick approximation → `material.mbt` (Dielectric variant)
    - Chapter 11: Defocus blur (thin-lens camera model) → `camera.mbt`
    - Chapter 12: Random scene construction pattern → `demo_scenes.mbt`
  - **Adaptation**: All algorithms re-implemented from first principles in idiomatic MoonBit. No code was translated line-by-line; only the mathematical formulations were referenced.

- [_Ray Tracing: The Next Week_](https://raytracing.github.io/books/RayTracingTheNextWeek.html) — Peter Shirley (2020)
  - **License**: CC0 1.0 Universal (Public Domain Dedication)
  - **Referenced sections**:
    - Chapter 3: BVH (Bounding Volume Hierarchy) construction via axis sorting → `bvh.mbt`
    - Chapter 5: Perlin noise procedural texture → `math_perlin.mbt`
    - Chapter 8: Constant-density volumes (participating media) → `volume_render.mbt`
  - **Adaptation**: BVH uses centroid-midpoint partitioning instead of SAH; volume rendering extends to layered fog and Beer-Lambert absorption beyond the reference.

- [_Physically Based Rendering: From Theory to Implementation_](https://pbr-book.org/) — Matt Pharr, Wenzel Jakob, Greg Humphreys (3rd/4th edition)
  - **License**: MIT License (online edition, code and samples)
  - **Referenced concepts** (no code copied):
    - Section 13.10: Multiple Importance Sampling (MIS) with balance/power heuristics → `render_sampling.mbt`
    - Section 14.3: Next Event Estimation (direct light sampling) → `renderer.mbt`
    - Section 12.2: Russian roulette path termination → `renderer.mbt`
    - Section 4.3: AABB ray intersection for BVH traversal → `math_aabb.mbt`
  - **Adaptation**: Mathematical formulations only; no code verbatim. MIS weights integrated into the NEE + BSDF sampling loop.

- **ACES Filmic Tone Mapping** — Academy Color Encoding System
  - **License**: Public specification (Academy of Motion Picture Arts and Sciences)
  - **Source**: Stephen Hill's ACES approximation (fitted curve)
  - **Used in**: `renderer.mbt` (tone mapping pass), `tone_mapping.mbt`

All MoonBit source code is an original implementation. The following features are independent additions with no external reference:
8 geometry types (Plane, Triangle, Box, Cylinder, Disk, Cone, Torus, Mesh), DiffuseLight/Isotropic/Textured material types, procedural texture system (Checker, Noise, Image), post-processing pipeline (bloom, vignette, color grading, film grain, denoising), keyframe animation system with easing functions, scene builder API, interactive web GUI, BMP output, and all demo scenes.

---

## License / 许可证

Apache License 2.0 — See [LICENSE](LICENSE) for details.

---

<div align="center">

**Built with MoonBit for the 2026 Open Source Ecosystem Competition**

★ Star on [GitHub](https://github.com/Kai-Junhan/moon-ray) · [Gitlink](https://gitlink.org.cn/weedmind/moonbit) · [mooncakes.io](https://mooncakes.io)

</div>
