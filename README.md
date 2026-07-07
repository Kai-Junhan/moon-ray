# moon-ray

**MoonBit Monte Carlo Path Tracing Renderer** — OSC 2026 参赛项目

纯 MoonBit 实现的蒙特卡洛路径追踪渲染器，支持物理基础材质、景深相机、BVH 加速结构，可编译为 Wasm 浏览器交互式渲染器。

## 快速开始

```bash
# 安装 MoonBit 工具链
# https://www.moonbitlang.cn/download

# 克隆项目
git clone git@github.com:Kai-Junhan/moon-ray.git
cd moon-ray

# 检查编译
moon check

# 渲染三球场景（输出 PPM 到终端，可重定向到文件查看）
moon run cmd/main > output.ppm
```

## 项目结构

```
moon-ray/
├── math_vec3.mbt        # Vec3 向量运算 + 运算符重载
├── math_ray.mbt         # Ray 光线
├── math_random.mbt      # 伪随机数 + 采样函数
├── geometry_hit.mbt     # Hitable 几何体枚举 + HitRecord + HitableList
├── geometry_sphere.mbt  # Sphere 几何体
├── material.mbt         # 材质枚举（Lambertian/Metal/Dielectric/Emissive）
├── camera.mbt           # 可调相机 + 景深
├── renderer.mbt         # 路径追踪渲染器
├── demo_scenes.mbt      # 预设场景
├── output_ppm.mbt       # PPM 输出
├── cmd/main/            # CLI 入口
├── moon.mod             # 模块配置
└── moon.pkg             # 包配置
```

## 功能

- **4 种材质**：Lambertian（漫反射）、Metal（金属 + 粗糙度）、Dielectric（玻璃/水 + 菲涅尔折射）、Emissive（发光光源）
- **递归路径追踪**：蒙特卡洛全局光照，俄罗斯轮盘赌终止
- **可调相机**：位置、朝向、FOV、光圈、焦距、景深
- **天空渐变背景**
- **PPM P3 文本格式输出**

## 测试渲染

```powershell
# 确保在项目根目录下运行
cd moon-ray

# 运行测试脚本，生成 test_output.ppm
powershell -File test.ps1

# 查看渲染结果（PPM 格式，可用 IrfanView / GIMP / ffmpeg 打开）
# start test_output.ppm

# 完成后删除测试文件
powershell -File clean.ps1
```

## 许可证

Apache-2.0
