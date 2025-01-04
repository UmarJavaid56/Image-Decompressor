## Hardware Implementation of an Image Decompressor

This project is centred around designing a hardware decompression system for the custom McMaster Image Compression (mic18) format. The system receives the mic18 file over the UART serial communication protocol and stores the data in the external SRAM. The decompression system then decodes this data into its corresponding RGB data through the use of custom-made digital sub-systems. The RGB image data is then outputted to the screen using a VGA controller.
