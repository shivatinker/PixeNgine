//
//  LuaWrapper.m
//  PixeNgine
//
//  Created by Andrii Zinoviev on 05.05.2020.
//  Copyright © 2020 Andrii Zinoviev. All rights reserved.
//

#import <Foundation/Foundation.h>

#include "LuaWrapper.h"

LUAMOD_API int luaopen_os (lua_State *L) {
  return 1;
}
