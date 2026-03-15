#include <AppleBLEPacket.h>

AppleBLEPacket::AppleBLEPacket(){
  this->packet_data = (char*)malloc(sizeof(char)*APPLE_BLE_PACKET_LENGTH);
  this->build_packet_structure();
}

void AppleBLEPacket::set_public_key(uint8_t *key){
  // BLE MAC Address (p[0] | 0b11 << 6 || p[1..5] where p is public key)
  for (int i = 0; i < 6; i++){
    if (i == 0){
      this->packet_data[i] = key[0] | (0b11 << 6);
    }
    this->packet_data[i] = key[i];
  }

  // Public Key Bytes p[6..27]
  for (int i = 13; i < 13+22; i++){
    this->packet_data[i] = key[i-7];
  }

  // Public Key Bits p[0] >> 6
  this->packet_data[35] = key[0] >> 6;
}

void AppleBLEPacket::build_packet_structure(){
  memset(this->packet_data, '\x00', APPLE_BLE_PACKET_LENGTH);
  // BLE MAC Address (p[0] | 0b11 << 6 || p[1..5] where p is public key)
  // for (int i = 0; i < 6; i++){
    // if (i == 0){
    //   packet[i] = public_k[0] | (0b11 << 6);
    // }
    // packet[i] = public_k[i];
    // this->packet_data[i] = '\x00';
  // }

  this->packet_data[6] = '\x1e'; // Payload Length in Bytes (30)
  this->packet_data[7] = '\xff'; // Advertisment Type
  // Company ID (Apple)
  this->packet_data[8] = '\x00';
  this->packet_data[9] = '\x4c'; 
  this->packet_data[10] = '\x12'; // OF Type
  this->packet_data[11] = '\x19'; // OF Data Length in Bytes (25)
  this->packet_data[12] = '\x00'; // Status (Battery Level)
  
  // Public Key Bytes p[6..27]
  // for (int i = 13; i < 13+22; i++){
  //   this->packet_data[i] = '\x00';
  // }
  
  // this->packet_data[35] = '\x00'; // Public Key Bits p[0] >> 6
  this->packet_data[36] = '\x00'; // Hint (0x00 on iOS Reports)
}