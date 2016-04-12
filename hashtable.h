#ifndef __HASHTABLE_H
#define __HASHTABLE_H
#include <stdlib.h>
#include <stdbool.h>
#include <math.h>
#include <string.h>
#include <stdio.h>
#include "debug.h"


/* hashtable consists of 
 * hash_fn : the hash function
 * capacity : number of elements that can fit in the hashtable
 * size : the number of elements in the hashtable
 * key_sz : size of keys in bytes
 * value_sz : size of values in bytes
 * flags : bit array of flags indicating state of each bucket
 * keys : array for keys
 * values : array for values
 */
struct hashtable {
  unsigned int (*hash_fn)(void*);
  bool (*cmp)(void*, void*);
  int capacity;
  int size;
  size_t key_sz;
  size_t value_sz;
  int *flags;
  void *keys;
  void *values;
};

/* Initializes an uninitialized hashtable
 */
void ht_init(
  struct hashtable *htable,       //ptr to hashtable
  unsigned int (*hash_fn)(void*), //hash function
  bool (*cmp_fn)(void*, void*),   //key comparison function
  size_t key_sz,                  //key size
  size_t value_sz,                //value size
  int capacity                    //initial capacity
  );

/* Free memory held be hashtable
 * does NOT free memory held by the keys or values in the hashtable
 */
void ht_del(struct hashtable *htable);

/*  Looks up a key in a hashtable
 *  htable : ptr to the hashtable
 *  key : ptr to the key
 *  value : ptr to ptr to value
 *
 * If key is found *value is set to reference the value
 */
bool ht_get_ref(struct hashtable *htable, void *key, void **value);

/*
 */
void ht_insert(struct hashtable *htable, void *key, void *value);

/*
 */
void ht_rm(struct hashtable *htable, void *key);

/*
 */
void ht_set(struct hashtable *htable, void *key, void *value);

/*
 */
void ht_iters(struct hashtable *htable, void* *begin, void* *end);

/*
 */
void ht_rehash(struct hashtable *ht, int sz);

static const int ht_empty = 0;
static const int ht_dummy = 1;
static const int ht_active = 2;

int ht_status(int *flags, int i);
void ht_setstatus(int *flags, int i, int st);

unsigned int ptr64(void* s); //TODO implement
unsigned int ptr32(void* s);
unsigned int str_hash(void** s_ptr);
#endif
