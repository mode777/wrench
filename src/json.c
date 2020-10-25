#include "./wrt_plugin.h"

#include <stdlib.h>
#include <jsmn.h>

#define pgl_wren_new(vm, T) (T*)wrenSetSlotNewForeign(vm, 0, 0, sizeof(T));



#define PGL_JSON_START_TOKENS 1024

typedef struct PGLJSONParser_T PGLJSONParser;

typedef enum {
  PGL_JSON_UNDEFINED = 0,
	PGL_JSON_OBJECT = 1,
	PGL_JSON_ARRAY = 2,
	PGL_JSON_STRING = 3,
	PGL_JSON_NULL = 4,
	PGL_JSON_NUMBER = 5,
  PGL_JSON_BOOLEAN = 6
} PGLJSONToken;

struct PGLJSONParser_T {
  const char * content;
  jsmntok_t* tokens;
  size_t num_tokens;
  int index;
  jsmntok_t token;
};

PGLJSONParser* pglJsonCreateParser(const char* content){
  jsmn_parser parser;
  jsmn_init(&parser);

  size_t num_tokens = PGL_JSON_START_TOKENS;
  jsmntok_t* tokens = malloc(num_tokens * sizeof(jsmntok_t));
  int tokensParsed;
  size_t contentLength = strlen(content);

  while((tokensParsed = jsmn_parse(&parser, content, contentLength, tokens, num_tokens)) == JSMN_ERROR_NOMEM){
    num_tokens *= 2;
    tokens = realloc(tokens, num_tokens * sizeof(jsmntok_t));
  }

  if(tokensParsed == JSMN_ERROR_INVAL || tokensParsed == JSMN_ERROR_PART){
    printf("Invalid JSON input\n");
    return NULL;
  }

  PGLJSONParser* inst = calloc(1, sizeof(PGLJSONParser));
  inst->content = content;
  inst->num_tokens = tokensParsed;
  inst->index = -1;
  inst->tokens = tokens;
  
  return inst;
}

void pglJsonDestroyParser(PGLJSONParser* parser){
  free(parser->tokens);
  free(parser);
}

bool pglJsonGetBoolVal(PGLJSONParser* parser){
  return parser->content[parser->token.start] == 't' 
    ? true
    : false; 
}

double pglJsonGetDoubleVal(PGLJSONParser* parser){
  return strtod(&parser->content[parser->token.start], NULL);
}

char* pglJsonGetStringVal(PGLJSONParser* parser){
  int start = parser->token.start;
  int size = parser->token.end - start;

  char * buffer = malloc(size + 1);

  strncpy(buffer, (parser->content + start), size);

  buffer[size] = 0;

  return buffer;
}

size_t pglJsonGetChildTokens(PGLJSONParser* parser) {
  return parser->token.size;
}

PGLJSONToken pglJsonGetToken(PGLJSONParser* parser) {
  switch (parser->token.type) {
    case JSMN_UNDEFINED: return PGL_JSON_UNDEFINED;
    case JSMN_OBJECT: return PGL_JSON_OBJECT;
    case JSMN_ARRAY: return PGL_JSON_ARRAY;
    case JSMN_STRING: return PGL_JSON_STRING;
    case JSMN_PRIMITIVE: {
      switch(parser->content[parser->token.start]){
        case 't':
        case 'f': return PGL_JSON_BOOLEAN;
        case 'n': return PGL_JSON_NULL;
        case '-':
        case '0':
        case '1':
        case '2':
        case '3':
        case '4':
        case '5':
        case '6':
        case '7':
        case '8':
        case '9': return PGL_JSON_NUMBER;
        default: return PGL_JSON_UNDEFINED;
      }
    }
    default: return PGL_JSON_UNDEFINED;
  }
}

bool pglJsonNextToken(PGLJSONParser* parser){
  if(parser->index < (int)parser->num_tokens){
    parser->token = parser->tokens[parser->index++];
    return true;
  }
  return false;
}

typedef struct {
  PGLJSONParser* parser;
  void* contentHandle;
  WrenVM* vm;
} JsonParserData;

static void JSONParser_allocate(WrenVM* vm){
  JsonParserData* parserData = pgl_wren_new(vm, JsonParserData); 
  const char* content = wrenGetSlotString(vm, 1); 
  parserData->contentHandle = wrenGetSlotHandle(vm, 1);
  parserData->parser = pglJsonCreateParser(content);  
  parserData->vm = vm;
  if(parserData->parser == NULL){
    wren_runtime_error(vm, "Invalid JSON");
  }
}

static void JSONParser_finalize(void* handle){
  JsonParserData* data = (JsonParserData*)handle;
  pglJsonDestroyParser(data->parser);
  wrenReleaseHandle(data->vm, data->contentHandle);
}

static void JSONParser_getValue_0(WrenVM* vm){
    JsonParserData* data = (JsonParserData*)wrenGetSlotForeign(vm, 0);
    switch (pglJsonGetToken(data->parser))
    {
      case PGL_JSON_NUMBER: 
        wrenSetSlotDouble(vm, 0, pglJsonGetDoubleVal(data->parser));
        break;
      case PGL_JSON_STRING: {
        char* str = pglJsonGetStringVal(data->parser);
        wrenSetSlotString(vm, 0, str);
        free(str);
        break;      
      }
      case PGL_JSON_BOOLEAN: 
        wrenSetSlotBool(vm, 0, pglJsonGetBoolVal(data->parser));
        break;
      case PGL_JSON_NULL:
        wrenSetSlotNull(vm, 0);
        break;
      default:
        wren_runtime_error(vm, "Current token is not a primitive value type");
        break;
  } 
}

static void JSONParser_getToken_0(WrenVM* vm){
  JsonParserData* data = (JsonParserData*)wrenGetSlotForeign(vm, 0);
  wrenSetSlotDouble(vm, 0, (double)pglJsonGetToken(data->parser));
}

static void JSONParser_nextToken_0(WrenVM* vm){
  JsonParserData* data = (JsonParserData*)wrenGetSlotForeign(vm, 0);
  wrenSetSlotBool(vm, 0, pglJsonNextToken(data->parser));
}

static void JSONParser_getChildren_0(WrenVM* vm){
  JsonParserData* data = (JsonParserData*)wrenGetSlotForeign(vm, 0);
  wrenSetSlotDouble(vm, 0, (double)pglJsonGetChildTokens(data->parser));
}

void wrt_plugin_init(){
  wrt_bind_class("json.JsonParser", JSONParser_allocate, JSONParser_finalize);
  wrt_bind_method("json.JsonParser.getValue()", JSONParser_getValue_0);
  wrt_bind_method("json.JsonParser.getToken()", JSONParser_getToken_0);
  wrt_bind_method("json.JsonParser.nextToken()", JSONParser_nextToken_0);
  wrt_bind_method("json.JsonParser.getChildren()", JSONParser_getChildren_0);
}
