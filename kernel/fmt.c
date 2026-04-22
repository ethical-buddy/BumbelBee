#include "fmt.h"

static void emit_string(fmt_emit_fn emit, void *ctx, const char *s) {
    while (*s) {
        emit(*s++, ctx);
    }
}

static void emit_unsigned(fmt_emit_fn emit, void *ctx, u64 value, u32 base) {
    char buf[32];
    const char *digits = "0123456789abcdef";
    size_t i = 0;
    if (value == 0) {
        emit('0', ctx);
        return;
    }
    while (value) {
        buf[i++] = digits[value % base];
        value /= base;
    }
    while (i) {
        emit(buf[--i], ctx);
    }
}

static void emit_signed(fmt_emit_fn emit, void *ctx, s64 value) {
    if (value < 0) {
        emit('-', ctx);
        emit_unsigned(emit, ctx, (u64)(-value), 10);
        return;
    }
    emit_unsigned(emit, ctx, (u64)value, 10);
}

void fmt_vprintf(fmt_emit_fn emit, void *ctx, const char *fmt, __builtin_va_list ap) {
    for (; *fmt; ++fmt) {
        if (*fmt != '%') {
            emit(*fmt, ctx);
            continue;
        }
        ++fmt;
        switch (*fmt) {
        case 's':
            emit_string(emit, ctx, __builtin_va_arg(ap, const char *));
            break;
        case 'c':
            emit((char)__builtin_va_arg(ap, int), ctx);
            break;
        case 'u':
            emit_unsigned(emit, ctx, __builtin_va_arg(ap, u32), 10);
            break;
        case 'd':
            emit_signed(emit, ctx, __builtin_va_arg(ap, s32));
            break;
        case 'x':
            emit_unsigned(emit, ctx, __builtin_va_arg(ap, u32), 16);
            break;
        case 'l':
            ++fmt;
            if (*fmt == 'u') {
                emit_unsigned(emit, ctx, __builtin_va_arg(ap, u64), 10);
            } else if (*fmt == 'd') {
                emit_signed(emit, ctx, __builtin_va_arg(ap, s64));
            } else if (*fmt == 'x') {
                emit_unsigned(emit, ctx, __builtin_va_arg(ap, u64), 16);
            }
            break;
        case '%':
            emit('%', ctx);
            break;
        default:
            emit('?', ctx);
            break;
        }
    }
}
