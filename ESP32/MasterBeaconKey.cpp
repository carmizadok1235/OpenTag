#include <MasterBeaconKey.h>

#ifndef uECC_SUPPORTS_secp224r1
    #define uECC_SUPPORTS_secp224r1 1
#endif

MasterBeaconKey::MasterBeaconKey(uECC_RNG_Function rng_function){
  this->curve = uECC_secp224r1();
  uECC_set_rng(rng_function);
}

bool MasterBeaconKey::init_ECC_keys(){
  if (!uECC_make_key(ecc_public_k, ecc_private_k, curve)){
    return false;
  }
  // Serial.print("private key:\n");
  // print_key(ecc_private_k, ECC_PRIVATE_KEY_LEN);

  // Serial.print("public key:\n");
  // print_key(ecc_public_k, ECC_PUBLIC_KEY_LEN);
  return true;
}

bool MasterBeaconKey::init_symmetric_key(){
  randomSeed(analogRead(A0));

  for (int i = 0; i < SYMMETRIC_KEY_LEN; i++){
    symmetric_k[i] = random(256);
  }
  // Serial.print("Symmetric key:\n");
  // print_key(symmetric_k, SYMMETRIC_KEY_LEN);
  return true;
}