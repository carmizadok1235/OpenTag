#pragma once

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <Arduino.h>
#include <uECC.h>
#include <crypto.h>

#define ECC_PRIVATE_KEY_LEN 28
#define ECC_PUBLIC_KEY_LEN ECC_PRIVATE_KEY_LEN*2
#define SYMMETRIC_KEY_LEN 32

/*
----------- Notes for el ganador -----------
Key Pair Structure
A NIST P-224 key pair consists of a private key and a corresponding public key: 

Private Key (d): A randomly generated integer (scalar) selected from the interval [1, n-1], where 
n is the order of the curve's base point. The private key is 224 bits in length.

Public Key (p): A point (x, y) on the elliptic curve, computed as p = d * G, where G
is the base point (generator) of the curve. 
The public key is an elliptic curve point, generally expressed as a 224-bit x-coordinate and a 224-bit y-coordinate.
*/

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