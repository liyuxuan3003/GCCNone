# GCCNone

该项目会自动拉取GCC源代码，从源代码编译适用于裸机的GCC编译器，支持RISC-V和ARM架构。
- RISC-V架构：`riscv-none-elf`
- ARM架构：`arm-none-eabi`

## 准备工作
在`~/.profile`或`~/.zprofile`下添加
```
export PATH="$PATH:/opt/riscv-none-elf/bin"
export PATH="$PATH:/opt/arm-none-eabi/bin"
```

安装必要工具
```
sudo apt install build-essential libgmp-dev libmpfr-dev libmpc-dev meson ninja-build
```

## riscv-none-elf
创建文件夹并切换所有者
```
sudo mkdir /opt/riscv-none-elf
sudo chown liyuxuan:liyuxuan /opt/riscv-none-elf
```

编译并安装
```
make TARGET=riscv-none-elf
```

## arm-none-eabi
创建文件夹并切换所有者
```
sudo mkdir /opt/arm-none-eabi
sudo chown liyuxuan:liyuxuan /opt/arm-none-eabi
```

编译并安装
```
make TARGET=arm-none-eabi
```

