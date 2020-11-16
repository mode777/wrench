#include "./wrt_plugin.h"
#include <curl/curl.h>
#include <stdlib.h>
#include <time.h>
#include <stdint.h>

int plugin_id;

typedef struct {
  CURL* handle;
  WrenHandle* wrenHandle;
  FILE* file;
  char* data;
  size_t size;
  size_t allocated;
  unsigned int id;
} CurlData;

static void wren_curl_CurlHandle_allocate(WrenVM* vm){
  CurlData* data = (CurlData*)wrenSetSlotNewForeign(vm, 0, 0, sizeof(CurlData));
  // TODO: Is this pointer hashing safe (enough)?
  data->id =((uintptr_t)data) % UINT_MAX;
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
  data->allocated = 0;
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

static void wren_curl_CurlHandle_followRedirects_v(WrenVM* vm){
  CurlData* data = (CurlData*)wrenGetSlotForeign(vm, 0);
  bool opt = wrenGetSlotBool(vm, 1);
  curl_easy_setopt(data->handle, CURLOPT_FOLLOWLOCATION, opt ? 1 : 0);
}

static void wren_curl_CurlHandle_timeout_v(WrenVM* vm){
  CurlData* data = (CurlData*)wrenGetSlotForeign(vm, 0);
  long timeout = wrenGetSlotDouble(vm, 1);
  curl_easy_setopt(data->handle, CURLOPT_TIMEOUT, timeout);
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

  while((totalsize+1) > data->allocated){
    size_t newsize = data->allocated * 2;
    char *ptr = realloc(data->data, newsize);
    if(ptr == NULL) {
      /* out of memory! */ 
      return 0;
    }
    data->allocated = newsize;
    data->data = ptr;
    //memset(&data->data[data->size], 0, data->allocated - data->size);
  } 
 
  memcpy(&(data->data[data->size]), contents, realsize);
  data->size += realsize;
  data->data[data->size] = 0;
 
  return realsize;
}

static void wren_curl_CurlHandle_writeMemory_0(WrenVM* vm){
  CurlData* data = (CurlData*)wrenGetSlotForeign(vm, 0);
  data->allocated = 1024 * 16;
  data->data = calloc(1, data->allocated);
  data->size = 0;
  curl_easy_setopt(data->handle, CURLOPT_WRITEDATA, data);
  curl_easy_setopt(data->handle, CURLOPT_WRITEFUNCTION, curl_write_memory);
}

typedef struct {
  size_t size;
  char* data;
} Buffer;

static void wren_curl_CurlHandle_getData_1(WrenVM* vm){
  CurlData* data = (CurlData*)wrenGetSlotForeign(vm, 0);
  Buffer* buffer = (Buffer*)wrenGetSlotForeign(vm, 1);
  if(data->data != NULL){
    buffer->data = data->data;
    buffer->size = data->size;
    data->data = NULL;
    data->size = 0;
    data->allocated = 0;
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

void wrt_plugin_init(int handle){
  plugin_id = handle;
  curl_global_init(CURL_GLOBAL_DEFAULT);

  wrt_bind_class("wren-curl.CurlHandle", wren_curl_CurlHandle_allocate, wren_curl_CurlHandle_delete);
  wrt_bind_method("wren-curl.CurlHandle.url=(_)", wren_curl_CurlHandle_url_v);
  wrt_bind_method("wren-curl.CurlHandle.caInfo=(_)", wren_curl_CurlHandle_caInfo_v);
  wrt_bind_method("wren-curl.CurlHandle.followRedirects=(_)", wren_curl_CurlHandle_followRedirects_v);
  wrt_bind_method("wren-curl.CurlHandle.timeout=(_)", wren_curl_CurlHandle_timeout_v);
  wrt_bind_method("wren-curl.CurlHandle.id", wren_curl_CurlHandle_id);
  wrt_bind_method("wren-curl.CurlHandle.writeFile(_)", wren_curl_CurlHandle_writeFile_1);
  wrt_bind_method("wren-curl.CurlHandle.writeMemory()", wren_curl_CurlHandle_writeMemory_0);
  wrt_bind_method("wren-curl.CurlHandle.getData_(_)", wren_curl_CurlHandle_getData_1);
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
}



void wrt_plugin_init_wren(WrenVM* vm){

}