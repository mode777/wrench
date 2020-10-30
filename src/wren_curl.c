#include "./wrt_plugin.h"
#include <curl/curl.h>
#include <stdlib.h>
#include <time.h>

#ifdef _WIN32
#define WAITMS(x) Sleep(x)
#else
/* Portable sleep for platforms other than Windows. */
#define WAITMS(x)                               \
  struct timeval wait = { 0, (x) * 1000 };      \
  (void)select(0, NULL, NULL, NULL, &wait);
#endif

int plugin_id;

typedef struct {
  WrenHandle* loopHandle;
  WrenHandle* callHandle_0;
} CurlWrenData;

static void wren_start(WrenVM* vm){
  CurlWrenData* cd = calloc(1, sizeof(CurlWrenData));

  cd->callHandle_0 = wrenMakeCallHandle(vm, "call()");

  wrt_set_plugin_data(vm, plugin_id, cd);
}

static bool success;
static WrenInterpretResult result = WREN_RESULT_COMPILE_ERROR;

static void wren_update(WrenVM* vm){
  CurlWrenData* cd = wrt_get_plugin_data(vm, plugin_id);

  wrenEnsureSlots(vm, 1);

  if(cd->loopHandle == NULL){
    wrenSetSlotBool(vm, 0, false);
    return;
  }

  wrenSetSlotHandle(vm, 0, cd->loopHandle);
  result = wrenCall(vm, cd->callHandle_0);
  success = wrenGetSlotBool(vm, 0);

  wrenSetSlotBool(vm, 0, result == WREN_RESULT_SUCCESS && success);
}

int id = 0;

typedef struct {
  CURL* handle;
  WrenHandle* wrenHandle;
  FILE* file;
  char* data;
  size_t size;
  size_t allocated;
  int id;
} CurlData;

static void wren_curl_CurlHandle_allocate(WrenVM* vm){
  CurlData* data = (CurlData*)wrenSetSlotNewForeign(vm, 0, 0, sizeof(CurlData));
  data->id = ++id;
  data->handle = curl_easy_init();
  //curl_easy_setopt(*handlePtr, CURLOPT_SSL_VERIFYPEER, 0L);
  //curl_easy_setopt(*handlePtr, CURLOPT_SSL_VERIFYHOST, 0L);
  curl_easy_setopt(data->handle, CURLOPT_PRIVATE, data);
}

static void dispose_curl_data(CurlData* data){
  if(data->data != NULL) free(data->data);
  if(data->file != NULL) fclose(data->file);
  if(data->handle != NULL) curl_easy_cleanup(data->handle);
  data->file = NULL;
  data->data = NULL;
  data->handle = NULL;
  data->size = 0;
}

static void wren_curl_CurlHandle_delete(void* data){
  dispose_curl_data((CurlData*)data);
}

static void wren_curl_CurlHandle_dispose_0(WrenVM* vm){
  CurlData* data = (CurlData*)wrenGetSlotForeign(vm, 0);
  dispose_curl_data(data);
}

static void wren_curl_CurlHandle_url_v(WrenVM* vm){
  CurlData* data = (CurlData*)wrenGetSlotForeign(vm, 0);
  const char* url = wrenGetSlotString(vm, 1);
  curl_easy_setopt(data->handle, CURLOPT_URL, url);
}

static void wren_curl_CurlHandle_caInfo_v(WrenVM* vm){
  CurlData* data = (CurlData*)wrenGetSlotForeign(vm, 0);
  const char* path = wrenGetSlotString(vm, 1);
  curl_easy_setopt(data->handle, CURLOPT_CAINFO, path);
}

static void wren_curl_CurlHandle_id(WrenVM* vm){
  CurlData* data = (CurlData*)wrenGetSlotForeign(vm, 0);
  wrenSetSlotDouble(vm, 0, data->id);
}

size_t curl_write_file(char *buffer, size_t sz, size_t nmemb, void *userdata){
  CurlData* data = (CurlData*)userdata;

  size_t rc = fwrite(buffer, sz, nmemb, data->file);

  return rc;
}

static void wren_curl_CurlHandle_writeFile_1(WrenVM* vm){
  CurlData* data = (CurlData*)wrenGetSlotForeign(vm, 0);
  const char* path = wrenGetSlotString(vm, 1);
  data->file = fopen(path, "wb");
  if(data->file == NULL) wren_runtime_error(vm, "Could not create file");
  curl_easy_setopt(data->handle, CURLOPT_WRITEDATA, data);
  curl_easy_setopt(data->handle, CURLOPT_WRITEFUNCTION, curl_write_file);
}

