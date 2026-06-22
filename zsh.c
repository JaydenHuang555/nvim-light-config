
#include <stdlib.h>
#include <stddef.h>
typedef struct {
	char *built;
	size_t len, cap;
} complete_engine_t;

void complete_engine_init() {
	complete_engine_t engine;
	engine.cap = 1 << 4;
	engine.len = 0;
	engine.built = (char*)malloc(sizeof(char) * engine.cap);
}
