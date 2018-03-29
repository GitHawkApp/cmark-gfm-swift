#include "gfm-extensions.h"
#include "mention.h"
#include "checkbox.h"
#include <libcmark_gfm/registry.h>
#include <libcmark_gfm/plugin.h>

static int gfm_extensions_registration(cmark_plugin *plugin) {
    cmark_plugin_register_syntax_extension(plugin, create_mention_extension());
    cmark_plugin_register_syntax_extension(plugin, create_checkbox_extension());
    return 1;
}

void gfm_extensions_ensure_registered(void) {
    static int registered = 0;

    if (!registered) {
        cmark_register_plugin(gfm_extensions_registration);
        registered = 1;
    }
}
