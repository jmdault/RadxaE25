# RadxaE25
Files for RadxaE25.

2023-01-22: Major modifications to radxa-e25-led.sh:
- Rewrote colourful() to not use "expr" and added some sleep(). Instead of taking 20-30% of the CPU, the usage is now about 3%.
- Changed color order for colorful(). Before, the unit would boot with a green color, then switch immediately to red. This was potentially misleading for a first-time user, who might imply the red meant an error condition. Now the order is green(boot), then blue->red, red->green, and green->blue. The unit is ready for ssh when the colow tends towards blue-purple.
- Added tricolor() method, meant as an alert to the user, to be used when upgrading software, etc.
- Added suspend, to reset leds to black, with without disabling the PWM. When disabled and script running in background, the script was spewing error messages.
- Added "killall" to be able to start/restart/stop scripts.
- Added the $2 optional parameter to be able to start the script with a specific pattern <colorful|blink|rgb_breathe|tricolor|none>.
