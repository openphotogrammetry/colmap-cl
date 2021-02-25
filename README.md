COLMAP-CL
=========
COLMAP-CL is an OpenCL implementation of the [COLMAP](https://demuc.de/colmap/) photogrammetry software originally developed by Johannes L. Schönberger. COLMAP and COLMAP-CL provide an interface to structure-from-motion (SFM) and dense multiview-stereo (MVS) algorithms for reconstructing 3D models from collections of images. While the original COLMAP required CUDA to achieve accelerated performance, COLMAP-CL is developed with the OpenCL API and can run on a variety of GPU platforms (AMD, Intel, NVIDIA, etc.).

Getting Started
---------------
Binary executables for the Windows version of COLMAP-CL can be downloaded from https://github.com/openphotogrammetry/colmap-cl/releases. After saving and unzipping the zip file, COLMAP-CL can be run via the `COLMAP.bat` file. If executed with no parameters, this file will start the GUI.

In the COLMAP-CL GUI interface, novice users usually use the _Reconstruction &rarr; Automatic reconstruction_ menu option to produce a 3D model from their images. Experienced users prefer to use COLMAP-CL via scripts or the command-line interface. We've included some example scripts in the [`scripts/`](scripts) folder that execute the steps of the 3D reconstruction pipeline.

Documentation
-------------
COLMAP-CL is simply a port of COLMAP from CUDA to OpenCL, so the original COLMAP documentation still applies to COLMAP-CL. The COLMAP documentation site is at https://colmap.github.io/.

Several introductory videos for using COLMAP are available on YouTube. One such video tutorial focusing on the GUI's automatic reconstruction process is at https://www.youtube.com/watch?v=Zm1mkOi9_1c.

Support
-------
For general COLMAP technical support, there is a COLMAP Google Group at https://groups.google.com/forum/#!forum/colmap (colmap@googlegroups.com) and the COLMAP GitHub issue tracker at https://github.com/colmap/colmap.

If your question specifically concerns this OpenCL implementation (COLMAP-CL), please open an issue on the COLMAP-CL GitHub at https://github.com/openphotogrammetry/colmap-cl/issues. We welcome your bug reports, questions, feature requests, and other feedback!

Frequently Asked Questions
--------------------------
### How can I specify which of my GPUs that COLMAP-CL should use?

In the original CUDA COLMAP, the `gpu_index` field is used to specify which CUDA devices should be used for processing. This same field is used in COLMAP-CL, but with a small difference due to the Platform/Device scheme for referencing OpenCL devices. In COLMAP-CL, your `gpu_index` should be computed by multiplying the platform index by 1000, and adding the device index, i.e. `gpu_index` = *platform* \*1000 + *device*. Both the platform and device indexes start from zero, and can be determined from the `clinfo` command output.

Multiple GPUs can be specified with a comma-separated list. For example, if you want COLMAP-CL to use both the first device of the first platform, and the second device of the second platform, you would set `gpu_index` to the value `0,1001`.

If the `gpu_index` field is left at the default value of `-1`, COLMAP-CL will try to automatically choose the best set of OpenCL devices that it can detect on your system.

### Which components of COLMAP-CL are OpenCL-accelerated?

The image feature matching (`exhaustive_matcher`, `sequential_matcher`, `spatial_matcher`, `transitive_matcher`, `vocab_tree_matcher`) and dense multiview stereo (`patch_match_stereo`) modules of COLMAP have been ported to OpenCL.

### Is the OpenCL acceleration as fast as the CUDA implementation?

Yes, on similar hardware, COLMAP-CL often processes data roughly as fast as the CUDA version, but sometimes faster and sometimes slower. The OpenCL version is optimized differently than CUDA COLMAP, so the performance can differ depending on your particular GPUs and input parameters.

For comparison, here are some COLMAP-CL timings for SIFT feature matching (`colmap exhaustive_matcher`) on a common photogrammetry bechmarking dataset (ETH3D's *facade*, 76 images with ~940,000 total features):

| Platform | Time (s) |
| -------- | -------: |
| COLMAP-CL CPU (28-core Xeon)   | 9182 |
| COLMAP-CL OpenCL (AMD Vega 56) |  261 |
| COLMAP-CL OpenCL (NV RTX 2070) |   69 |
| COLMAP CUDA (NV RTX 2070)      |   88 |

And comparing COLMAP and COLMAP-CL processing time for multiview stereo (`colmap patch_match_stereo`) on the ETH3D *pipes* dataset (default parameters, `max_image_size`=2000):

|Platform | Time (min) |
|-------- | ----------- |
|COLMAP CUDA (NV RTX 2070) | 7.720 |
|COLMAP-CL OpenCL (NV RTX 2070) | 4.527 |
|COLMAP-CL OpenCL (AMD Vega 56) | 3.423 |

In general, COLMAP-CL's `patch_match_stereo` processing time grows linearly with the number of source images and is independent of the `PatchMatchStereo.num_samples` argument, whereas COLMAP processing time grows linearly with `PatchMatchStereo.num_samples`.
