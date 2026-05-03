# Radar-Warning-garming

sudo cp -r /root/garmin-sdk-data /home/dgamu/garmin-sdk-data
sudo chown -R dgamu:dgamu /home/dgamu/garmin-sdk-data


echo "connectiq-sdk-lin-9.1.0-2026-03-09-6a872a80b" > /home/dgamu/garmin-sdk-data/garmin-sdk-data/ConnectIQ/current-sdk.cfg

control ,  y monkey c
{
    "monkeyC.javaPath": "/usr/lib/jvm/java-11-openjdk-amd64",
    "monkeyC.testDevices": "",
    "monkeyC.sdkPath": "/home/dgamu/garmin-sdk-data/garmin-sdk-data/ConnectIQ/Sdks/connectiq-sdk-lin-9.1.0-2026-03-09-6a872a80b"
}