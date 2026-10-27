# receipts-ios

Internal iOS application for field staff and sales representatives to capture, enhance, and categorize expense receipts immediately after purchase. Built for seamless integration with corporate internal reimbursement workflows.

![App Screenshot Placeholder](docs/screenshots/main-dashboard.png)

## Features

- **Receipt Capture & Edge Crop**: Built-in camera capture with automatic document edge detection and interactive crop handles.
- **Thermal Image Enhancement**: Custom contrast and brightness filters (`CIColorControls` / `CIHistogramModification`) tailored for low-contrast thermal paper receipts.
- **Expense Data Entry**: Record vendor name, transaction date, category (KONSUMSI, TRANSPORTASI, AKOMODASI, ATK, LAINNYA), and nominal amount in IDR.
- **PDF Summary Export**: Generate formatted expense report PDFs containing itemized summary tables and attached high-contrast receipt images ready for finance submission.

## Requirements & Stack

- **iOS Target**: iOS 17.0+
- **Language**: Swift 6.0
- **UI Framework**: SwiftUI
- **IDE**: Xcode 15.4 / 16.0+
- **Core Frameworks**: `VisionKit`, `CoreImage`, `PDFKit`, `SwiftData`

## Getting Started

### Prerequisites

Ensure you have Xcode 15.4 or Xcode 16 installed with the iOS 17 SDK.

```bash
git clone git@git.internal.corp:mobile/receipts-ios.git
cd receipts-ios
```

### Opening in Xcode

1. Open `Receipts.xcodeproj` in Xcode.
2. Select your development team in **Signing & Capabilities** for local device deployment.
3. Build and run on an iOS 17 physical device (Camera features require a real camera device).

> **Note on Camera Simulator Limitation**:
> `VNDetectRectanglesRequest` and live camera feeds do not produce accurate frames in the Xcode iOS Simulator. Always test receipt scanning on a physical iPhone.

## Deployment & Distribution

This application is distributed internally to enterprise devices via **Apple Business Manager (Custom App Distribution)** and Ad-Hoc provisioning profiles.

- **Staging / QA Build**: Distributed via internal TestFlight / Ad-Hoc profile (`org.internal.receipts.staging`).
- **Production Enterprise**: Distributed via ABM / In-House Enterprise (`org.internal.receipts`).

## Project Structure

```
Receipts/
├── App/
│   ├── ReceiptsApp.swift
│   └── AppConfig.swift
├── Models/
│   └── ExpenseReceipt.swift
├── Views/
│   ├── Scanner/
│   │   ├── CameraScannerView.swift
│   │   └── CropOverlayView.swift
│   ├── Metadata/
│   │   └── ReceiptFormView.swift
│   └── Export/
│       └── PDFReportGenerator.swift
├── Services/
│   ├── ImageProcessor.swift
│   └── PDFExportService.swift
└── Resources/
    └── Assets.xcassets
```

## Internal Business Rules

- Nominal receipt amounts default to Indonesian Rupiah (IDR).
- Receipt attachments over 5MB are automatically compressed during PDF generation to keep email reimbursement submissions below corporate mail gateway limits (10MB total submission limit).
- Expenses categorized as `AKOMODASI` or `TRANSPORTASI` require attached receipt images before PDF export is permitted.