size_t curl_write_memory(void *contents, size_t size, size_t nmemb, void *userp)
{
  CurlData* data = (CurlData*)userp;
  
  size_t realsize = size * nmemb;
  size_t totalsize = data->size + realsize;

  if(totalsize > data->allocated){
    size_t newsize = data->allocated * 2;
    char *ptr = realloc(data->data, newsize);
    if(ptr == NULL) {
      /* out of memory! */ 
      return 0;
    }
    data->allocated = newsize;
    data->data = ptr;
  } 
 
  memcpy(&(data->data[data->size]), contents, realsize);
  data->size += realsize;
  //mem->memory[mem->size] = 0;
 
  return realsize;
}

static void wren_curl_CurlHandle_writeMemory_0(WrenVM* vm){
  CurlData* data = (CurlData*)wrenGetSlotForeign(vm, 0);
  data->allocated = 1024 * 16;
  data->data = malloc(data->allocated);
  data->size = 0;
  curl_easy_setopt(data->handle, CURLOPT_WRITEDATA, data);
  curl_easy_setopt(data->handle, CURLOPT_WRITEFUNCTION, curl_write_memory);
}

static void wren_curl_CurlHandle_getData_0(WrenVM* vm){
  CurlData* data = (CurlData*)wrenGetSlotForeign(vm, 0);
  if(data->data != NULL){
    wrenSetSlotBytes(vm, 0, data->data, data->size);
    data->size = 0;
    data->allocated = 0;
    free(data->data);
    data->data = NULL;
  } else {
    wrenSetSlotNull(vm, 0);
  }
}

static void wren_curl_CurlHandle_responseCode(WrenVM* vm){
  CurlData* data = (CurlData*)wrenGetSlotForeign(vm, 0);
  long responseCode;
  curl_easy_getinfo(data->handle, CURLINFO_RESPONSE_CODE, &responseCode);
  wrenSetSlotDouble(vm, 0, responseCode);
}


static void wren_curl_CurlMultiHandle_allocate(WrenVM* vm){
  CURLM** handlePtr = (CURLM**)wrenSetSlotNewForeign(vm, 0, 0, sizeof(CURLM*));
  *handlePtr = curl_multi_init();
}

static void wren_curl_CurlMultiHandle_delete(void* data){
  CURLM** handlePtr = (CURLM**)data;
  curl_multi_cleanup(*handlePtr);
}

static void wren_curl_CurlMultiHandle_addHandle_1(WrenVM* vm){
  CURLM* mhandle = *(CURLM**)wrenGetSlotForeign(vm, 0);
  CurlData* data = (CurlData*)wrenGetSlotForeign(vm, 1);
  data->wrenHandle = wrenGetSlotHandle(vm, 1);
  curl_multi_add_handle(mhandle, data->handle);
}

static void wren_curl_CurlMultiHandle_removeHandle_1(WrenVM* vm){
  CURLM* mhandle = *(CURLM**)wrenGetSlotForeign(vm, 0);
  CurlData* data = (CurlData*)wrenGetSlotForeign(vm, 1);
  if(data->wrenHandle != NULL){
    wrenReleaseHandle(vm, data->wrenHandle);
    data->wrenHandle = NULL;
  }
  curl_multi_remove_handle(mhandle, data->handle);
}

static void wren_curl_CurlMultiHandle_perform_0(WrenVM* vm){
  CURLM* mhandle = *(CURLM**)wrenGetSlotForeign(vm, 0);
  int running;
  CURLMcode err = curl_multi_perform(mhandle, &running);
  if(err != CURLM_OK){
     wren_runtime_error(vm, "perform() reported an error.");
  }
  wrenSetSlotDouble(vm, 0, running);
}

static void wren_curl_CurlMultiHandle_wait_1(WrenVM* vm){
  CURLM* mhandle = *(CURLM**)wrenGetSlotForeign(vm, 0);
  int timeout = wrenGetSlotDouble(vm, 1);
  int fds;
  CURLMcode err = curl_multi_wait(mhandle, NULL, 0, timeout, &fds);
  if(err != CURLM_OK){
     wren_runtime_error(vm, "wait() reported an error.");
  }
  wrenSetSlotDouble(vm, 0, fds);
}

static void wren_curl_CurlMultiHandle_readInfo_1(WrenVM* vm){
  CURLM* mhandle = *(CURLM**)wrenGetSlotForeign(vm, 0);
  CURLMsg** msg = (CURLMsg**)wrenGetSlotForeign(vm, 1);
  int left;
  *msg = curl_multi_info_read(mhandle, &left);
  wrenSetSlotBool(vm, 0, *msg != NULL);
}

static void wren_curl_CurlMessage_allocate(WrenVM* vm){
  wrenSetSlotNewForeign(vm, 0, 0, sizeof(CURLMsg*));
}

