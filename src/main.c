#include <stdio.h>
#include <assert.h>
#include <wren.h>
#include <string.h>

// CAUTION: Do this only once
#define STB_DS_IMPLEMENTATION
#include <stb_ds.h>

#include "os_call.h"

#define WRT_SEND_API(T) apiFunc(#T, T)
#ifdef DEBUG
#define LOG(...) printf(__VA_ARGS__)
#else
#define LOG(...)
#endif

static const void error_fn(WrenVM *vm, WrenErrorType type, const char *module, int line, const char *message)
{  
  printf("Wren-Error in module '%s' line %i: %s\n", module, line, message);
}

static const void write_fn(WrenVM *vm, const char *text)
{
  printf("%s", text);
}

static char *read_file_string(const char *filename)
{
  FILE* file = fopen(filename, "rb");
  if(file == NULL){
    printf("File not found %s\n", filename);
    return NULL;
  }
  long old = ftell(file);
  long numbytes;
  fseek(file, 0L, SEEK_END);
  numbytes = ftell(file);
  fseek(file, old, SEEK_SET);
  char* buffer = (char*)malloc((numbytes+1) * sizeof(char));	
  size_t read = fread(buffer, sizeof(char), numbytes, file);
  buffer[(int)read] = 0;
  fclose(file);
  return buffer;
}

static char strbuffer[1024];
static char dllbuffer[1024];



typedef struct {
  char * key;
  WrenForeignMethodFn value;
} Binding;

typedef struct {
  char* key;
  WrenForeignClassMethods value;
} ClassBinding;

static Binding* bindings = NULL;
static ClassBinding* classBindings = NULL;

static char* getMethodName(const char* module, 
  const char* className, 
  bool isStatic, 
  const char* signature)
{
  int length = strlen(module) + strlen(className) + strlen(signature) + 3;
  char *str = (char*)malloc(length);
  sprintf(str, "%s.%s.%s", module, className, signature);
  return str;
}

static char* getClassName(const char* module, 
  const char* className)
{
  int length = strlen(module) + strlen(className) + 2;
  char *str = (char*)malloc(length);
  sprintf(str, "%s.%s", module, className);
  return str;
}

static WrenForeignMethodFn bindMethodFunc( 
  WrenVM* vm, 
  const char* module, 
  const char* className, 
  bool isStatic, 
  const char* signature) 
{
  if(strcmp(module, "random") == 0 || strcmp(module, "meta") == 0){
    return NULL;
  }
  char* fullName = getMethodName(module, className, isStatic, signature);
  WrenForeignMethodFn func = shget(bindings, fullName);
  free(fullName);
  return func;
}

WrenForeignClassMethods bindClassFunc( 
  WrenVM* vm, 
  const char* module, 
  const char* className)
{
  if(strcmp(module, "random") == 0 || strcmp(module, "meta") == 0){
    WrenForeignClassMethods wfcm ={0};
    return wfcm;
  }

  char* fullName = getClassName(module, className);
  
  int index = shgeti(classBindings, fullName);
  free(fullName);
  if(index == -1){
    WrenForeignClassMethods wfcm ={0};
    return wfcm;  
  }
  else {
    return classBindings[index].value;
  }
}

static void wrt_bind_method(const char* name, WrenForeignMethodFn func){
  shput(bindings, name, func);
}

static void wrt_bind_class(const char* name, WrenForeignMethodFn allocator, WrenFinalizerFn finalizer){
  WrenForeignClassMethods methods = {
    allocator = allocator,
    finalizer = finalizer
  };
  shput(classBindings, name, methods);
}



struct WrenCallbackNode {
  WrenForeignMethodFn callback;
  struct WrenCallbackNode* next;
};
typedef struct WrenCallbackNode WrenCallbackNode;
typedef struct {
  WrenCallbackNode* start;
  WrenCallbackNode* end;
}  WrenCallbackList;

static WrenCallbackList initCallbacks;
static WrenCallbackList updateCallbacks;

static void callbacks_push(WrenCallbackList* list, WrenCallbackNode* node){
  if(list->start == NULL && list->end == NULL){
      list->start = node;
      list->end = node;
  } else {
    list->end->next = node;
  }
}

static void wrt_wren_init_callback(WrenForeignMethodFn fn){
  WrenCallbackNode* cb = malloc(sizeof(WrenCallbackNode));
  cb->callback = fn;
  cb->next = NULL;

  callbacks_push(&initCallbacks, cb);
}

static void call_init_callbacks(WrenVM* vm) {
  WrenCallbackNode* current = initCallbacks.start;
  while(current != NULL){
    current->callback(vm);
    WrenCallbackNode* remove = current;
    current = current->next;
    free(remove);
  }
  initCallbacks.start = NULL;
  initCallbacks.end = NULL;
}

