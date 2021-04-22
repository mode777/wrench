include objects.mk

all: wrench.wasm wren-sdl.wasm

WOBJ = $(OBJ:.o=.bc)
WOBJ_WREN = $(OBJ_WREN:.o=.bc)

wren-sdl.wasm: MODULE=SIDE_MODULE
wrench.wasm: MODULE=MAIN_MODULE


wrench.wasm: $(WOBJ) $(WOBJ_WREN)
	emcc -o main.html $(WOBJ) $(WOBJ_WREN) -s WASM=1 -s MAIN_MODULE=1 -s EXPORT_ALL=1 -s --shell-file html/template.html --preload-file wren_modules --preload-file assets --preload-file main.wren

WOBJ_SDL = $(OBJ_SDL:.o=.bc)

wren-sdl.wasm: $(WOBJ_SDL)
	emcc -o $@ $(WOBJ_SDL) -s WASM=1 -s USE_SDL=2
	cp $@ ./wren_modules/$@


%.bc: %.c
	emcc -o $@ -c $< -fPIC -O3 $(INCLUDES_COMMON) -s EXPORT_ALL=1 -s $(MODULE)=1