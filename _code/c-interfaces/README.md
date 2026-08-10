---
title: c-interfaces
description: Method syntatic sugar for C functions
source: .
---

# C Interfaces

This is a proof-of-concept project that aims to bring the syntatic sugar from mechanisms like interfaces, methods and classes to C.

Small usage example:

```c
#include <assert.h>
#include <stdio.h>
#include <stdlib.h>

#define definitions

#include <stdbool.h>

#define self struct vector2_vtable
struct vector2_vtable {
    bool (*error)(self *);
    self (*orelse)(self *, const self);
    self (*add)(self *, const self);
    float x, y;
};

#define vector2(...)                                           \
    (const struct vector2_vtable) {                            \
        .add = vector2_impl_add, .error = vector2_impl_err,    \
        .orelse = vector2_impl_add_orelse_abort, ##__VA_ARGS__ \
    }

#define _vector2(...)                                                     \
    (const struct vector2_vtable) {                                       \
        .add = vector2_impl_add, .error = vector2_impl_err, ##__VA_ARGS__ \
    }

#define def static inline

def self vector2_impl_add(self *s, self x);

def bool vector2_impl_err(self *y);
def self vector2_impl_add_orelse_ok(self *x, const self y);
def self vector2_impl_add_orelse_err(self *x, const self y);
def self vector2_impl_add_orelse_abort(self *x, const self y);

#ifdef definitions
const struct vector2_vtable $vector2 = vector2();

def bool vector2_impl_err(self *y) {
    return y == NULL;
}

def self vector2_impl_add(self *s, const self x) {
    if (!s)
        return _vector2(.orelse = vector2_impl_add_orelse_err);
    else {
        s->x += x.x;
        s->y += x.y;
        return _vector2(.orelse = vector2_impl_add_orelse_ok);
    }
}

def self vector2_impl_add_orelse_ok(self *x, const self y) {
    return *x;
}

def self vector2_impl_add_orelse_err(self *x, const self y) {
    return y;
}

#include <stdlib.h>
def self vector2_impl_add_orelse_abort(self *x, const self y) {
    fprintf(stderr, "invalid orelse call\n");
    abort();
}
#else
extern const struct vector2_vtable $vector2;
#endif

#undef self

#define add(...) add(using, __VA_ARGS__)
#define err error(using)
#define orelse(...) orelse(using, __VA_ARGS__)

#define use(x) using = x

#define let __auto_type

int main(int argc, char *argv[]) {
    void *using;

    // Warning: __auto_type is a GNU extension. A portable approach would be:
    //
    // #define interface(name) __typeof__(const struct name##_vtable)
    let x = vector2(.x = 190.0, .y = 0.0 );
    let b = vector2(.x = 20.0, .y = 0.0 );

    use(&x); // expands in add()

    x.add(b).add(b); // use interface

    $vector2.add(b); // global

#define str $vector2
    str.add(b); // renamed global

    vector2().add(b); // init and use

    assert(x.x == 190.0 + (20.0 * 5.0));

    let z = vector2( .x = 0.0, .y = 0.0);

    {
        use(NULL);
        z = z.add(b).orelse(b); // add fails, return b
        assert(z.x == b.x);

        // try
        if (z.add(b).err) return 1;
    }

    abort(); // unreachable
}

// gcc main.c -O3 -flto -S
```

For the sane:

```c
// how to properly use vtables without losing sanity

#include <assert.h>
#include <stdio.h>
#include <stdlib.h>

#define definitions

#include <stdbool.h>

typedef struct {
    float x, y;
} Vector2;

typedef struct {
    float x, y, w;
} Vector3;

static inline Vector2 mylib_vector2_add(const Vector2 lhs, Vector2 rhs);
static inline Vector3 mylib_vector3_add(const Vector3 lhs, Vector3 rhs);

#define fn(x) __typeof__(x)
struct mylib {
    struct {
        fn(mylib_vector2_add) * add;
    } Vector2;
    struct {
        fn(mylib_vector3_add) * add;
    } Vector3;
};

#ifdef definitions
const struct mylib mylib = (const struct mylib){ .Vector2 = { .add = mylib_vector2_add },
                                                 .Vector3 = { .add = mylib_vector3_add } };
static inline Vector2 mylib_vector2_add(const Vector2 lhs, const Vector2 rhs) {
    return (Vector2){
        .x = lhs.x + rhs.x,
        .y = lhs.y + rhs.y,
    };
}

static inline Vector3 mylib_vector3_add(const Vector3 lhs, const Vector3 rhs) {
    return (Vector3){
        .x = lhs.x + rhs.x,
        .y = lhs.y + rhs.y,
        .w = lhs.w + rhs.w,
    };
}
#else
extern const struct mylib mylib;
#endif

#define use(name, n) static __typeof__(name) n = name

use(mylib.Vector2, vec2);

int main(int argc, char *argv[]) {
    use(mylib.Vector2, v);

    Vector2 x = { .x = 190.0, .y = 0.0 };
    Vector2 b = { .x = 20.0, .y = 0.0 };

    Vector2 t = vec2.add(x, b);
    Vector2 t2 = mylib.Vector2.add(t, v.add(x, b));

    assert(t2.x == 2 * (190.0 + 20.0));

    return 0;
}

// gcc main.c -O3 -flto -S
```

# License

This project is available as public-domain under the CC0 License.
