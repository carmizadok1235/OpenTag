#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <Arduino.h>
// #include <BLEDevice.h>
// #include <BLEAdvertising.h>
#include <NimBLEDevice.h>
#include <uECC.h>
#include <crypto.h>
// #include <esp_gap_ble_api.h>
// #include <esp_mac.h>


#ifndef uECC_SUPPORTS_secp224r1
    #define uECC_SUPPORTS_secp224r1 1
#endif

// #define BLE_PACKET_SIZE 37 

#define ECC_PRIVATE_KEY_LEN 28
#define ECC_PUBLIC_KEY_LEN ECC_PRIVATE_KEY_LEN*2
#define SYMMETRIC_KEY_LEN 32

// Advertisement Key is 28 Bytes Long
// Packet Index Macros
#define MAC_ADDRESS_SIZE 6
#define ADVERTISEMENT_KEY_LENGTH 28
#define APPLE_BLE_PACKET_LENGTH 31
#define FIRST_6_BYTES_KEY_START_INDEX 0
#define FIRST_6_BYTES_KEY_END_PACKET_INDEX 6
#define PAYLOAD_LENGTH_PACKET_INDEX 0
#define ADVERTISEMENT_TYPE_PACKET_INDEX 1
#define COMPANY_ID_PACKET_STARTING_INDEX 2
#define COMPANY_ID_LENGTH 2
#define OF_TYPE_PACKET_INDEX 4
#define OF_DATA_LENGTH_PACKET_INDEX 5
#define BATTERY_LEVEL_STATUS_PACKET_INDEX 6
#define REMAINING_22_BYTES_KEY_START_PACKET_INDEX 7
#define REMAINING_22_BYTES_KEY_END_PACKET_INDEX 28
#define FIRST_BYTE_FIRST_2_BITS_PACKET_INDEX 29
#define HINT_PACKET_INDEX 30
#define KEY_OFFSET 1

// Packet Values Macros
#define PAYLOAD_LENGTH_VAL '\x1e'
#define ADVERTISEMENT_TYPE_VAL '\xff'
#define COMPANY_ID_VAL "\x4c\x00"
#define OF_TYPE_VAL '\x12'
#define OF_DATA_LENGTH_VAL '\x19'
#define BATTERY_LEVEL_STATUS_VAL '\x10'
#define HINT_VAL '\x00'

uECC_Curve curve;
uint8_t ecc_private_k[ECC_PRIVATE_KEY_LEN];
uint8_t ecc_public_k[ECC_PUBLIC_KEY_LEN];
uint8_t symmetric_k[SYMMETRIC_KEY_LEN];

uint8_t packet_data[APPLE_BLE_PACKET_LENGTH];
uint8_t macAddress[MAC_ADDRESS_SIZE];

NimBLEAdvertising* pAdvertising = nullptr;
NimBLEAdvertisementData* advData = nullptr;

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

void initMasterBeacon(){
  curve = uECC_secp224r1();
  uECC_set_rng(&RNG);

  if (!uECC_make_key(ecc_public_k, ecc_private_k, curve)){
    dbg_print("Failed to generate private-public key pair.");
    exit(1);
  }

  randomSeed(analogRead(A0));
  for (int i = 0; i < SYMMETRIC_KEY_LEN; i++){
    symmetric_k[i] = random(256); // 256 bytes 
  }
}

bool setPublicKey(uint8_t *key, int len){
  if (!key || len != ADVERTISEMENT_KEY_LENGTH){
    return false;
  }

  // BLE MAC Address (p[0] | 0b11 << 6 || p[1..5] where p is public key)
  for (int i = 0; i < MAC_ADDRESS_SIZE; i++){
    if (MAC_ADDRESS_SIZE-i == MAC_ADDRESS_SIZE){ // first byte
      macAddress[MAC_ADDRESS_SIZE-i-1] = key[i] | (0b11 << 6); // for some reason NimBLEDevice::setOwnAddr() setting the address in the opposite way
    }
    else{
      macAddress[MAC_ADDRESS_SIZE-i-1] = key[i];
    }
  }

  // esp_err_t ret = esp_base_mac_addr_set(macAddress);
  // esp_err_t ret = esp_ble_gap_set_rand_addr(macAddress);
  bool res1 = NimBLEDevice::setOwnAddrType(BLE_OWN_ADDR_RANDOM);
  bool res2 = NimBLEDevice::setOwnAddr(macAddress);
  if (!res1){
    Serial.println("Failed to setOwnAddrType");
    return false;
  }
  if (!res2){
    Serial.println("Failed to setOwnAddr");
  }

  // Public Key Bytes p[6..27]
  for (int i = REMAINING_22_BYTES_KEY_START_PACKET_INDEX; i < REMAINING_22_BYTES_KEY_END_PACKET_INDEX+1; i++){
    packet_data[i] = key[i-KEY_OFFSET];
  }

  // Public Key Bits p[0] >> 6
  packet_data[FIRST_BYTE_FIRST_2_BITS_PACKET_INDEX] = key[0] >> 6;

  return true;
}

