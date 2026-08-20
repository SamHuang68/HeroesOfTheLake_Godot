#include "suikoden_recompiled_core.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

uint8_t psx_read8(PSX_NativeContext* ctx, uint32_t addr) {
    addr &= 0x001FFFFF;
    return ctx->ram[addr];
}

uint16_t psx_read16(PSX_NativeContext* ctx, uint32_t addr) {
    addr &= 0x001FFFFF;
    return *(uint16_t*)&ctx->ram[addr];
}

uint32_t psx_read32(PSX_NativeContext* ctx, uint32_t addr) {
    addr &= 0x001FFFFF;
    return *(uint32_t*)&ctx->ram[addr];
}

void psx_write8(PSX_NativeContext* ctx, uint32_t addr, uint8_t val) {
    addr &= 0x001FFFFF;
    ctx->ram[addr] = val;
}

void psx_write16(PSX_NativeContext* ctx, uint32_t addr, uint16_t val) {
    addr &= 0x001FFFFF;
    *(uint16_t*)&ctx->ram[addr] = val;
}

void psx_write32(PSX_NativeContext* ctx, uint32_t addr, uint32_t val) {
    addr &= 0x001FFFFF;
    *(uint32_t*)&ctx->ram[addr] = val;
}

void psx_syscall(PSX_NativeContext* ctx, uint32_t code) {
    /* 原版 BIOS / OS 呼叫重定向至 PC 原生系統 API */
}

void suikoden_native_init(PSX_NativeContext* ctx) {
    memset(ctx, 0, sizeof(PSX_NativeContext));
    ctx->pc = 0x80014134;
    ctx->r[29] = 0x801FFFF0; // SP
    ctx->is_running = true;
}
