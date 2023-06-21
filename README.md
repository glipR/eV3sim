# EV3Sim (Currently in RFC Stage)

A Robotics simulation software, empowering you to simulate various robotics apparatus in your language of choice

!! EV3Sim is currently in the early stages of development. Nothing is set in stone.

## Developing

EV3Sim is written in the ~[Godot](https://godotengine.org/article/godot-4-0-sets-sail/) game engine for Godot 4.
To get started, clone the repository, open Godot, and click the "Import" button, selecting the repository folder.

### Goals

* Higher fidelity simulation than the original ev3sim (2d -> 3d)
* Support multiple languages and ways of working
* Support many of the customisation features present in original ev3sim (something akin to custom presets)
* Provide an easy way to replay games for tournament settings or testing
* Require at most minimal code change from the user point of view between simulation and reality.

### Anti-Goals

* Be beholden to the python implementation of ev3dev
* Package python or any other language with the installation of EV3Sim
* Require major changes to the integrating language libraries

### Folder Structure

The project is comprised of the following folders:

* Devices: Scripts and Prefabs for simulating devices in EV3Sim.
* Testing: Temporary files for trying out things.
* Simulation: Various scripts ran in simulation for features. Includes game logging, load orchestration.
* GUI: The GUI, and various functionality surrounding the GUI.
* Playgrounds: Definitions for soccer, rescue, and backbone for various others.

## TODOs

Here's a list of things that need to be done before a v1 can really be considered:

* Working bots, loaded from a filepath
    * This filepath can represent a godot prefab, some custom yaml config, or something else. Still up in the air
* Working orchestration of multiple language executions
    * Single click to spawn many bots and have them all running simultaneously
* Working maps (soccer), loaded from a filepath
* Minimal GUI
* Python implementation working

And here's things that could be added in future:

* Testing other language implementations of ev3dev
* Adding support for other robotics devices through the same file read/write pattern
* In-Sim Bot Editor
