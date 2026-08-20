/* Copyright (c) 2026 Sam Huang. All Rights Reserved. */
/* 《水滸傳·天導108星》原版 MIPS R3000A 重編譯為 PC 原生 C++ 核心 */
#pragma once
#include <stdint.h>
#include <stdbool.h>

#ifdef __cplusplus
extern "C" {
#endif

typedef struct {
    uint32_t r[32];
    uint32_t pc;
    uint32_t hi, lo;
    uint8_t ram[2 * 1024 * 1024]; // 2MB PSX RAM
    bool is_running;
} PSX_NativeContext;

void suikoden_native_init(PSX_NativeContext* ctx);
void suikoden_native_step(PSX_NativeContext* ctx);
uint8_t psx_read8(PSX_NativeContext* ctx, uint32_t addr);
uint16_t psx_read16(PSX_NativeContext* ctx, uint32_t addr);
uint32_t psx_read32(PSX_NativeContext* ctx, uint32_t addr);
void psx_write8(PSX_NativeContext* ctx, uint32_t addr, uint8_t val);
void psx_write16(PSX_NativeContext* ctx, uint32_t addr, uint16_t val);
void psx_write32(PSX_NativeContext* ctx, uint32_t addr, uint32_t val);
void psx_syscall(PSX_NativeContext* ctx, uint32_t code);

#ifdef __cplusplus
}
#endif