void buildPacketStructure(){
  packet_data[PAYLOAD_LENGTH_PACKET_INDEX] = PAYLOAD_LENGTH_VAL; // Payload Length in Bytes (30)
  packet_data[ADVERTISEMENT_TYPE_PACKET_INDEX] = ADVERTISEMENT_TYPE_VAL; // Advertisement Type
  // Company ID (Apple)
  memcpy(packet_data+COMPANY_ID_PACKET_STARTING_INDEX, (uint8_t*)(COMPANY_ID_VAL), COMPANY_ID_LENGTH);
  // this->packet_data[8] = '\x00';
  // this->packet_data[9] = '\x4c'; 
  packet_data[OF_TYPE_PACKET_INDEX] = OF_TYPE_VAL; // OF Type
  packet_data[OF_DATA_LENGTH_PACKET_INDEX] = OF_DATA_LENGTH_VAL; // OF Data Length in Bytes (25)
  packet_data[BATTERY_LEVEL_STATUS_PACKET_INDEX] = BATTERY_LEVEL_STATUS_VAL; // Status (Battery Level)
  
  // packet_data[35] = '\x00'; // Public Key first byte's first two bits p[0] >> 6
  packet_data[HINT_PACKET_INDEX] = HINT_VAL; // Hint (0x00 on iOS Reports)
}

void initAppleBLEPacket(){
  memset(packet_data, 0, APPLE_BLE_PACKET_LENGTH); // cleaning the buffer
  memset(macAddress, 0, MAC_ADDRESS_SIZE);
  buildPacketStructure();
}

void printBytesRepr(std::vector<uint8_t> bytes){
  for (int i = 0; i < bytes.size(); i++){
    Serial.printf("%02X ", bytes[i]);
  }
  Serial.println();
}

void setup() {
  Serial.begin(115200);
  delay(5000);
  dbg_print("Testing ECC");
  
  dbg_print("Initializing MasterBeaconKey");
  initMasterBeacon();

  initAppleBLEPacket();

  // if (!appleBLEPacket->setPublicKey(masterBeaconKey->ecc_public_k, ECC_PUBLIC_KEY_LEN/2)){ // taking only the X-coordinate of the public key
  //   dbg_print("Failed to set mac address.");
  //   exit(1);
  // }

  // Serial.print("---------------------------------------------------------------------------------------------------------\n");
  NimBLEDevice::init("");
  // BLEDevice::init("");
  dbg_print("BLEDevice initialized.");
  dbg_print(NimBLEDevice::getAddress().toString().c_str());

  dbg_print("Initializing BLE Adverisment.");
  pAdvertising = NimBLEDevice::getAdvertising();
  
  advData = new NimBLEAdvertisementData();
}

void loop() {
  if (!setPublicKey(ecc_public_k, ECC_PUBLIC_KEY_LEN/2)){ // taking only the X-coordinate of the public key
    dbg_print("Failed to set public key");
  }

  advData->addData(packet_data, APPLE_BLE_PACKET_LENGTH);
  dbg_print("Data added to advData.");

  // Serial.print("---------------------------------------------------------------------------------------------------------\n");
  dbg_print("final BLE packet:\n");
  uint8_t* mAddr = macAddress;
  Serial.printf("Mac Address: %02x %02x %02x %02x %02x %02x\n", mAddr[5], mAddr[4], mAddr[3], mAddr[2], mAddr[1], mAddr[0]);
  printBytesRepr(advData->getPayload());
  
  pAdvertising->setAdvertisementData(*advData);
  pAdvertising->start();
  dbg_print("Started Advertising.");
  Serial.print("---------------------------------------------------------------------------------------------------------\n");
  delay(10000);
  pAdvertising->stop();
  dbg_print("Stopped Advertising");
  Serial.print("---------------------------------------------------------------------------------------------------------\n");
}
