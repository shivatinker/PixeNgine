//
//  LuaWrapper.h
//  PixeNgine
//
//  Created by Andrii Zinoviev on 05.05.2020.
//  Copyright © 2020 Andrii Zinoviev. All rights reserved.
//

#ifndef LuaWrapper_h
#define LuaWrapper_h

#include "lua.h"
#include "lapi.h"
#include "lauxlib.h"
#include "lualib.h"
#include "lcode.h"
#include "lctype.h"
#include "ldebug.h"
#include "ldo.h"
#include "lfunc.h"
#include "lgc.h"
#include "llex.h"
#include "llimits.h"
#include "lmem.h"
#include "lobject.h"
#include "lopcodes.h"
#include "lparser.h"
#include "lprefix.h"
#include "lstate.h"
#include "lstring.h"
#include "ltable.h"
#include "ltm.h"
#include "luaconf.h"
#include "lundump.h"
#include "lvm.h"
#include "lzio.h"

void stackDump (lua_State *L);

#endif /* LuaWrapper_h */
