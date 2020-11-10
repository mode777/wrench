include objects.mk

INCLUDES =-I./wren/src/include -I./wren/src/optional -I./wren/src/vm -I./include -I./include/linux -I./include/common -I./nanovg/src

DLLFLAGS =-shared -Wl,-no-undefined -L/opt/vc/lib -L/usr/lib/arm-linux-gnueabihf -lm

VPATH = ./src ./wren/src/optional ./wren/src/vm ./nanovg/src

all: wrench wren-sdl.so json.so wren-gles2.so wren-nanovg.so wren-curl.so wren-rapidxml.so

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
	gcc -o $@ $(OBJ_CURL) $(DLLFLAGS) -lcurl
	cp $@ ./wren_modules/$@

wren-rapidxml.so: wren_rapidxml.o
	g++ -o $@ wren_rapidxml.o $(DLLFLAGS)
	cp $@ ./wren_modules/$@

wren-msgpack.so: $(OBJ_MSGPACK)
	gcc -o $@ $(OBJ_MSGPACK) $(DLLFLAGS)
	cp $@ ./wren_modules/$@

wren_rapidxml.o: wren_rapidxml.cpp
	g++ -o $@ -c $< -fPIC -O3 -Wall $(INCLUDES) -fpermissive

%.o: %.c
	gcc -o $@ -c $< -fPIC -O3 -Wall $(INCLUDES)

clean:
	rm -f *.{o,bc,exe}
