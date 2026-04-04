#include <BLEDevice.h>
#include <BLEUtils.h>
#include <BLEScan.h>
#include <BLEAdvertisedDevice.h>

int scanTime = 5;  //In seconds
BLEScan *pBLEScan;

class MyAdvertisedDeviceCallbacks : public BLEAdvertisedDeviceCallbacks {
  void onResult(BLEAdvertisedDevice advertisedDevice) {
    // uint8_t advType = advertisedDevice.getAdvType();
    uint8_t payload_length = advertisedDevice.getPayloadLength();
    uint8_t* payload = advertisedDevice.getPayload();
    if (payload[2] == 0x4c && payload[3] == 0){
      // Serial.println("                                                                          <|----------------------------- CHECK THIS ONE -----------------------------");
      Serial.println("----------------------------------------------------------------");
      Serial.printf("Advertised Device: %s \n", advertisedDevice.toString().c_str());
      Serial.printf("Raw Payload ___\n"
                    "               |\n"
                    "               v\n");
      for (int i = 0; i < payload_length; i++){
        Serial.printf("%02x ", payload[i]);
      }
      Serial.println();
      Serial.println("----------------------------------------------------------------");
    }
    // Serial.printf("Found device\nAdv Type: %02x\nPayload Length: %d\n", advType, payload_length);
    // Serial.printf("First two bytes: %02x%02x\n", payload[0], payload[1]);

    // Serial.printf("Advertised Device: %s \n", advertisedDevice.toString().c_str());
  }
};

void setup() {
  Serial.begin(115200);
  Serial.println("Scanning...");

  BLEDevice::init("");
  pBLEScan = BLEDevice::getScan();  //create new scan
  pBLEScan->setAdvertisedDeviceCallbacks(new MyAdvertisedDeviceCallbacks());
  pBLEScan->setActiveScan(true);  //active scan uses more power, but get results faster
  pBLEScan->setInterval(100);
  pBLEScan->setWindow(99);  // less or equal setInterval value
}

void loop() {
  // put your main code here, to run repeatedly:
  BLEScanResults *foundDevices = pBLEScan->start(scanTime, false);
  Serial.print("Devices found: ");
  Serial.println(foundDevices->getCount());
  // foundDevices->getDevice(0);
  Serial.println("Scan done!");
  pBLEScan->clearResults();  // delete results fromBLEScan buffer to release memory
  delay(30000);
}