#include <ESP8266WiFi.h>
#include <ESP8266mDNS.h>
MDNSResponder mdns;

const char* ssid =       "thesis";
const char* password =   "12345678";
const char myDNSName[] = "tileTester";
WiFiServer                server(7899);

#define OSCDEBUG    (0)

#include <NeoPixelBus.h>
const int PixelCount = 64;
const int PixelPin = 2;
boolean matrixOn = true;
const int matrixSwitchPin = 5;

NeoPixelBus<NeoGrbFeature, NeoEsp8266Uart800KbpsMethod> strip(PixelCount, PixelPin);
// Gamma correction 2.2 look up table

void setup() {

  Serial.begin(115200);
  Serial.println("initialize");
  pinMode(matrixSwitchPin, OUTPUT);
  if (matrixOn) {
    digitalWrite(matrixSwitchPin, HIGH);
  } else {
    digitalWrite(matrixSwitchPin, LOW);
  }
  uint16_t i = 0;
  // this resets all the neopixels to an off state
  strip.Begin();
  for (i = 0; i < PixelCount; i++)
    strip.SetPixelColor(i, RgbColor(0, 0, 0));
  strip.Show();
  delay(500);

  // Connect to WiFi network
  Serial.println();
  Serial.println();
  Serial.print("Connecting to ");
  Serial.println(ssid);
  
  WiFi.mode(WIFI_STA);
  WiFi.begin(ssid, password);

  while (WiFi.status() != WL_CONNECTED) {
    Serial.print(".");
    strip.SetPixelColor(i, RgbColor(1, 0, 0));
    strip.Show();
    delay(200);
    strip.SetPixelColor(i, RgbColor(0, 0, 0));
    i++;
    if (i >= 64)
      i = 0;
  }

  Serial.println("");
  Serial.println("WiFi connected");

  for (i = 0; i < 64; i++)
    strip.SetPixelColor(i, RgbColor(1, 0, 0));
  strip.Show();
  delay(500);
   for (i = 0; i < 64; i++)
    strip.SetPixelColor(i, RgbColor(0, 0, 1));
  strip.Show();
  delay(500);
   for (i = 0; i < 64; i++)
    strip.SetPixelColor(i, RgbColor(0, 1, 0));
  strip.Show();

  // Print the IP address
  Serial.println(WiFi.localIP());

  // Set up mDNS responder:
  if (!mdns.begin(myDNSName, WiFi.localIP())) {
    Serial.println("Error setting up MDNS responder!");
  }
  else {
    Serial.println("mDNS responder started");
    Serial.printf("My name is [%s]\r\n", myDNSName);
  }

  // Start the server listening for incoming client connections
  server.begin();
  Serial.println("Server listening on port 7890");

}

WiFiClient client;

#define minsize(x,y) (((x)<(y))?(x):(y))

void clientEvent()
{
  static int packetParse = 0;
  static uint8_t pktChannel, pktCommand;
  static uint16_t pktLength, pktLengthAdjusted, bytesIn;
  static uint8_t pktData[PixelCount * 3];
  uint16_t bytesRead;
  size_t frame_count = 0, frame_discard = 0;

  if (!client) {
    // Check if a client has connected
    client = server.available();
    if (!client) {
      Serial.println(WiFi.RSSI());
      return;
    }
    Serial.println("new OPC client");
  }

  if (!client.connected()) {
    Serial.println("OPC client disconnected");
    for (int i = 0; i < 64; i++)
      strip.SetPixelColor(i, RgbColor(0, 8, 0));
    strip.Show();
    client = server.available();
    if (!client) {
      return;
    }
  }

  while (client.available()) {
    switch (packetParse) {
      case 0: // Get pktChannel
        pktChannel = client.read();
        packetParse++;
#if OSCDEBUG
        Serial.printf("pktChannel %u\r\n", pktChannel);
#endif
        break;
      case 1: // Get pktCommand
        pktCommand = client.read();
        packetParse++;
#if OSCDEBUG
        Serial.printf("pktCommand %u\r\n", pktCommand);
#endif
        break;
      case 2: // Get pktLength (high byte)
        pktLength = client.read() << 8;
        packetParse++;
#if OSCDEBUG
        Serial.printf("pktLength high byte %u\r\n", pktLength);
#endif
        break;
      case 3: // Get pktLength (low byte)
        pktLength = pktLength | client.read();
        packetParse++;
        bytesIn = 0;
#if OSCDEBUG
        Serial.printf("pktLength %u\r\n", pktLength);
#endif
        if (pktLength > sizeof(pktData)) {
          Serial.println("Packet length exceeds size of buffer! Data discarded");
          pktLengthAdjusted = sizeof(pktData);
        }
        else {
          pktLengthAdjusted = pktLength;
        }
        break;
      case 4: // Read pktLengthAdjusted bytes into pktData
        bytesRead = client.read(&pktData[bytesIn],
                                minsize(sizeof(pktData), pktLengthAdjusted) - bytesIn);
        bytesIn += bytesRead;
        if (bytesIn >= pktLengthAdjusted) {
          if ((pktCommand == 0) && (pktChannel <= 1)) {
            int i;
            uint8_t *pixrgb;
            pixrgb = pktData;
            for (i = 0; i < minsize((pktLengthAdjusted / 3), PixelCount); i++) {
              strip.SetPixelColor(i,
                                  RgbColor(*pixrgb++,
                                           *pixrgb++,
                                           *pixrgb++));
            }
            // Display only the first frame in this cycle. Buffered frames
            // are discarded.
            if (frame_count == 0) {
#if OSCDEBUG
              Serial.print("=");
              unsigned long startMicros = micros();
#endif
              strip.Show();
#if OSCDEBUG
              Serial.printf("%lu\r\n", micros() - startMicros);
#endif
            }
            else {
              frame_discard++;
            }
            frame_count++;
          }
          if (pktLength == pktLengthAdjusted)
            packetParse = 0;
          else
            packetParse++;
        }
        //client.write(1);
        break;
      default:  // Discard data that does not fit in pktData
        bytesRead = client.read(pktData, pktLength - bytesIn);
        bytesIn += bytesRead;
        if (bytesIn >= pktLength) {
          packetParse = 0;
        }
        break;
    }
  }
#if OSCDEBUG
  if (frame_discard) {
    Serial.printf("discard %u\r\n", frame_discard);
  }
#endif
}

void loop() {
  clientEvent();
}
