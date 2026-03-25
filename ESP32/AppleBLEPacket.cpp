#include <AppleBLEPacket.h>

AppleBLEPacket::AppleBLEPacket(){
  this->packet_data = (char*)malloc(sizeof(char)*APPLE_BLE_PACKET_LENGTH);
  this->build_packet_structure();
}

AppleBLEPacket::~AppleBLEPacket(){
  free(this->packet_data);
}

bool AppleBLEPacket::set_public_key(uint8_t *key, int len){
  if (!key || len != ADVERTISEMENT_KEY_LENGTH){
    return false;
  }

  // BLE MAC Address (p[0] | 0b11 << 6 || p[1..5] where p is public key)
  for (int i = FIRST_6_BYTES_KEY_START_INDEX; i < FIRST_6_BYTES_KEY_END_PACKET_INDEX; i++){
    if (i == 0){ // first byte
      this->packet_data[i] = key[i] | (0b11 << 6);
      continue;
    }
    this->packet_data[i] = key[i];
  }

  // Public Key Bytes p[6..27]
  for (int i = REMAINING_22_BYTES_KEY_START_PACKET_INDEX; i < REMAINING_22_BYTES_KEY_END_PACKET_INDEX; i++){
    this->packet_data[i] = key[i-KEY_OFFSET];
  }

  // Public Key Bits p[0] >> 6
  this->packet_data[FIRST_BYTE_FIRST_2_BITS_PACKET_INDEX] = key[0] >> 6;

  return true;
}

void AppleBLEPacket::build_packet_structure(){
  memset(this->packet_data, '\x00', APPLE_BLE_PACKET_LENGTH); // cleaning the buffer
  // BLE MAC Address (p[0] | 0b11 << 6 || p[1..5] where p is public key)
  // for (int i = 0; i < 6; i++){
    // if (i == 0){
    //   packet[i] = public_k[0] | (0b11 << 6);
    // }
    // packet[i] = public_k[i];
    // this->packet_data[i] = '\x00';
  // }

  this->packet_data[PAYLOAD_LENGTH_PACKET_INDEX] = PAYLOAD_LENGTH_VAL; // Payload Length in Bytes (30)
  this->packet_data[ADVERTISEMENT_TYPE_PACKET_INDEX] = ADVERTISEMENT_TYPE_VAL; // Advertisement Type
  // Company ID (Apple)
  memcpy(this->packet_data+COMPANY_ID_PACKET_STARTING_INDEX, (uint_t*)(COMPANY_ID_VAL), COMPANY_ID_LENGTH)
  // this->packet_data[8] = '\x00';
  // this->packet_data[9] = '\x4c'; 
  this->packet_data[OF_TYPE_PACKET_INDEX] = OF_TYPE_VAL; // OF Type
  this->packet_data[OF_DATA_LENGTH_PACKET_INDEX] = OF_DATA_LENGTH_VAL; // OF Data Length in Bytes (25)
  this->packet_data[BATTERY_LEVEL_STATUS_PACKET_INDEX] = BATTERY_LEVEL_STATUS_VAL; // Status (Battery Level)
  
  // Public Key Bytes p[6..27]
  // for (int i = 13; i < 13+22; i++){
  //   this->packet_data[i] = '\x00';
  // }
  
  // this->packet_data[35] = '\x00'; // Public Key Bits p[0] >> 6
  this->packet_data[HINT_PACKET_INDEX] = HINT_VAL; // Hint (0x00 on iOS Reports)
}