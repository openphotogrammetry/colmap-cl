:: This script for COLMAP-CL can be used to reconstruct
:: a 3D model from a folder of input images. The script
:: assumes that all the images were photographed with the same
:: camera with the same camera settings.
::
:: Set the three paths below to point to the COLMAP.bat file,
:: the folder containing your input images, and a folder to 
:: store the project files, respectively.

set COLMAP_PATH=C:\COLMAP-CL-0.8-windows\COLMAP.bat
set IMAGES_DIR=C:\Users\Owner\Desktop\Images\
set WORKSPACE_DIR=C:\Users\Owner\Desktop\COLMAP-Workspace\


if not exist %WORKSPACE_DIR% mkdir %WORKSPACE_DIR%

call %COLMAP_PATH% feature_extractor^
   --database_path %WORKSPACE_DIR%\reconstruction.db^
   --image_path %IMAGES_DIR%^
   --ImageReader.camera_model OPENCV^
   --ImageReader.single_camera 1^
   --SiftExtraction.use_gpu 0

call %COLMAP_PATH% exhaustive_matcher^
   --database_path %WORKSPACE_DIR%\reconstruction.db^
   --SiftMatching.guided_matching 1

set SPARSE_DIR=%WORKSPACE_DIR%\sparse
if not exist %SPARSE_DIR% mkdir %SPARSE_DIR%

call %COLMAP_PATH% mapper^
   --database_path %WORKSPACE_DIR%\reconstruction.db^
   --image_path %IMAGES_DIR%^
   --output_path %SPARSE_DIR%^
   --Mapper.ba_refine_principal_point 1

set DENSE_DIR=%WORKSPACE_DIR%\dense
if not exist %SDENSE_DIR% mkdir %DENSE_DIR%

call %COLMAP_PATH% image_undistorter^
   --image_path %IMAGES_DIR%^
   --input_path %SPARSE_DIR%\0\^
   --output_path %DENSE_DIR%

call %COLMAP_PATH% patch_match_stereo^
   --workspace_path %DENSE_DIR%^
   --PatchMatchStereo.window_radius 5

call %COLMAP_PATH% stereo_fusion^
   --workspace_path %DENSE_DIR%^
   --output_path %DENSE_DIR%\fused.ply

call %COLMAP_PATH% poisson_mesher^
   --input_path %DENSE_DIR%\fused.ply^
   --output_path %DENSE_DIR%\meshed-poisson.ply^
   --PoissonMeshing.depth 13

call %COLMAP_PATH% delaunay_mesher^
   --input_path %DENSE_DIR%^
   --output_path %DENSE_DIR%\meshed-delaunay.ply
