# moon-ray

**MoonBit 蒙特卡洛路径追踪渲染器** — 2026 MoonBit 国产基础软件开源大赛参赛项目

基于 MoonBit 语言从零实现的物理基础渲染（PBR）路径追踪器，支持多种材质、景深相机和全局光照。

## 技术亮点

### 渲染算法
- **蒙特卡洛路径追踪**: 从相机发射光线，递归追踪其在场景中的反射、折射路径，模拟真实光传输
- **俄罗斯轮盘赌终止**: 避免递归爆炸，保证渲染有限时间完成的同时保持无偏估计
- **伽马校正**: 对最终颜色应用 sqrt 伽马校正，适配 sRGB 显示器

### 物理基础材质（PBR）
| 材质 | 参数 | 说明 |
|------|------|------|
| `Lambertian(albedo)` | 漫反射颜色 | 理想漫反射，适用于墙面、地面等粗糙表面 |
| `Metal(albedo, fuzz)` | 反射颜色 + 粗糙度 | 金属反射，fuzz 控制反射模糊程度 |
| `Dielectric(ior)` | 折射率 | 玻璃/水/钻石，含菲涅尔反射（Schlick 近似） |
| `Emissive(color)` | 发光颜色 | 场景光源，颜色值可 >1.0 实现高动态范围 |

### 相机模型
- 可配置位置和朝向（`lookfrom` / `lookat`）
- 可调视场角（`vfov`）
- 景深效果（`aperture` / `focus_dist`）
- 运动模糊（`time0` / `time1`）

### MoonBit 语言特性应用
- `enum` 实现几何体和材质的多态分派
- 运算符重载（`Add`/`Sub`/`Mul`/`Neg` for `Vec3`）
- 函数式风格的状态传递（RNG 链式调用）
- 模式匹配（`match` for 材质散射）

## 快速开始

### 安装 MoonBit 工具链
```bash
# 参考官方文档安装
# https://www.moonbitlang.cn/download/
```

### 克隆并构建
```bash
git clone git@github.com:Kai-Junhan/moon-ray.git
cd moon-ray

# 检查语法
moon check

# 运行单元测试
moon test

# 编译
moon build
```

### 运行渲染
```bash
# 默认三球场景（400x225, 100 samples）
moon run cmd/main > output.ppm

# 转换为 BMP 查看（Windows）
powershell -File ppm2bmp.ps1 -inputFile output.ppm -outputFile output.bmp

# 使用测试脚本一键运行
powershell -File test.ps1
```

### 自定义渲染参数
修改 `cmd/main/main.mbt` 中的场景和参数：

```moonbit
fn main {
  // 可选场景: three_spheres_scene, cornell_box_scene, 
  //           material_showcase_scene, random_spheres_scene
  let (world, cam) = @lib.material_showcase_scene()

  let width = 800        // 图像宽度
  let height = 450       // 图像高度
  let samples = 500      // 每像素采样数（越高噪点越少）
  let max_depth = 50     // 最大递归深度（越高光照越准确）

  let pixels = @lib.render_scene(
    width=width, height=height,
    samples_per_pixel=samples, max_depth=max_depth,
    world=world, cam=cam,
  )
  @lib.write_ppm_stdout(
    width=width, height=height,
    pixels=pixels, samples_per_pixel=samples,
  )
}
```

## 项目结构

```
moon-ray/
├── math_vec3.mbt            # Vec3 向量 + 运算符重载 + reflect/refract
├── math_ray.mbt             # Ray 光线
├── math_random.mbt          # xorshift128+ 伪随机数 + 采样函数
├── geometry_hit.mbt         # Hitable/HitableList + HitRecord
├── geometry_sphere.mbt      # Sphere 几何体 + 光线求交
├── material.mbt             # 4 种材质枚举 + 散射计算
├── camera.mbt               # 相机模型 + 景深
├── renderer.mbt             # 路径追踪渲染器
├── demo_scenes.mbt          # 4 个预设场景
├── output_ppm.mbt           # PPM P3 格式输出
├── cmd/main/main.mbt        # CLI 入口
├── *.ps1                    # PowerShell 辅助脚本
├── *_test.mbt               # 单元测试
├── .github/workflows/       # CI/CD 配置
├── moon.mod / moon.pkg      # MoonBit 包配置
└── LICENSE                  # Apache-2.0
```

## 预设场景

| 场景 | 说明 | 材质展示 |
|------|------|----------|
| `three_spheres_scene` | 经典三球场景 | 漫反射 + 金属 + 玻璃 |
| `cornell_box_scene` | Cornell Box 全局光照测试 | 自发光光源 + 颜色溢出 |
| `material_showcase_scene` | 材质对比展示 | 4色漫反射 + 4级金属粗糙度 + 3种折射率 |
| `random_spheres_scene` | 随机球体场景 | 100+ 随机材质球体 + 景深 |

## 测试

```bash
# 运行全部测试
moon test

# 测试覆盖
# - Vec3 向量运算: add/sub/mul/neg/dot/cross/length/normalize/reflect/lerp
# - Sphere 求交: 击中/未击中/背面/法线方向
# - 材质散射: Lambertian/Metal/Dielectric/Emissive
```

## CI/CD

每次提交自动触发：
- `moon check` — 语法检查
- `moon test` — 单元测试
- `moon build` — 编译验证
- 渲染测试 — 生成 PPM 并验证格式

## 参考资料

- [_Ray Tracing in One Weekend_](https://raytracing.github.io/books/RayTracingInOneWeekend.html) — Peter Shirley
- [Physically Based Rendering](https://pbr-book.org/) — Matt Pharr, Wenzel Jakob, Greg Humphreys

## 许可证

Apache-2.0
