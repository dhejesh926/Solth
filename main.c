// solth_embed.c
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include <luajit-2.1/lua.h>
#include <luajit-2.1/lauxlib.h>
#include <luajit-2.1/lualib.h>

int main(int argc, char **argv) {
    if (argc < 2) {
        printf("Usage: %s <solth_file> [args...]\n", argv[0]);
        return 1;
    }

    lua_State *L = luaL_newstate();    // Create Lua state
    if (!L) {
        fprintf(stderr, "Failed to create Lua state\n");
        return 1;
    }

    luaL_openlibs(L);                  // Open standard Lua libraries

    // Push command-line arguments into Lua as global 'arg'
    lua_newtable(L);  // arg table
    for (int i = 0; i < argc; i++) {
        lua_pushinteger(L, i);
        lua_pushstring(L, argv[i]);
        lua_settable(L, -3);
    }
    lua_setglobal(L, "arg");

    // Load solth.lua
    if (luaL_loadfile(L, "solth.lua") || lua_pcall(L, 0, 0, 0)) {
        fprintf(stderr, "Error loading solth.lua: %s\n", lua_tostring(L, -1));
        lua_close(L);
        return 1;
    }

    // Call solth:execute_file(arg[1])
    lua_getglobal(L, "solth");       // get solth table
    if (!lua_istable(L, -1)) {
        fprintf(stderr, "Error: 'solth' table not found in solth.lua\n");
        lua_close(L);
        return 1;
    }

    lua_getfield(L, -1, "execute_file");  // solth.execute_file
    lua_pushvalue(L, -2);                 // push solth table as self
    lua_pushstring(L, argv[1]);           // push filename
    if (lua_pcall(L, 2, 0, 0) != 0) {
        fprintf(stderr, "Error running Solth file: %s\n", lua_tostring(L, -1));
        lua_close(L);
        return 1;
    }

    lua_close(L);
    return 0;
}
