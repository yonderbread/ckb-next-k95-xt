#import <AudioToolbox/AudioServices.h>
#import <Foundation/Foundation.h>
#include "media.h"

bool isMuteDeviceSupported() {
    return false;
}

muteState getMuteState(const muteDevice muteDev){
    // Get the system's default audio device
    AudioObjectPropertyAddress propertyAddress = {
        kAudioHardwarePropertyDefaultOutputDevice,
        kAudioObjectPropertyScopeGlobal,
        kAudioObjectPropertyElementMaster
    };
    AudioDeviceID deviceID = 0;
    UInt32 dataSize = sizeof(deviceID);
    if(AudioObjectGetPropertyData(kAudioObjectSystemObject, &propertyAddress, 0, NULL, &dataSize, &deviceID)
            != kAudioHardwareNoError){
        return UNKNOWN;
    }
    // Grab the mute property
    AudioObjectPropertyAddress propertyAddress2 = {
        kAudioDevicePropertyMute,
        kAudioDevicePropertyScopeOutput,
        kAudioObjectPropertyElementMaster
    };
    if(!AudioObjectHasProperty(deviceID, &propertyAddress2))
        return UNKNOWN;
    int state = 0;
    dataSize = sizeof(state);
    if(AudioObjectGetPropertyData(deviceID, &propertyAddress2, 0, NULL, &dataSize, &state)
            != kAudioHardwareNoError)
        return UNKNOWN;
    return state ? MUTED : UNMUTED;
}

void disableAppNap(){
    [[NSProcessInfo processInfo] beginActivityWithOptions:NSActivityUserInitiatedAllowingIdleSystemSleep reason:@"Keyboard animation"];
}

void deinitAudioSubsystem() {}