static void wren_curl_CurlMessage_delete(void* data){
  // OK
}

static void wren_curl_CurlMessage_getHandle_0(WrenVM* vm){
  CURLMsg* handlePtr = *(CURLMsg**)wrenGetSlotForeign(vm, 0);
  if(handlePtr->easy_handle == NULL){
    wrenSetSlotNull(vm, 0);
    return;
  }
  CurlData* cData;
  curl_easy_getinfo(handlePtr->easy_handle, CURLINFO_PRIVATE, &cData);
  wrenSetSlotHandle(vm, 0, cData->wrenHandle);
}

static void wren_curl_CurlMessage_isDone(WrenVM* vm){
  CURLMsg* handlePtr = *(CURLMsg**)wrenGetSlotForeign(vm, 0);
  if(handlePtr->easy_handle == NULL){
    wrenSetSlotNull(vm, 0);
    return;
  }
  wrenSetSlotBool(vm, 0, handlePtr->msg == CURLMSG_DONE);
}

static void wren_curl_CURL_runLoop_1(WrenVM* vm){
  CurlWrenData* cd = wrt_get_plugin_data(vm, plugin_id);

  if(cd->loopHandle != NULL){
    wrenReleaseHandle(vm, cd->loopHandle);
  }
  cd->loopHandle = wrenGetSlotHandle(vm, 1);
}

static void wren_curl_CURL_sleep_1(WrenVM* vm){
  int ms = wrenGetSlotDouble(vm, 1);
  WAITMS(ms);
}

static void wren_curl_CURL_clock(WrenVM* vm){
  clock_t c = clock();
  wrenSetSlotDouble(vm, 0, ((double)c / (double)CLOCKS_PER_SEC) * 1000);
}

void wrt_plugin_init(int handle){
  plugin_id = handle;
  curl_global_init(CURL_GLOBAL_DEFAULT);

  wrt_bind_class("wren-curl.CurlHandle", wren_curl_CurlHandle_allocate, wren_curl_CurlHandle_delete);
  wrt_bind_method("wren-curl.CurlHandle.url=(_)", wren_curl_CurlHandle_url_v);
  wrt_bind_method("wren-curl.CurlHandle.caInfo=(_)", wren_curl_CurlHandle_caInfo_v);
  wrt_bind_method("wren-curl.CurlHandle.id", wren_curl_CurlHandle_id);
  wrt_bind_method("wren-curl.CurlHandle.writeFile(_)", wren_curl_CurlHandle_writeFile_1);
  wrt_bind_method("wren-curl.CurlHandle.writeMemory()", wren_curl_CurlHandle_writeMemory_0);
  wrt_bind_method("wren-curl.CurlHandle.getData()", wren_curl_CurlHandle_getData_0);
  wrt_bind_method("wren-curl.CurlHandle.dispose()", wren_curl_CurlHandle_dispose_0);
  wrt_bind_method("wren-curl.CurlHandle.responseCode", wren_curl_CurlHandle_responseCode);

  wrt_bind_class("wren-curl.CurlMultiHandle", wren_curl_CurlMultiHandle_allocate, wren_curl_CurlMultiHandle_delete);
  wrt_bind_method("wren-curl.CurlMultiHandle.addHandle(_)", wren_curl_CurlMultiHandle_addHandle_1);
  wrt_bind_method("wren-curl.CurlMultiHandle.removeHandle(_)", wren_curl_CurlMultiHandle_removeHandle_1);
  wrt_bind_method("wren-curl.CurlMultiHandle.perform()", wren_curl_CurlMultiHandle_perform_0);
  wrt_bind_method("wren-curl.CurlMultiHandle.wait(_)", wren_curl_CurlMultiHandle_wait_1);
  wrt_bind_method("wren-curl.CurlMultiHandle.readInfo(_)", wren_curl_CurlMultiHandle_readInfo_1);

  wrt_bind_class("wren-curl.CurlMessage", wren_curl_CurlMessage_allocate, wren_curl_CurlMessage_delete);
  wrt_bind_method("wren-curl.CurlMessage.getHandle()", wren_curl_CurlMessage_getHandle_0);
  wrt_bind_method("wren-curl.CurlMessage.isDone", wren_curl_CurlMessage_isDone);

  wrt_bind_method("wren-curl.CURL.runLoop_(_)", wren_curl_CURL_runLoop_1);
  wrt_bind_method("wren-curl.CURL.sleep(_)", wren_curl_CURL_sleep_1);
  wrt_bind_method("wren-curl.CURL.clock", wren_curl_CURL_clock);

  wrt_wren_update_callback(wren_update);
}

void wrt_plugin_init_wren(WrenVM* vm){
  wren_start(vm);
}