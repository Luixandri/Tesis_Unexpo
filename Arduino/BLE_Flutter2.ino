#include "EEPROM.h"
#include <WiFi.h>
#include <ESP32Ping.h>
#include "FirebaseESP32.h"
#include "DHTesp.h"
#include <stdlib.h>
#include <BLEDevice.h>
#include <BLEServer.h>
#include <BLEUtils.h>
#include <BLE2902.h>

#define EEPROM_SIZE 128
#define SERVICE_UUID        "4fafc201-1fb5-459e-8fcc-c5c9c331914b"
#define CHARACTERISTIC_UUID "beb5483e-36e1-4688-b7f5-ea07361b26a8"
#define timeSeconds 2
#define FIREBASE_HOST "esp32-flutter.firebaseio.com"               
#define FIREBASE_AUTH "Sg7E8ECbLbWL8dSP9GMFcZ3udd9KvC4gZ8tBb6lI"    

const char* remote_host = "www.google.com";

BLEServer* pServer = NULL;
BLECharacteristic* pCharacteristic = NULL;
bool deviceConnected = false;
bool oldDeviceConnected = false;

//Declaracion de objetos 
DHTesp dht;
WiFiClient espClient;
FirebaseData firebaseData;
String ruta = "/items/-M1cg_B703splmfUU15i";
    
const int modeAddr = 0;
const int wifiAddr = 10;
int modeIdx;

const int PinLDR= 25;
const byte PIRsensor = 26;
int dhtPin = 27;
int Ledroom= 13;
int Ledbath = 14;
int LedKitchen = 2;
int Ledgaraje = 15;
int counterInter = 0;


// Timer: Auxiliary variables}
int contar =0;
unsigned long now = millis();
unsigned long lastTrigger = 0;
boolean startTimer = false;

  
//---------Estructura para las mediciones respectivas------------
struct sensor {
  int deviceId;
  const char* measurementType;
  float value;
}; 
  
//-----------Configuracion del Bluetooth------------------------------

class MyServerCallbacks: public BLEServerCallbacks {
    void onConnect(BLEServer* pServer) {
      deviceConnected = true;
      BLEDevice::startAdvertising(); };

    void onDisconnect(BLEServer* pServer) {
      deviceConnected = false; }};

class MyCallbacks: public BLECharacteristicCallbacks {
  void onWrite(BLECharacteristic *pCharacteristic){
    std::string value = pCharacteristic->getValue();

    if(value.length() > 0){
      Serial.print("Value : ");
      Serial.println(value.c_str());
      writeString(wifiAddr, value.c_str());} }
    
  void writeString(int add, String data){
    int _size = data.length();
    for(int i=0; i<_size; i++){
      EEPROM.write(add+i, data[i]);}
    
    EEPROM.write(add+_size, '\0');
    EEPROM.commit(); }};
    
//----------- Interrupcion PIR-----------------------

void IRAM_ATTR detectsMovement() {
  Serial.println("Movimiento detectado!!!");
  startTimer = true;
  lastTrigger = millis();
  contar = 1;
} 

 //----------------------------------------------------
 
void setup() {
  
  Serial.begin(115200);
  if(!EEPROM.begin(EEPROM_SIZE)){
    delay(1000);}
  delay(3000);
  modeIdx = EEPROM.read(modeAddr); //leo la dir de la Eeeprom
  Serial.print("modeIdx : ");
  Serial.println(modeIdx);

  EEPROM.write(modeAddr, modeIdx !=0 ? 0 : 1);
  EEPROM.commit();

  if(modeIdx != 0){
    //BLE MODE
    Serial.println("BLE MODE");
    bleTask();
    
  }else{
    //WIFI MODE
    Serial.println("WIFI MODE");
    wifiTask();}
    
   //---------------------- DHT y PIR-------------------------------------
  dht.setup(dhtPin, DHTesp::DHT11); 
  
 //Configuracion del sensor de movimiento
  pinMode(PIRsensor, INPUT_PULLUP);
  attachInterrupt(digitalPinToInterrupt(PIRsensor), detectsMovement, RISING);

// --------------Configuracion de pines para las luces---------------------
  pinMode(Ledroom,OUTPUT);
  digitalWrite(Ledroom,LOW),
  pinMode(Ledbath, OUTPUT); 
  digitalWrite(Ledbath, LOW);
  pinMode(LedKitchen, OUTPUT); 
  digitalWrite(LedKitchen, LOW); 
  pinMode(Ledgaraje, OUTPUT); 
  digitalWrite(Ledgaraje, LOW); 
}

//-------------------------------------------------------------------------- 

void loop() {
  if( contar==1){
    Firebase.setString(firebaseData, ruta + "/movimiento", "ALERTA");
    now = millis();
    if(startTimer && (now - lastTrigger > (timeSeconds*100))) {
      Serial.println("AMBIENTE SEGURO");
      startTimer = false;
  }
  contar =0;    
  }
  else {
    Firebase.setString(firebaseData, ruta + "/movimiento", "AMBIENTE SEGURO");
  }
  Temperatura();
  delay(3000);
  Humedad();
  delay(1200);
  lucess();
  delay(500);
}
//--------------------------FUNCIONES---------------------------------------


void Temperatura()
{   
    char temp[20];
    delay(500);
    struct sensor mySensor;
    mySensor.deviceId = 1;
    mySensor.measurementType = "Temperatura";
    mySensor.value = dht.getTemperature();
    Serial.print("Temperatura:");
    Serial.println(mySensor.value);
    dtostrf(mySensor.value,4,2,temp);
     Firebase.setString(firebaseData, ruta + "/temperatura", temp);    
    delay(10); 
}

