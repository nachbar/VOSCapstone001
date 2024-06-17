# Capstone project, Kodeco VisualOS Bootcamp, May-June 2024

### James Nachbar

This is an demonstration VisualOS / Vision Pro project, created at the end of the Kodeco VisualOS Bootcamp in June 2024.

It is designed as an immersive guide for a museum exhibit for a total of three objects, allowing the user to experience the objects in detail, without touching the objects.  It is planned as a demonstration app, in that it only displays three specific and hard-coded objects, but could be extended to display more objects.

It was developed using Apple VisualOS 2.0 public beta, which was released the week that this project was developed.  It runs on the Vision Pro, also under VisionOS 2.0 beta, and the Vision Pro using VisionOS 2.0 beta was used to capture the video linked below.

A video demonstrating the main functionality is available at https://vimeo.com/960075134

## Setup

This app requires VisionOS 2.0+, and has only been tested on VisionOS 2.0 public beta.  It does use features not available in VisionOS 1.X

It can be run on either the first commercial version of Apple Vision Pro running VisionOS 2.0+, or the VisionOS 2.0+ simulator under Xcode (although some of the gestures may not be available on the simulator).

The code can be loaded into Xcode 16+, compiled and then run on either the device or the simulator.  Note that VisionOS requires an Apple system with Apple silicon.  It will neither compile nor run on a system with Intel silicon.

## Operation

When started, the app displays a VisionOS volumetric presentation, with three objects visible.  The user can see the baseplate of the volume when looking at it, and there is a control with buttons on the side of the volume.

The user can move herself around the objects in the volumetric presentation to inspect them as closely as desired.  If too close to the volume, the ornament with buttons may not be visible until the user steps back a little.  If the user is to the side or behind the volume, the control will be moved to the side of the volume closest to the user.

The volumetric presentation control also has two toggles to control anchoring in the immersive space.  

One of the toggles is for an anchor to the head, and if this toggle is selected, close inspection of the object in immersive space will cause the inspected object to move with the user’s head and thus remain in her visual field.

The other toggle is for an anchor to a nearby table.  If selected, when an object is inspected in immersive space, it will be placed by the system on a horizontal table surface identified by the system.  Once a table anchor is created, it will be kept for all objects in that app run.

Selection of either of those toggles turns the other one off.  They are not selected by default, and if selected can be deselected by clicking.

When the user clicks the button to enter immersive space, the volume presentation disappears, along with the volumetric base plate.  The three objects are then visible in the immersive space.  They can be inspected using the standard VisionOS rotation gesture while looking at one of the three objects, allowing rotation in all three axes, and inspection from all sides.  

Using these standard gestures, the object selected for rotation is not determined by the position of the user’s hands, but rather by the object the user is focused on while performing the rotation gesture.

When the user taps on one of the objects in immersive space, that object will move closer to the user for even closer inspection.  It can be rotated in three axes using the standard rotation gesture.  If the user taps on that object again, it will move back with the other objects.  If the user taps on one of the other objects, the currently inspected object will move back into line, and the tapped object will move forward.

In immersive space, the control changes to having a button for leaving immersive space, a second button, labeled Show Signs, to show some description of the objects above each object, and an indicator telling the user whether and what kind of anchoring had been selected before entering immersive space.

When the Show Signs button is clicked, the descriptive signs appear and the button becomes a Hide Signs button.

Clicking the Hide Immersive Space button causes Immersive Space to be closed, and the user is shown the volumetric presentation again.  Alternatively, if the close button provided below the controls is clicked, the immersive space is closed if it was open, and the application terminates.

### Anchoring

If head anchoring had been selected before entering immersive space, when an object is selected for inspection, it is shown such that it follows the user’s head position.  

If table anchoring had been selected before entering immersive space, when an object is selected for inspection, it will be moved by the system to a nearby table.  Depending on the environment, the system may or may not have selected a table within the user’s view.

With either head or table anchoring, the inspected object can be rotated in three axes using the same standard rotation gesture while focused on the inspected object.  Tapping on the inspected object, or on one of the other objects, returns the inspected object back into line.

