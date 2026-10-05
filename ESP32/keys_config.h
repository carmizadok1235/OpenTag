
#if __has_include("user_keys.h")
    #include "user_keys.h"
    #if defined(PRIVATE_KEY) && defined(SYMMETRIC_KEY)
        #define KEYS_DEFINED 1
    #else
        #error "user_keys.h must define both PRIVATE_KEY and SYMMETRIC_KEY"
    #endif
#else
    #define KEYS_DEFINED 0
#endif