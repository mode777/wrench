OBJ = main.o os_call.o mutex.o
OBJ_SDL = sdl.o
OBJ_JSON = json.o
OBJ_GLFW = glfw.o
OBJ_GLES2 = gles2.o
OBJ_NVG = wren_nanovg.o nanovg.o
OBJ_CURL = wren_curl.o
OBJ_WREN = wren_core.o wren_debug.o wren_primitive.o wren_utils.o wren_value.o wren_vm.o wren_compiler.o wren_opt_meta.o wren_opt_random.o
OBJ_NVG_DEMO=demo.o example_gles2.o nanovg.o
OBJ_MSGPACK=wren_msgpack.o objectc.o unpack.o version.o vrefbuffer.o zone.o 
OBJ_BUFFERS=wren_buffers.o
OBJ_IMAGE=wren_image.o
OBJ_THREAD=sdl_thread.o
OBJ_FILE=file.o
OBJ_SUPER16=super16.o

INCLUDES_COMMON =-I./wren/src/include -I./wren/src/optional -I./wren/src/vm -I./include -I./include/common -I./nanovg/src -I./msgpack-c/include
VPATH = ./src ./wren/src/optional ./wren/src/vm ./nanovg/src ./nanovg/example ./msgpack-c/src
