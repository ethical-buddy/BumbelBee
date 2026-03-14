#ifndef FMT_H
#define FMT_H

#include "types.h"

typedef void (*fmt_emit_fn)(char c, void *ctx);
void fmt_vprintf(fmt_emit_fn emit, void *ctx, const char *fmt, __builtin_va_list ap);

#endif
