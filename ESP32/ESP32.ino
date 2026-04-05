#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <Arduino.h>
#include <BLEDevice.h>
#include <BLEAdvertising.h>
#include <uECC.h>
#include <crypto.h>
#include <MasterBeaconKey.h>
#include <AppleBLEPacket.h>

#define BLE_PACKET_SIZE 37 


static int RNG(uint8_t *dest, unsigned size) {
  // Use the least-significant bits from the ADC for an unconnected pin (or connected to a source of 
  // random noise). This can take a long time to generate random data if the result of analogRead(0) 
  // doesn't change very frequently.
  while (size) {
    uint8_t val = 0;
    for (unsigned i = 0; i < 8; ++i) {
      int init = analogRead(0);
      int count = 0;
      while (analogRead(0) == init) {
        ++count;
      }
      
      if (count == 0) {
         val = (val << 1) | (init & 0x01);
      } else {
         val = (val << 1) | (count & 0x01);
      }
    }
    *dest = val;
    ++dest;
    --size;
  }
  // NOTE: it would be a good idea to hash the resulting random data using SHA-256 or similar.
  return 1;
}

void dbg_print(String message){
  Serial.print("[>] ");
  Serial.print(message);
  Serial.println();
}

void print_key(uint8_t* key, int size){
  for (int i = 0; i < size; i++){
    Serial.print(key[i]);
    Serial.print(" ");
  }
  Serial.println();
}

MasterBeaconKey* initBeaconObject(uECC_RNG_Function rng_function){
  MasterBeaconKey* mbk = new MasterBeaconKey(&RNG);

  if (!(mbk->init_ECC_keys())){
    dbg_print("Failed to Generate Elliptic Curve Key Pair.");
    exit(1);
  }
  Serial.print("private key:\n");
  print_key(mbk->ecc_private_k, ECC_PRIVATE_KEY_LEN);

  Serial.print("public key:\n");
  print_key(mbk->ecc_public_k, ECC_PUBLIC_KEY_LEN);

  if (!(mbk->init_symmetric_key())){
    dbg_print("Failed to Generate Symmetric Key.");
    exit(1);
  }

  Serial.print("Symmetric key:\n");
  print_key(mbk->symmetric_k, SYMMETRIC_KEY_LEN);

  return mbk;
}

void setup() {
  Serial.begin(115200);
  delay(5000);
  dbg_print("Testing ECC");
  
  dbg_print("Initializing MasterBeaconKey");
  MasterBeaconKey* masterBeaconKey = initBeaconObject(&RNG);

  Serial.print("---------------------------------------------------------------------------------------------------------\n");
  BLEDevice::init("");
  dbg_print("BLEDevice initialized.");

  dbg_print("Initializing BLE Adverisment.");

  BLEAdvertising* pAdvertising = BLEDevice::getAdvertising();
  
  AppleBLEPacket* appleBLEPacket = new AppleBLEPacket();
  if (!appleBLEPacket->set_public_key(masterBeaconKey->ecc_public_k, ECC_PUBLIC_KEY_LEN/2)){ // taking only the X-coordinate of the public key
    dbg_print("Failed to set mac address.");
  }

  BLEAdvertisementData* advData = new BLEAdvertisementData();
  advData->addData((char*)(appleBLEPacket->packet_data));
  dbg_print("Data added to advData.");

  Serial.print("---------------------------------------------------------------------------------------------------------\n");
  dbg_print("final BLE packet:\n");
  uint8_t* macAddress = appleBLEPacket->macAddress;
  Serial.printf("Mac Address: %02x %02x %02x %02x %02x %02x\n", macAddress[0], macAddress[1], macAddress[2], macAddress[3], macAddress[4], macAddress[5]);

  char* buf = appleBLEPacket->packet_repr();
  for (int i = 0; i < APPLE_BLE_PACKET_LENGTH*2; i++){
    Serial.printf("%c", buf[i]);
    if ((i+1)%2 == 0)
      Serial.print(" ");
  }
  Serial.println();
  
  pAdvertising->setAdvertisementData(*advData);
  pAdvertising->start();

  dbg_print("Started Advertising.");
}

void loop() {
  // Serial.print("Just to PRINT\n");
}
