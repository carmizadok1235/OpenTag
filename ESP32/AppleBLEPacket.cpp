#include <AppleBLEPacket.h>


AppleBLEPacket::AppleBLEPacket(){
  this->packet_data = (uint8_t*)malloc(sizeof(uint8_t)*APPLE_BLE_PACKET_LENGTH);
  this->macAddress = (uint8_t*)malloc(sizeof(uint8_t)*MAC_ADDRESS_SIZE);
  this->build_packet_structure();
}

AppleBLEPacket::~AppleBLEPacket(){
  free(this->packet_data);
  free(this->macAddress);
}

bool AppleBLEPacket::set_public_key(uint8_t *key, int len){
  if (!key || len != ADVERTISEMENT_KEY_LENGTH){
    return false;
  }

  // BLE MAC Address (p[0] | 0b11 << 6 || p[1..5] where p is public key)
  for (int i = 0; i < MAC_ADDRESS_SIZE; i++){
    if (i == 0){ // first byte
      this->macAddress[i] = key[i] | (0b11 << 6);
      continue;
    }
    this->macAddress[i] = key[i];
  }

  esp_err_t ret = esp_ble_gap_set_rand_addr(macAddress);
  if (ret != ESP_OK){
    return false;
  }

  // Public Key Bytes p[6..27]
  for (int i = REMAINING_22_BYTES_KEY_START_PACKET_INDEX; i < REMAINING_22_BYTES_KEY_END_PACKET_INDEX+1; i++){
    this->packet_data[i] = key[i-KEY_OFFSET];
  }

  // Public Key Bits p[0] >> 6
  this->packet_data[FIRST_BYTE_FIRST_2_BITS_PACKET_INDEX] = key[0] >> 6;

  return true;
}

void AppleBLEPacket::build_packet_structure(){
  memset(this->packet_data, 0, APPLE_BLE_PACKET_LENGTH); // cleaning the buffer
  memset(this->macAddress, 0, MAC_ADDRESS_SIZE);
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
  memcpy(this->packet_data+COMPANY_ID_PACKET_STARTING_INDEX, (uint8_t*)(COMPANY_ID_VAL), COMPANY_ID_LENGTH);
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

char* AppleBLEPacket::packet_repr(){
  char* buffer = (char*)malloc((APPLE_BLE_PACKET_LENGTH*2+1)*sizeof(char));
  char tmp[3];
  for (int i = 0; i < APPLE_BLE_PACKET_LENGTH; i++){
    sprintf(tmp, "%02X", this->packet_data[i]);
    memcpy(buffer+i*2, tmp, 2);
    // snprintf(buffer+i*3, 3, "%02X ", this->packet_data[i]);
  }

  buffer[APPLE_BLE_PACKET_LENGTH*2] = 0;
  // Serial.printf("%s\n", buffer);
  return buffer;
}
