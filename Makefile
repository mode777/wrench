include objects.mk

INCLUDES =$(INCLUDES_COMMON) -I./include/win32

DLLFLAGS =-shared -Wl,-no-undefined -Wl,--enable-runtime-pseudo-reloc


all: wrench.exe wren-sdl.dll wren-glfw.dll json.dll wren-gles2.dll wren-nanovg.dll wren-curl.dll wren-rapidxml.dll images.dll threads.dll buffers.dll wren-msgpack.dll file.dll super16.dll

wrench.exe: $(OBJ) $(OBJ_WREN)
	gcc -o $@ $(OBJ) $(OBJ_WREN)

nanovg_demo.exe: $(OBJ_NVG_DEMO)
	gcc -o $@ $(OBJ_NVG_DEMO) -L. -l:glfw3.dll -L./lib -l:libGLESv2.lib -l:libEGL.lib 
	cp nanovg_demo.exe nanovg/example/demo.exe

wren-sdl.dll: $(OBJ_SDL)
	gcc -o $@ $(OBJ_SDL) $(DLLFLAGS) -L. -l:SDL2.dll
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
	gcc -o $@ $(OBJ_CURL) $(DLLFLAGS) -L. -l:libcurl.dll -l:libssl-1_1.dll -l:libcrypto-1_1.dll
	cp $@ ./wren_modules/$@

wren-rapidxml.dll: wren_rapidxml.o
	g++ -o $@ wren_rapidxml.o $(DLLFLAGS)
	cp $@ ./wren_modules/$@

wren-msgpack.dll: $(OBJ_MSGPACK)
	gcc -o $@ $(OBJ_MSGPACK) $(DLLFLAGS)
	cp $@ ./wren_modules/$@

buffers.dll: $(OBJ_BUFFERS)
	gcc -o $@ $(OBJ_BUFFERS) $(DLLFLAGS)
	cp $@ ./wren_modules/$@

images.dll: $(OBJ_IMAGE)
	gcc -o $@ $(OBJ_IMAGE) $(DLLFLAGS)
	cp $@ ./wren_modules/$@

threads.dll: $(OBJ_THREAD)
	gcc -o $@ $(OBJ_THREAD) $(DLLFLAGS) -L. -l:SDL2.dll
	cp $@ ./wren_modules/$@

wren_rapidxml.o: wren_rapidxml.cpp
	g++ -o $@ -c $< -fPIC -O3 -Wall $(INCLUDES) -DDEBUG -fpermissive

file.dll: $(OBJ_FILE)
	gcc -o $@ $(OBJ_FILE) $(DLLFLAGS)
	cp $@ ./wren_modules/$@

super16.dll: $(OBJ_SUPER16)
	gcc -o $@ $(OBJ_SUPER16) $(DLLFLAGS) -L. -l:libGLESv2.lib -L./lib
	cp $@ ./wren_modules/$@

nanovg.o: nanovg.c
	gcc -o $@ -c $< -fPIC -g -O0 -Wall $(INCLUDES) -DDEBUG -DNVG_NO_STB

%.o: %.c
	gcc -o $@ -c $< -fPIC -g -O0 -Wall $(INCLUDES) -DDEBUG

clean:
	rm -f *.{o,bc,exe}