static void wrt_wren_update_callback(WrenForeignMethodFn fn){
  WrenCallbackNode* cb = malloc(sizeof(WrenCallbackNode));
  cb->callback = fn;
  cb->next = NULL;

  callbacks_push(&updateCallbacks, cb);
}

static void call_update_callbacks(WrenVM* vm) {
  WrenCallbackNode* current = updateCallbacks.start;
  WrenCallbackNode* prev = NULL;
  while(current != NULL){
    current->callback(vm);
    if(!wrenGetSlotBool(vm, 0)){
      if(current == updateCallbacks.end){
        updateCallbacks.end = prev;
      }      
      if(prev == NULL){
        updateCallbacks.start = current->next;        
      } else {
        prev->next = current->next;
      }
      WrenCallbackNode* remove = current;
      current = current->next;
      free(remove);
    }
  }
}



static void load_plugin(const char * name){
  void* handle = wrt_dlopen(name);
  if(handle == NULL){
    LOG("Could not load Plugin: %s\n", name);
    return;
  } 
  void (*initFunc)() = wrt_dlsym(handle, "wrt_plugin_init");
  assert(initFunc != NULL);
  void (*apiFunc)(const char*, void*) = wrt_dlsym(handle, "wrt_plugin_api");
  assert(apiFunc != NULL);
  
  WRT_SEND_API(wrenGetSlotCount);
  WRT_SEND_API(wrenEnsureSlots);
  WRT_SEND_API(wrenGetSlotType);
  WRT_SEND_API(wrenGetSlotBool);
  WRT_SEND_API(wrenGetSlotBytes);
  WRT_SEND_API(wrenGetSlotDouble);
  WRT_SEND_API(wrenGetSlotForeign);
  WRT_SEND_API(wrenGetSlotString);
  WRT_SEND_API(wrenGetSlotHandle);
  WRT_SEND_API(wrenSetSlotBool);
  WRT_SEND_API(wrenSetSlotBytes);
  WRT_SEND_API(wrenSetSlotDouble);
  WRT_SEND_API(wrenSetSlotNewForeign);
  WRT_SEND_API(wrenSetSlotNewList);
  WRT_SEND_API(wrenSetSlotNewMap);
  WRT_SEND_API(wrenSetSlotNull);
  WRT_SEND_API(wrenSetSlotString);
  WRT_SEND_API(wrenSetSlotHandle);
  WRT_SEND_API(wrenGetListCount);
  WRT_SEND_API(wrenGetListElement);
  WRT_SEND_API(wrenInsertInList);
  WRT_SEND_API(wrenGetMapCount);
  WRT_SEND_API(wrenGetMapContainsKey);
  WRT_SEND_API(wrenGetMapValue);
  WRT_SEND_API(wrenSetMapValue);
  WRT_SEND_API(wrenRemoveMapValue);
  WRT_SEND_API(wrenReleaseHandle);
  WRT_SEND_API(wrenAbortFiber);
  WRT_SEND_API(wrenMakeCallHandle);
  WRT_SEND_API(wrenCall);
  WRT_SEND_API(wrenGetVariable);

  WRT_SEND_API(wrt_bind_class);
  WRT_SEND_API(wrt_bind_method);
  WRT_SEND_API(wrt_wren_init_callback);
  WRT_SEND_API(wrt_wren_update_callback);

  initFunc();
}

static char* load_module_fn(WrenVM* vm, const char* name){
  //file
  if(name[0] == '.'){
    strcpy(strbuffer, name);
    strcat(strbuffer, ".wren");
  }
  //module
  else {
    strcpy(strbuffer, "./wren_modules/");
    strcat(strbuffer, name);
    strcpy(dllbuffer, strbuffer);
    strcat(dllbuffer, ".dll");
    load_plugin(dllbuffer);
    strcat(strbuffer, ".wren");
  }

  return read_file_string(strbuffer);
}

static WrenVM* init_wren(){
  WrenConfiguration config;
  wrenInitConfiguration(&config);
  
  config.errorFn = error_fn;
  config.writeFn = write_fn;
  config.loadModuleFn = load_module_fn;
    config.bindForeignMethodFn = bindMethodFunc;
  config.bindForeignClassFn = bindClassFunc;
  return wrenNewVM(&config); 
}

int main(int argc, char *argv[])
{  
  WrenVM* vm = init_wren();
  char* script;
  if(argc < 2){
    script = read_file_string("main.wren");
  }
  else {
    script = read_file_string(argv[1]);
  }
  assert(script != NULL);
  WrenInterpretResult result = wrenInterpret(vm, "main", script);
  free(script);
  if(result == WREN_RESULT_SUCCESS){
    call_init_callbacks(vm);
    while(updateCallbacks.start != NULL){
      call_update_callbacks(vm);
    }
  }
  return 0;
}