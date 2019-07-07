@echo off
setlocal 

set ROOT_DIR=%~dp0
set ACTION=

set CMAKE_GENERATOR="Visual Studio 14 2015 Win64"
set BUILD_LEPTONICA=1
set LEPTONICA_BRANCH=branch_1.74.4
set BUILD_TESSERACT=1
set TESSERACT_BRANCH=3.05
set BUILD_OPENCV=1
OPENCV_BRANCH=branch_3.4.2_fixbug

if not "%1" == "" set ACTION=%1
if "%ACTION%" == "clean" (
  cd %ROOT_DIR%FFmpeg && rm -rf build
  cd %ROOT_DIR%opencv && rm -rf build
  cd %ROOT_DIR%leptonica && rm -rf build
  cd %ROOT_DIR%tesseract && rm -rf build
  goto CLEAN
)


if "%BUILD_LEPTONICA%" == "1" (
    rem now will build for leptonica
    cd leptonica
    git checkout %LEPTONICA_BRANCH%
    if not "%ERRORLEVEL%" == "0" goto ERROR
    
    mkdir build
    cd build
    if not "%ERRORLEVEL%" == "0" goto ERROR

    cmake ^
        -G %CMAKE_GENERATOR% ^
        -DCMAKE_INSTALL_PREFIX=%ROOT_DIR%result\win ^
        ..
        
    if not "%ERRORLEVEL%" == "0" goto ERROR

    rem "%VS140COMNTOOLS%/../IDE/devenv.com" videoAnalyzer.sln /build "%BUILD_TYPE%|x64"
    cmake --build . --config Release --target INSTALL
    if not "%ERRORLEVEL%" == "0" goto ERROR
    
    cd %ROOT_DIR%
)

if "%BUILD_TESSERACT%" == "1" (
    rem now will build for tesseract
    cd tesseract
    mkdir build 
    cd build
    if not "%ERRORLEVEL%" == "0" goto ERROR

    cmake ^
        -G %CMAKE_GENERATOR% ^
        -DBUILD_TRAINING_TOOLS=OFF ^
        -DLeptonica_Dir=%ROOT_DIR%result\win\cmake ^
        -DCMAKE_INSTALL_PREFIX=%ROOT_DIR%result\win ^
        ..
        
    if not "%ERRORLEVEL%" == "0" goto ERROR

    cmake --build . --config Release --target INSTALL
    if not "%ERRORLEVEL%" == "0" goto ERROR
    
    cd %ROOT_DIR%
)

if "%BUILD_OPENCV%" == "1" (
    rem now will build for opencv
    cd opencv
    git checkout %OPENCV_BRANCH%
    if not "%ERRORLEVEL%" == "0" goto ERROR
    
    mkdir build
    cd build
    if not "%ERRORLEVEL%" == "0" goto ERROR

    cmake ^
        -G %CMAKE_GENERATOR% ^
        -DCMAKE_INSTALL_PREFIX=%ROOT_DIR%result\win ^
        -DBUILD_SHARED_LIBS=ON ^
        -DBUILD_opencv_world=ON ^
        -DBUILD_TESTS=OFF ^
        -DBUILD_EXAMPLES=OFF ^
        ..
        
    if not "%ERRORLEVEL%" == "0" goto ERROR

    cmake --build . --config Release --target INSTALL
    if not "%ERRORLEVEL%" == "0" goto ERROR
    
    cd %ROOT_DIR%
)

goto DONE

:ERROR
cd %ROOT_DIR%
endlocal
@echo on
@echo autobuild.cmd failed
pause
@exit /b 1

:CLEAN
cd %ROOT_DIR%
endlocal
@echo ***************************************************
@echo Clean Process Done...
@echo ***************************************************
@exit /b 0

:DONE
endlocal
@echo ***************************************************
@echo Build Process Done...
@echo ***************************************************
pause
@exit /b 0
