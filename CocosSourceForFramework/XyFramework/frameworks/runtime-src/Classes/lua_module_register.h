#ifndef __LUA_TEMPLATE_RUNTIME_FRAMEWORKS_RUNTIME_SRC_CLASSES_LUA_MODULE_REGISTER_H__
#define __LUA_TEMPLATE_RUNTIME_FRAMEWORKS_RUNTIME_SRC_CLASSES_LUA_MODULE_REGISTER_H__

#include "lua.h"
#include "Lua-BindingsExport.h"

#define lua_module_register lua_lua_module_register

CC_LUA_DLL  int  lua_module_register(lua_State* L);

#endif  // __LUA_TEMPLATE_RUNTIME_FRAMEWORKS_RUNTIME_SRC_CLASSES_LUA_MODULE_REGISTER_H__

