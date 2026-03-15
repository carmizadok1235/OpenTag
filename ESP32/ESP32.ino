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

// char* packet_data = (char*)malloc(sizeof(char)*37);

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

// *packet_data = {
//   '\x00', '\x00', '\x00', '\x00', '\x00', '\x00', // BLE MAC Address (p[0] | 0b11 << 6 || p[1..5] where p is public key)
//   '\x1e', //Payload Length in Bytes (30)
//   '\xff', // Advertisment Type
//   '\x00', '\x4c', // Company ID (Apple)
//   '\x12', // OF Type
//   '\x19', // OF Data Length in Bytes (25)
//   '\x00', // Status (Battery Level)
//   '\x00', '\x00', '\x00', '\x00', '\x00', '\x00', '\x00', '\x00', '\x00', '\x00', '\x00', '\x00', // Public Key Bytes p[6..27]
//   '\x00', '\x00', '\x00', '\x00', '\x00', '\x00', '\x00', '\x00', '\x00', '\x00',
//   '\x00', // Public Key Bits p[0] >> 6
//   '\x00' // Hint (0x00 on iOS Reports)
// };

void setup() {
  Serial.begin(115200);
  delay(5000);
  dbg_print("Testing ECC");
  dbg_print("Initializing MasterBeaconKey");
  MasterBeaconKey* masterBeaconKey = new MasterBeaconKey(&RNG);


  if (!(masterBeaconKey->init_ECC_keys())){
    dbg_print("Failed to Generate Elliptic Curve Key Pair.");
    exit(1);
  }
  Serial.print("private key:\n");
  print_key(masterBeaconKey->ecc_private_k, ECC_PRIVATE_KEY_LEN);

  Serial.print("public key:\n");
  print_key(masterBeaconKey->ecc_public_k, ECC_PUBLIC_KEY_LEN);

  masterBeaconKey->init_symmetric_key();
  Serial.print("Symmetric key:\n");
  print_key(masterBeaconKey->symmetric_k, SYMMETRIC_KEY_LEN);
  Serial.print("---------------------------------------------------------------------------------------------------------\n");

  dbg_print("Initializing BLE Adverisment.");

  BLEDevice::init("");
  dbg_print("BLEDevice initialized.");

  BLEAdvertising* pAdvertising = BLEDevice::getAdvertising();
  dbg_print("BLEAdvertising initialized.");

  // char* packet_data = (char*)malloc(sizeof(char)*37);
  AppleBLEPacket* appleBLEPacket = new AppleBLEPacket();
  dbg_print("initialized AppleBLEPacket.");

  // build_packet_data(packet_data, masterBeaconKey->ecc_public_k);
  appleBLEPacket->set_public_key(masterBeaconKey->ecc_public_k);
  dbg_print("packet_data built.");

  BLEAdvertisementData* advData = (BLEAdvertisementData*)malloc(sizeof(BLEAdvertisementData));
  advData->addData(appleBLEPacket->packet_data);
  dbg_print("Data added to advData.");

  
  pAdvertising->setAdvertisementData(*advData);
  pAdvertising->start();

  dbg_print("Started Advertising.");
}

void loop() {
  // Serial.print("Just to PRINT\n");
}
