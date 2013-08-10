EXIF Cloner
===========

Description
-----------

A simple Mac applications for copying image metadata from one picture file to a bunch of others.
Support metadata for `jpg`, `tiff`, `png` and others.

Useful if your image editor software loses track of those metadata during the edition process.
Feel free to contribute any improvement.

EXIF Cloner is built in Objective-C++, uses AutoLayout and does *not* use Automatic Reference Counting.
A small set of unit tests is provided to make sure the program behaves as expected.

Contributing
------------

Obviously I am no designer. If you feel like contributing and have some talent as an icon designer or UI designer, I think your talent can be put to good use: please contact me so we can work out something.
Code contributions are also more than welcome if you feel like some things need to be ironed out.

Building the project
--------------------

`git clone` this repository (or download it as a zip) and just build the main target in the project.

This program links against [`libexiv2`](http://www.exiv2.org), an open-source library for EXIF, XMP and IPTC metadata parsing.
The recommended way to get it is by using [homebrew](http://brew.sh): `brew install exiv2`.

Contacting the author
---------------------

The most efficient way to get in touch with me is [Twitter](http://twitter.com/Olotiar).

Licensing
---------

This software is released under the GPL v3 license. 
Any software using any part of this source code should be published under the GPL v3 license and its source code made available.
The full license text is available in the LICENSE file at the root of this repository.
