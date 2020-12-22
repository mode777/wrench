include objects.mk

INCLUDES =$(INCLUDES_COMMON) -I./include/linux

DLLFLAGS =-shared -Wl,-no-undefined -L/opt/vc/lib -L/usr/lib/arm-linux-gnueabihf -lm

all: wrench wren-sdl.so json.so wren-gles2.so wren-nanovg.so wren-curl.so wren-rapidxml.so wren-msgpack.so images.so threads.so buffers.so wren-msgpack.so file.so

wrench: $(OBJ) $(OBJ_WREN)
	gcc -o $@ $(OBJ) $(OBJ_WREN) -ldl -lm

wren-sdl.so: $(OBJ_SDL)
	gcc -o $@ $(OBJ_SDL) $(DLLFLAGS) -lSDL2 -lbrcmEGL -lbrcmGLESv2
	cp $@ ./wren_modules/$@

json.so: $(OBJ_JSON)
	gcc -o $@ $(OBJ_JSON) $(DLLFLAGS)
	cp $@ ./wren_modules/$@

wren-gles2.so: $(OBJ_GLES2)
	gcc -o $@ $(OBJ_GLES2) $(DLLFLAGS) -lbrcmGLESv2
	cp $@ ./wren_modules/$@

wren-nanovg.so: $(OBJ_NVG)
	gcc -o $@ $(OBJ_NVG) $(DLLFLAGS) -lbrcmGLESv2
	cp $@ ./wren_modules/$@

wren-curl.so: $(OBJ_CURL)
	gcc -o $@ $(OBJ_CURL) $(DLLFLAGS) -lcurl -lcrypto
	cp $@ ./wren_modules/$@

wren-rapidxml.so: wren_rapidxml.o
	g++ -o $@ wren_rapidxml.o $(DLLFLAGS)
	cp $@ ./wren_modules/$@

wren-msgpack.so: $(OBJ_MSGPACK)
	gcc -o $@ $(OBJ_MSGPACK) $(DLLFLAGS)
	cp $@ ./wren_modules/$@

wren_rapidxml.o: wren_rapidxml.cpp
	g++ -o $@ -c $< -fPIC -O3 -Wall $(INCLUDES) -fpermissive

buffers.so: $(OBJ_BUFFERS)
	gcc -o $@ $(OBJ_BUFFERS) $(DLLFLAGS)
	cp $@ ./wren_modules/$@

images.so: $(OBJ_IMAGE)
	gcc -o $@ $(OBJ_IMAGE) $(DLLFLAGS)
	cp $@ ./wren_modules/$@

file.so: $(OBJ_FILE)
	gcc -o $@ $(OBJ_IMAGE) $(DLLFLAGS)
	cp $@ ./wren_modules/$@

threads.so: $(OBJ_THREAD)
	gcc -o $@ $(OBJ_THREAD) $(DLLFLAGS) -L. -lSDL2
	cp $@ ./wren_modules/$@

%.o: %.c
	gcc -o $@ -c $< -fPIC -O3 -Wall $(INCLUDES)

clean:
	rm -f *.{o,bc,exe}
