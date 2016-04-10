#ifndef __MA_DYNAMIC_ARRAY_H
#define __MA_DYNAMIC_ARRAY_H
#include <stdlib.h>
#include <stdio.h>
#include <string.h>

struct DynArray {
  size_t size;
  size_t capacity;
  size_t elem_size;
  void *elems;
};

double DA_GROWTH_FACTOR = 1.5;
double DA_SHRINK_THRESHOLD = 0.3;
double DA_SHRINK_FACTOR = 0.75;

void da_DynArray_init(struct DynArray *arr, size_t sz, size_t elem_sz);

void da_DynArray_del(struct DynArray *arr);

void da_append(struct DynArray *arr, void *elem);

void da_pop(struct DynArray *arr);

void da_get(struct DynArray *arr, int index, void *elem);

void da_set(struct DynArray *arr, int index, void *elem);
#endif