//--------------------------------------------------------------------------
void Humedad ()
{
    char hum[20];
    struct sensor mySensor;
    mySensor.deviceId = 2;
    mySensor.measurementType = "Humedad";
    mySensor.value = dht.getHumidity();
    Serial.print("Humedad:");
    Serial.println(mySensor.value);
    dtostrf(mySensor.value,4,2,hum);
    Firebase.setString(firebaseData, ruta + "/humedad",hum);    
    delay(500);

}
//-------------------------------------------------------------------------

void lucess ()
{  
   Firebase.getString(firebaseData, ruta + "/lucesroom");
   Serial.println(firebaseData.stringData());
   if (firebaseData.stringData()== "ON"){
       Serial.println("Luz del cuarto encendida");
       digitalWrite(Ledroom, HIGH);
   }
   else {
       Serial.println("Luz del cuarto apagada");
       digitalWrite(Ledroom, LOW);


   }
   Firebase.getString(firebaseData, ruta + "/lucesbath");
   Serial.println(firebaseData.stringData());
   if (firebaseData.stringData()== "ON"){
       Serial.println("Luz del baño encendida");
       digitalWrite(Ledbath, HIGH);

   }
   else {
       Serial.println("Luz del baño apagada");
       digitalWrite(Ledbath, LOW);
   }
   Firebase.getString(firebaseData, ruta + "/luceskitchen");
   Serial.println(firebaseData.stringData());
   if (firebaseData.stringData()== "ON"){
       Serial.println("Luz de la cocina encendida");
        digitalWrite(LedKitchen, HIGH);
   }
   else {
       Serial.println("Luz de la cocina apagada");
        digitalWrite(LedKitchen, LOW);

   }
   Firebase.getString(firebaseData, ruta + "/lucesgaraje");
   Serial.println(firebaseData.stringData());
   if (firebaseData.stringData()== "ON"){
       Serial.println("Luz del garaje encendida");
       digitalWrite(Ledgaraje, HIGH);

   }
   else {
       Serial.println("Luz del garaje apagada");
       digitalWrite(Ledgaraje, LOW);
   }   
}

//--------------------------------------------------------------------------
void bleTask(){
  // Create the BLE Device
  BLEDevice::init("ESP32 THAT PROJECT");

  // Create the BLE Server
  pServer = BLEDevice::createServer();
  pServer->setCallbacks(new MyServerCallbacks());

  // Create the BLE Service
  BLEService *pService = pServer->createService(SERVICE_UUID);

  // Create a BLE Characteristic
  pCharacteristic = pService->createCharacteristic(
                      CHARACTERISTIC_UUID,
                      BLECharacteristic::PROPERTY_READ   |
                      BLECharacteristic::PROPERTY_WRITE  |
                      BLECharacteristic::PROPERTY_NOTIFY |
                      BLECharacteristic::PROPERTY_INDICATE
                    );

  pCharacteristic->setCallbacks(new MyCallbacks());
  
  // Create a BLE Descriptor
  pCharacteristic->addDescriptor(new BLE2902());

  // Start the service
  pService->start();

  // Start advertising
  BLEAdvertising *pAdvertising = BLEDevice::getAdvertising();
  pAdvertising->addServiceUUID(SERVICE_UUID);
  pAdvertising->setScanResponse(false);
  pAdvertising->setMinPreferred(0x0);  //
  BLEDevice::startAdvertising();
  Serial.println("Waiting a client connection to notify...");}
//--------------------------------------------------------------------------

void wifiTask() {
  String receivedData;
  receivedData = read_String(wifiAddr);

  if(receivedData.length() > 0){
    String wifiName = getValue(receivedData, ',', 0);
    String wifiPassword = getValue(receivedData, ',', 1);

    if(wifiName.length() > 0 && wifiPassword.length() >= 0){
      Serial.print("WifiName : ");
      Serial.println(wifiName);

      Serial.print("wifiPassword : ");
      Serial.println(wifiPassword);

      WiFi.begin(wifiName.c_str(), wifiPassword.c_str());
      Serial.print("Connecting to Wifi");
      while(WiFi.status() != WL_CONNECTED){
        Serial.print(".");
        delay(300);
      }
      Firebase.begin(FIREBASE_HOST, FIREBASE_AUTH);
      Firebase.reconnectWiFi(true);
      Serial.print("Ping Host: ");
      Serial.println(remote_host);

      if(Ping.ping(remote_host)){
        Serial.println("Success!!");
      }else{
        Serial.println("ERROR!!");} 
               
    }
  }
}

String read_String(int add){
  char data[100];
  int len = 0;
  unsigned char k;
  k = EEPROM.read(add);
  while(k != '\0' && len< 500){
    k = EEPROM.read(add+len);
    data[len] = k;
    len++;}  
  data[len] = '\0';
  return String(data);
}

String getValue(String data, char separator, int index){
  int found = 0;
  int strIndex[] = {0, -1};
  int maxIndex = data.length()-1;

  for(int i=0; i<=maxIndex && found <=index; i++){
    if(data.charAt(i)==separator || i==maxIndex){
      found++;
      strIndex[0] = strIndex[1]+1;
      strIndex[1] = (i==maxIndex) ? i+1 : i;
    }
  }
  return found>index ? data.substring(strIndex[0], strIndex[1]) : "";
}
