#pragma once

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <Arduino.h>
#include <uECC.h>
#include <crypto.h>

#define ECC_PRIVATE_KEY_LEN 28
#define ECC_PUBLIC_KEY_LEN 28*2
#define SYMMETRIC_KEY_LEN 32

class MasterBeaconKey {
  public:
    uint8_t ecc_private_k[ECC_PRIVATE_KEY_LEN];

    uint8_t ecc_public_k[ECC_PUBLIC_KEY_LEN];
    
    uint8_t symmetric_k[SYMMETRIC_KEY_LEN];
    
    MasterBeaconKey(uECC_RNG_Function);
    
    bool init_ECC_keys();
    
    bool init_symmetric_key();
  private:
    uECC_Curve curve;
};