## Design and Structure

This app is based on the default VisionOS 2.0 beta template, produced by Xcode for an immersive app.  Many of the features are provided by VisionOS 2, including the volumetric baseplate and controls that move to the side closest to the user, as well as directional lighting in immersive space.  The volumetric baseplate is programmatically hidden in immersive space.

The app uses an AppModel class instance to centralize app state, extending the class from that created by the template.  Additional state variables were used to control the volumetric toggles.

The app uses ContentView().onChange(of: scenePhase) in the WindowGroup to respond when the user has clicked the App Close button while in immersive space, so the app can first close immersive space before the app itself closes.  Otherwise, if the Close App is clicked while in immersive space, the volumetric presentation will be closed but the user will be left in immersive space.  Although the user could then exit immersive space by opening the home menu, that is not as expected as having the app shut down when the user clicks App Close.

The app uses three Directional Lights (new in VisionOS 2) for the immersive space, configured using Reality Composer Pro.

## Object Capture

The objects were chosen from home, and object capture performed using an iPhone 12 Pro Max.  The software used was the sample code provided by Apple to demonstrate the API for object capture.  The software code was inspected, but it was used unmodified.  The code was loaded into Xcode 15, compiled, and then run on the iPhone.

The object capture can be completely performed on the iPhone, but only a reduced resolution captured object is available when reconstruction is performed on the device.  However, the API allows, and the sample code uses, the ability to capture enough images for full resolution.  

The image files so captured (as well as the reconstructed object) are placed by the software into a folder accessible in the Files app on iPhone. The image file folder was sent to a MacBook using AirDrop, and then Reality Composer Pro was used to reconstruct the objects in full or raw resolution, and those reconstructed objects were used in the app.

## Known Issues

As noted above, when the inspected object is anchored to a table, the table selected by the system is not controllable, and may not be visible, especially if the system has not identified a suitable table.  The user can recover by closing and re-opening the immersive space (perhaps also turning off table anchoring while immersive space is closed).

When the inspected object is anchored to the user’s head, it can be rotated.  The rotation was modified to allow the center of rotation to be the center of the object, rather than the object base.  That provides a more pleasing rotation than an eccentric rotation.  However, if the user moves her head while simultaneously doing the rotation gesture, the object will not move with the user’s head while being rotated, but will become re-anchored, possibly outside the user’s gaze, when rotation stops.  The user can recover by tapping one of the other objects, which will return the inspected object to the line and bring the new object close and directly in front of the user’s head.

## Required Capstone Features

Apple’s Human Interface Guidelines were consulted and implemented.  For example, the guidelines recommend that the app bring the content to the user rather than requiring the user to move to the content.  The inspection within immersive space implements that.

The app was developed using Swift, Swift UI, and RealityKit, using Xcode 16 beta, and no other third party libraries.  Reality Composer Pro was used both to recontruct the object capture, to design the volumetric presentation, and to provide the same objects for the immersive space presentation.

There are three 3D objects presented.

The panels that can be shown above the objects in immersive space are overlay attachments.  They were initially implemented as children of each object, but that was distracting when the object was rotated.  Therefore, the overlays are positioned above each object as children of the background, and they do not rotate or move when the object is inspected.

Anchoring is implemented both as a head anchor and as a table anchor, and can be selected by the user.

The app uses a 3D AppIcon created from my initials.

The accessibility feature is an AccessibilityNotification posted to tell the user when she enters and when she leaves immersive space.  It was tested by using a print statement to confirm that it runs at the appropriate time.  However, I was not able to get VoiceOver to work properly under VisionOS 2.0 beta.  On the simulator, when I first turned on dwell control, dwell control initially worked to allow me to turn on VoiceOver, but once VoiceOver had been turned on, dwell control no longer worked, and it was not possible to exit VoiceOver.  Ultimately, I had to use the Devices and Simulators window within Xcode to completely remove and then reinstall a simulator in order to get a simulator that works.
