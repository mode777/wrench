OBJ = main.o os_call.o
OBJ_SDL = sdl.o
OBJ_JSON = json.o
OBJ_GLFW = glfw.o
OBJ_GLES2 = gles2.o
OBJ_NVG = wren_nanovg.o nanovg.o
OBJ_CURL = wren_curl.o
OBJ_WREN = wren_core.o wren_debug.o wren_primitive.o wren_utils.o wren_value.o wren_vm.o wren_compiler.o wren_opt_meta.o wren_opt_random.o

OBJ_NVG_DEMO=demo.o example_gles2.o nanovg.o

INCLUDES =-I./wren/src/include -I./wren/src/optional -I./wren/src/vm -I./include -I./nanovg/src

DLLFLAGS =-shared -Wl,-no-undefined -Wl,--enable-runtime-pseudo-reloc

VPATH = ./src ./wren/src/optional ./wren/src/vm ./nanovg/src ./nanovg/example

test.exe: test.o 
	gcc -o $@ test.o -L./lib -lcurl

wrench.exe: $(OBJ) $(OBJ_WREN)
	gcc -o $@ $(OBJ) $(OBJ_WREN)

nanovg_demo.exe: $(OBJ_NVG_DEMO)
	gcc -o $@ $(OBJ_NVG_DEMO) -L. -l:glfw3.dll -L./lib -l:libGLESv2.lib -l:libEGL.lib 
	cp nanovg_demo.exe nanovg/example/demo.exe

wren-sdl.dll: $(OBJ_SDL)
	gcc -o $@ $(OBJ_SDL) $(DLLFLAGS) -L. -l:SDL2.dll -L./lib -l:libEGL.lib
	cp $@ ./wren_modules/$@

wren-glfw.dll: $(OBJ_GLFW)
	gcc -o $@ $(OBJ_GLFW) $(DLLFLAGS) -L. -l:glfw3.dll -L./lib -l:libEGL.lib
	cp $@ ./wren_modules/$@

json.dll: $(OBJ_JSON)
	gcc -o $@ $(OBJ_JSON) $(DLLFLAGS)
	cp $@ ./wren_modules/$@

wren-gles2.dll: $(OBJ_GLES2)
	gcc -o $@ $(OBJ_GLES2) $(DLLFLAGS) -L. -l:libGLESv2.lib -L./lib
	cp $@ ./wren_modules/$@

wren-nanovg.dll: $(OBJ_NVG)
	gcc -o $@ $(OBJ_NVG) $(DLLFLAGS) -L. -l:libGLESv2.lib -L./lib
	cp $@ ./wren_modules/$@

wren-curl.dll: $(OBJ_CURL)
	gcc -o $@ $(OBJ_CURL) $(DLLFLAGS) -L. -l:libcurl.dll
	cp $@ ./wren_modules/$@

wren-rapidxml.dll: wren_rapidxml.o
	g++ -o $@ wren_rapidxml.o $(DLLFLAGS)
	cp $@ ./wren_modules/$@

wren_rapidxml.o: wren_rapidxml.cpp
	g++ -o $@ -c $< -fPIC -O3 -Wall $(INCLUDES) -DDEBUG -fpermissive

%.o: %.c
	gcc -o $@ -c $< -fPIC -O3 -Wall $(INCLUDES) -DDEBUG

clean:
	rm -f *.{o,bc,exe}
