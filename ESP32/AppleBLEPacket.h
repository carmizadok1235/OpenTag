#pragma once

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <Arduino.h>

#define APPLE_BLE_PACKET_LENGTH 37

class AppleBLEPacket {
  public:
    char* packet_data;
    
    AppleBLEPacket();
    
    void set_public_key(uint8_t* key);
  private:
    void build_packet_structure();

};