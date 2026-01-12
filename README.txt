HYBRID HANG FIX FOR X11 Nvidia+Intel
Updated: January 11, 2026
Author: Nacho_P90

[ORIGINALY MADE FOR SYSTEM]
OS:	Arch Linux
Device: Acer Nitro V15
CPU:	Intel core i9 13900H (20 Thread)
iGPU:	Intel UHD Graphics
dGPU:	Nvidia GeForce RTX 5060 8GB Max-Q (open kernel driver)

[POURPOSE]
This project provides a simple workaround for Hybrid GPU Laptops that experience
- GPU Hangs
- Freezes
- Watchdog Errors
while gaming or doing GPU heavy tasks

This works because it forces Xorg to commit system rendering to either the NVIDIA dgpu while active, this eliminates a massive portion of driver handoff issues that trigger hangs under heavy load.

[BACKSTORY]
Got the laptop for gaming and game development, when I tried to play arc raiders on Windows 11 the system would quickly freeze and soon after I would get either a TDR_RECOVERY_ERROR or a WATCHDOG_VIOLATION stop code. I tried several several things and all I got out of them was wasting time in registry settings, or fighting with the modern windows 11 settings app to try and get it to work. Not wanting to return the laptop (the deal I got for it was insane, I wonder why), I remembered using linux and how well it worked with previous systems I have had. So I did some reaserch, and I found out that Xorg can for the most part disable a GPU. Now, im not proud of it but I did use chatGPT to help with the syntax because I never really configured a linux system like this. 14 days later, I end up with this, and it works pretty well.

[BENEFITS]
Heavily Reduces GPU Hang Related Errors for modern videogames and GPU intensive tasking.

[SETBACKS] 
- While the descrete GPU is set to default, the built in display will likely not 
turn on and an external monitor will have to be used.
- Installing this will increase your initial logon black-screen time by up to 8 seconds.
- Does not stop crashes while playing gary's mod (possibly other source games)

[STORAGE COST] ~5 KiB

----AUTOMATIC-SETUP----------------------------------
[Execute]
sudo ./setup.sh

setup.sh also contains additional instructions that you must do manually

----MANUAL-SETUP-------------------------------------
[Dependincies]
-xrandr
-xorg
-sytsemd (or other compatable service manager)

[Update repositories]

[Edit files]
Type xrandr into your terminal to see what your display panels max resolution, refesh rate, and label it has.
Edit set-refresh.service and make sure line 10 has the correct settings (default: HDMI-0, 1920x1080, 144hz)
If you have a non-nvidia descrete GPU, change make sure to change it to your brand and ensure the Variables are correct.

[Create Directory]
In your home folder create: .igpud/

[Make Exectutable]
hybridGPU-toggle

[Copy Files]
10-monitor.conf		> /etc/X11/xorg.conf.d/
10-nvidia-primary.conf	> /etc/X11/xorg.conf.d/
hybridGPU-toggle	> /usr/local/bin/

[reboot]

[run]
hybridGPU-toggle
the first line it prints should tell you what it's doing.

[reboot]

Works best when power management is set to maximum performance

----IF-MONITOR-SETTINGS-DEFAULT-INCORRECT-------------
So lets say that your refresh rate is incorrect upon login after you reboot

[Copy File]
set-refresh.service	> ~/.config/systemd/user/

[Enable Service]
systemctl --user daemon-reload
systemctl --user enable set-refresh.service

[reboot]

====ALL=DONE=========================================

----AUTOMATIC-REMOVAL--------------------------------
Run remove
