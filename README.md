# Package ssd

##Introduction

With the ssd package the user is able to directly use 
the Flow operator allows expressing unambiguously the expected 
spatial behavior in environmental models for different phenomena 
that can occur simultaneously during the simulation. Thus, 
vertical (between collections) and horizontal (for neighborhood 
within the same collection) spatial diffusion processes were 
modeled and simulated.

This tool was developed as a package for 
[TerraME](https://github.com/TerraME/terrame/wiki), a modeling 
and simulation platform developed by INPE.
The code of this package is open-source and is available in 
the [project page at GitHub](https://github.com/afancio/ssd).

##Classes

This package defines two operators, the Flow operator and the 
Connector operator .
The spatial Connector operator defines the spatial way in which the 
attributes of a collection will be addressed by the Flow operator.
In this algebra, the Flow operators use only Connectors 
(represented by a cell or collections CellularSpace and Trajectory) 
as operands and represents continuous transference of energy or 
matter between regions of space. The differential equation supplied 
as the first operator parameter determines the amount of energy 
transferred between regions.

##Installation

 To use any of the functions and types in 
 this [package](https://github.com/TerraME/terrame/wiki/Packages), 
 you must first download and install this package into your 
 TerraME platform. This package is available for download on the 
 releases tab of the git hub project.

 After downloading the .zip file, open the TerraME platform, select 
 "install new package" and choose the "ssd.zip" file. To be able 
 to use an installed package in your programs, you must first import 
 it using:
> import("ssd")
