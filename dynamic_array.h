#ifndef __MA_DYNAMIC_ARRAY_H
#define __MA_DYNAMIC_ARRAY_H
#include <stdlib.h>
#include <stdio.h>
#include <string.h>

/* Dynamically resizing arrays
 *  size : size_t, the number of elements in the array
 *  capacity : size_t, the number elements that can fit
 *  elem_size : size_t, the size of each element
 *  elems : void*, ptr to array containing elems
 */
struct DynArray {
  size_t size;
  size_t capacity;
  size_t elem_size;
  void *elems;
};

/* arr : ptr to uninitialized dynamic array struct
 * sz : initial capacity
 * elem_sz : size of element to be held in array in bytes
 */
void da_DynArray_init(struct DynArray *arr, size_t sz, size_t elem_sz);

/* arr : ptr to initialized dynamic array struct
 * frees memory held by arr
 */
void da_DynArray_del(struct DynArray *arr);

/* arr : ptr to dynamic array struct
 * elem : ptr to elem to append
 * _copys_ elem to the end of the array
 * may resize dynamic array if size == capacity
 */
void da_append(struct DynArray *arr, void *elem);

/* arr : ptr to dynamic array struct
 * removes element from end of array
 * may call realloc if size/capacity <= shrink threshold
 */
void da_pop(struct DynArray *arr);

/* arr : ptr to dynamic array struct
 * index : index of element to get
 * elem* : ptr of where to copy element into
 * _copys_ element at index into elem
 */
void da_get(struct DynArray *arr, int index, void *elem);

/* arr : ptr to dynamic array struct
 * index : index of element to set
 * elem* : ptr to element to _copy_ from
 */
void da_set(struct DynArray *arr, int index, void *elem);
#endif
