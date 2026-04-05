#pragma once

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <Arduino.h>
#include <esp_gap_ble_api.h>

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
#define COMPANY_ID_VAL "\x00\x4c"
#define OF_TYPE_VAL '\x12'
#define OF_DATA_LENGTH_VAL '\x19'
#define BATTERY_LEVEL_STATUS_VAL '\x10'
#define HINT_VAL '\x00'

class AppleBLEPacket {
  public:
    uint8_t* packet_data;
    uint8_t* macAddress;
    
    AppleBLEPacket();

    ~AppleBLEPacket();
    
    bool set_public_key(uint8_t* key, int len);

    char* packet_repr();
  private:
    void build_packet_structure();

};