#ifndef __HASHTABLE_H
#define __HASHTABLE_H
#include <stdlib.h>
#include <stdbool.h>

struct hashtable {
  int (*hash_fn)(void*);
  int capacity;
  int size;
  size_t key_sz;
  size_t value_sz;
  int *flags;
  void *keys;
  void *values;
};

void ht_init(struct hashtable *htable, int (*hash_fn)(void*), size_t key_sz, size_t value_sz, int capacity);

void ht_del(struct hashtable *htable);

bool ht_lookup(struct hashtable *htable, void *key, void* *value);

void ht_insert(struct hashtable *htable, void *key, void *value);

void ht_rm(struct hashtable *htable, void *key);

void ht_set(struct hashtable *htable, void *key, void *value);

void ht_iters(struct hashtable *htable, void* *begin, void* *end);

void ht_rehash(struct hashtable *ht, int sz);

static const int ht_empty = 0;
static const int ht_dummy = 1;
static const int ht_active = 2;

int ht_status(int *flags, int i);
void ht_setstatus(int *flags, int i, int st);
#endif
