#include "dynamic_array.h"

void da_DynArray_init(struct DynArray *arr, size_t sz, size_t elem_sz) {
  arr->size = 0;
  arr->capacity = sz;
  arr->elem_size = elem_sz;
  arr->elems = malloc(sz*elem_sz);
}


void da_DynArray_del(struct DynArray *arr) {
  free(arr->elems);
}

void da_append(struct DynArray *arr, void *elem) {
  if (arr->size == arr->capacity) {
    arr->capacity *= DA_GROWTH_FACTOR;
    void *new = realloc(arr->elems, arr->capacity*arr->elem_size);
    if (!new) {//realloc failed
      return;
    }
    arr->elems = new;
  }
  memcpy(arr->elems + arr->size*arr->elem_size, elem, arr->elem_size);
  ++arr->size;
}

void da_pop(struct DynArray *arr) {
  --arr->size;
  if (arr->size / (double) arr->capacity <= DA_SHRINK_THRESHOLD) {
    arr->capacity *= DA_SHRINK_FACTOR;
    if (arr->capacity < 1)
      arr->capacity = 1;
    void *new = realloc(arr->elems, arr->capacity*arr->elem_size);
    if (!new)
      return;
    arr->elems = new;
  }
}

void da_get(struct DynArray *arr, int index, void *elem) {
   memcpy(elem, arr->elems + index*arr->elem_size, arr->elem_size);
}

void da_set(struct DynArray *arr, int index, void *elem) {
  memcpy(arr->elems + index*arr->elem_size, elem, arr->elem_size);
}
