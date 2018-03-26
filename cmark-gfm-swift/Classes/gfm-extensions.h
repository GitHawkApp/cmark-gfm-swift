#ifndef GFM_EXTENSIONS_H
#define GFM_EXTENSIONS_H

#ifdef __cplusplus
extern "C" {
#endif

#include <libcmark_gfm/cmark_extension_api.h>
#include <libcmark_gfm/cmarkextensions_export.h>
#include <stdint.h>

CMARKEXTENSIONS_EXPORT
void gfm_extensions_ensure_registered(void);

#ifdef __cplusplus
}
#endif

#endif


