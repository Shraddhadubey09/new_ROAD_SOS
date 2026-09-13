# 🚨 RoadSOS

### FPGA-Based Emergency Communication System

RoadSOS is an FPGA-based emergency communication prototype that transfers emergency events between two FPGA nodes using **UART and Wi-Fi/TCP** through two PCs.

## 🔹 Architecture

```text
FPGA 1 → UART → PC 1 → Wi-Fi/TCP → PC 2 → UART → FPGA 2
```

## 🔹 Features

* 🚨 Emergency event generation using FPGA
* 🚗 Vehicle ID and Event ID transmission
* 📡 UART communication at **115200 baud**
* 🌐 PC-to-PC communication using Wi-Fi/TCP
* 🔐 CRC-16/CCITT-FALSE error detection
* 📺 Event and Vehicle ID display on FPGA2
* ✅ Emergency acceptance using physical button
* 🔄 ACK packet generation
* 📊 Web-based monitoring dashboard

## 🔹 Packet Format

```text
A5 | EVENT | VEHICLE_ID | CRC | 5A | 0A
```

* **Event ID:** 8-bit
* **Vehicle ID:** 16-bit
* **CRC:** CRC-16/CCITT-FALSE
* **Packet Size:** 8 bytes

## 🔹 Hardware

* 2 × RealDigital Boolean Boards
* AMD/Xilinx Spartan-7 XC7S50
* 2 × PCs
* USB-UART connections

## 🔹 Current Communication

```text
Emergency Button
       ↓
    FPGA 1
       ↓ UART
     PC 1
       ↓ Wi-Fi/TCP
     PC 2
       ↓ UART
    FPGA 2
       ↓
CRC Validation
       ↓
Event + Vehicle Display
       ↓
   ACCEPT / ACK
```

## 🔹 Current Status

| Feature                   | Status |
| ------------------------- | ------ |
| FPGA Emergency Generation | ✅      |
| UART Communication        | ✅      |
| Wi-Fi/TCP Forwarding      | ✅      |
| FPGA2 Reception           | ✅      |
| CRC Verification          | ✅      |
| Event/Vehicle Display     | ✅      |
| ACK Generation            | ✅      |
| Dashboard                 | ✅      |

> **Note:** LoRa is **not used** in the current implementation.

## 🔮 Future Scope

* Embedded gateway instead of PCs
* GPS/location information
* Secure authentication/encryption
* Retransmission and fault recovery
* Multi-node communication
