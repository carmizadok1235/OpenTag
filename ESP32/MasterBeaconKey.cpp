#include <MasterBeaconKey.h>

#ifndef uECC_SUPPORTS_secp224r1
    #define uECC_SUPPORTS_secp224r1 1
#endif

MasterBeaconKey::MasterBeaconKey(uECC_RNG_Function rng_function){
  this->curve = uECC_secp224r1();
  uECC_set_rng(rng_function);
}

bool MasterBeaconKey::init_ECC_keys(){
  return uECC_make_key(ecc_public_k, ecc_private_k, curve);
}

bool MasterBeaconKey::init_symmetric_key(){
  try{
    randomSeed(analogRead(A0));
    for (int i = 0; i < SYMMETRIC_KEY_LEN; i++){
      symmetric_k[i] = random(256); // 256 bytes 
    }
    
    return true;

  } catch (int errorCode){
    Serial.printf("Error code: %d", errorCode);
    return false;
  }
}