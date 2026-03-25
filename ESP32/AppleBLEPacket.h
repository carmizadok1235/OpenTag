#pragma once

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <Arduino.h>

// Advertisement Key is 28 Bytes Long
// Packet Index Macros
#define ADVERTISEMENT_KEY_LENGTH 28
#define APPLE_BLE_PACKET_LENGTH 37
#define FIRST_6_BYTES_KEY_START_INDEX 0
#define FIRST_6_BYTES_KEY_END_PACKET_INDEX 6
#define PAYLOAD_LENGTH_PACKET_INDEX 6
#define ADVERTISEMENT_TYPE_PACKET_INDEX 7
#define COMPANY_ID_PACKET_STARTING_INDEX 8
#define COMPANY_ID_LENGTH 2
#define OF_TYPE_PACKET_INDEX 10
#define OF_DATA_LENGTH_PACKET_INDEX 11
#define BATTERY_LEVEL_STATUS_PACKET_INDEX 12
#define REMAINING_22_BYTES_KEY_START_PACKET_INDEX 13
#define REMAINING_22_BYTES_KEY_END_PACKET_INDEX REMAINING_22_BYTES_START_PACKET_INDEX+(ADVERTISEMENT_KEY_LENGTH-FIRST_6_BYTES_END_PACKET_INDEX)
#define FIRST_BYTE_FIRST_2_BITS_PACKET_INDEX 35
#define HINT_PACKET_INDEX 36
#define KEY_OFFSET 7

// Packet Values Macros
#define PAYLOAD_LENGTH_VAL '\x1e'
#define ADVERTISEMENT_TYPE_VAL '\xff'
#define COMPANY_ID_VAL "\x00\4c"
#define OF_TYPE_VAL '\x12'
#define OF_DATA_LENGTH_VAL '\x19'
#define BATTERY_LEVEL_STATUS_VAL '\x00'
#define HINT_VAL '\x00'

class AppleBLEPacket {
  public:
    char* packet_data;
    
    AppleBLEPacket();

    ~AppleBLEPacket();
    
    void set_public_key(uint8_t* key, int len);
  private:
    void build_packet_structure();

};