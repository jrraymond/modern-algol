#include "hashtable.h"
#include <math.h>
#include <string.h>
#include <stdio.h>

/* A bucket can be in one of three states: empty, dummy, active.
 *  empty: no value in the bucket
 *  dummy: no value in bucket but should continue probing
 *  active: value in the bucket
 */

int ht_status(int *flags, int i) {
  return (flags[2*i/sizeof(int)]>>(2*i%sizeof(int)))&0x3;
}
void ht_setstatus(int *flags, int i, int st) {
  int mask = 0x3 << 2*i%sizeof(int);
  st = st << 2*i%sizeof(int);
  flags[2*i/sizeof(int)] = (flags[2*i/sizeof(int)] & ~mask) | (st & mask);
}

void ht_init(struct hashtable *htable, int (*hash_fn)(void*), size_t key_sz, size_t value_sz, int capacity) {
  htable->hash_fn = hash_fn;
  htable->capacity = capacity;
  htable->size = 0;
  htable->key_sz = key_sz;
  htable->value_sz = value_sz;
  htable->flags = calloc(2*ceil((double)capacity/sizeof(int)), sizeof(int));
  htable->keys = malloc(capacity*key_sz);
  htable->values = malloc(capacity*value_sz);
}


void ht_del(struct hashtable *htable) {
  free(htable->flags);
  free(htable->keys);
  free(htable->values);
}


bool ht_lookup(struct hashtable *htable, void *key, void* *value) {
  int k, ix, found;
  k = htable->hash_fn(key);
  found = false;
  for (int i=0; i<htable->capacity && !found; ++i) {
    ix = (k + i*i)%htable->capacity;
    int status = ht_status(htable->flags, ix);
    if (status == ht_active && !memcmp(htable->keys+ix*htable->key_sz, key, htable->key_sz)) {
      found = true;
    } else if (status == ht_empty) {
      return false;
    }
  }
  if (!found)
    return false;
  *value = htable->values+ix*htable->value_sz;
  return true;
}

void ht_rehash(struct hashtable *ht, int sz) {
  int old_c = ht->capacity;
  int *old_flags = ht->flags;
  void *old_keys = ht->keys;
  void *old_vals = ht->values;

  ht->flags = calloc(2*ceil((double)sz/sizeof(int)), sizeof(int));
  ht->keys = malloc(sz*ht->key_sz);
  ht->values = malloc(sz*ht->value_sz);
  ht->size = 0;
  ht->capacity = sz;
  for (int i=0; i<old_c; ++i) {
    if (ht_status(old_flags, i) == ht_active)
      ht_insert(ht, old_keys+i*ht->key_sz, old_vals+i*ht->value_sz);
  }
  free(old_flags);
  free(old_keys);
  free(old_vals);
}

void ht_insert(struct hashtable *htable, void *key, void *value) {
  int k, ix;
  k = htable->hash_fn(key);
  for (int i=0; i<htable->capacity; ++i) {
    ix = (k + i*i)%htable->capacity;
    if (ht_status(htable->flags, ix) != ht_active)
      break;
  }
  ht_setstatus(htable->flags, ix, ht_active);
  memcpy(htable->keys+ix*htable->key_sz, key, htable->key_sz);
  memcpy(htable->values+ix*htable->value_sz, value, htable->value_sz);
  ++htable->size;
  if ((double)htable->capacity*0.67 <= (double) htable->size)
    ht_rehash(htable, htable->capacity*2);
}


void ht_rm(struct hashtable *htable, void *key) {
  int k, ix, found;
  k = htable->hash_fn(key);
  found = false;
  for (int i=0; i<htable->capacity && !found; ++i) {
    ix = (k + i*i)%htable->capacity;
    if (ht_status(htable->flags, ix) == ht_active &&
       !memcmp(htable->keys+ix*htable->key_sz, key, htable->key_sz)) {
      ht_setstatus(htable->flags, ix, ht_dummy);
      found = true;
      --htable->size;
    }
  }
  if (htable->capacity > 8 && 0.1*(double)htable->capacity >= htable->size)
    ht_rehash(htable, htable->capacity/2);
}

void ht_set(struct hashtable *htable, void *key, void *value) {
  int k, ix, found;
  k = htable->hash_fn(key);
  found = 0;
  for (int i=0; i<htable->capacity && !found; ++i) {
    ix = (k + i*i)%htable->capacity;
    if (ht_status(htable->flags, ix) == ht_active &&
       !memcmp(htable->keys+ix*htable->key_sz, key, htable->key_sz))
      found = 1;
  }
  if (!found)
    return;
  memcpy(htable->values+ix*htable->value_sz, value, htable->value_sz);
}

void ht_iters(struct hashtable *htable, void* *begin, void* *end) {
  printf("UNIMPLEMENTED\n");
  exit(0);
}
