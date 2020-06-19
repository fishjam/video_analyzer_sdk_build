rem @echo off
setlocal 

rem ###############################################################################
rem usage:
rem   autobuild [build_type]
rem      build_type: [Release] | Debug
rem ###############################################################################

set ROOT_DIR=%~dp0
set BUILD_TYPE=Release

set CMAKE_GENERATOR="Visual Studio 14 2015 Win64"
set VS_DEVENV="%VS140COMNTOOLS%/../IDE/devenv.com"

set BUILD_LEPTONICA=1
set LEPTONICA_BRANCH=branch_1.74.4
set BUILD_TESSERACT=1
set TESSERACT_BRANCH=3.05
set BUILD_OPENCV=1
set OPENCV_BRANCH=branch_3.4.2_fixbug
set OPENCV_CONTRIB_BRANCH=3.4.2
set BUILD_VMAF=1
set VMAF_BRANCH=dynamic_win

if not "%1" == "" set BUILD_TYPE=%1

if "%BUILD_LEPTONICA%" == "1" (
    rem now will build for leptonica
    cd leptonica
    git checkout %LEPTONICA_BRANCH%
    if not "%ERRORLEVEL%" == "0" goto ERROR
    
    mkdir build_%BUILD_TYPE%
    cd build_%BUILD_TYPE%
    if not "%ERRORLEVEL%" == "0" goto ERROR

    cmake ^
        -G %CMAKE_GENERATOR% ^
        -DCMAKE_BUILD_TYPE=%BUILD_TYPE% ^
        -DCMAKE_INSTALL_PREFIX=%ROOT_DIR%result\win\%BUILD_TYPE% ^
        ..
        
    if not "%ERRORLEVEL%" == "0" goto ERROR

    rem "%VS140COMNTOOLS%/../IDE/devenv.com" videoAnalyzer.sln /build "%BUILD_TYPE%|x64"
    cmake --build . --config %BUILD_TYPE% --target INSTALL
    if not "%ERRORLEVEL%" == "0" goto ERROR
    
    cd %ROOT_DIR%
)

if "%BUILD_TESSERACT%" == "1" (
    rem now will build for tesseract
    cd tesseract
    mkdir build_%BUILD_TYPE% 
    cd build_%BUILD_TYPE%
    if not "%ERRORLEVEL%" == "0" goto ERROR

    cmake ^
        -G %CMAKE_GENERATOR% ^
        -DCMAKE_BUILD_TYPE=%BUILD_TYPE% ^
        -DBUILD_TRAINING_TOOLS=OFF ^
        -DLeptonica_Dir=%ROOT_DIR%result\win\cmake ^
        -DCMAKE_INSTALL_PREFIX=%ROOT_DIR%result\win\%BUILD_TYPE% ^
        ..
        
    if not "%ERRORLEVEL%" == "0" goto ERROR

    cmake --build . --config %BUILD_TYPE% --target INSTALL
    if not "%ERRORLEVEL%" == "0" goto ERROR
    
    cd %ROOT_DIR%
)

if "%BUILD_OPENCV%" == "1" (
    rem now will build for opencv
    cd %ROOT_DIR%\opencv_contrib
    git checkout %OPENCV_CONTRIB_BRANCH%
    if not "%ERRORLEVEL%" == "0" goto ERROR
    
    cd %ROOT_DIR%\opencv
    git checkout %OPENCV_BRANCH%
    if not "%ERRORLEVEL%" == "0" goto ERROR
    
    mkdir build_%BUILD_TYPE%
    cd build_%BUILD_TYPE%
    if not "%ERRORLEVEL%" == "0" goto ERROR

    cmake ^
        -G %CMAKE_GENERATOR% ^
        -DCMAKE_BUILD_TYPE=%BUILD_TYPE% ^
        -DCMAKE_INSTALL_PREFIX=%ROOT_DIR%result\win\%BUILD_TYPE% ^
        -DOPENCV_EXTRA_MODULES_PATH=%ROOT_DIR%\opencv_contrib\modules ^
        -DOPENCV_ENABLE_NONFREE=ON ^
        -DBUILD_SHARED_LIBS=ON ^
        -DBUILD_opencv_world=ON ^
        -DBUILD_TESTS=OFF ^
        -DBUILD_EXAMPLES=OFF ^
        ..
        
    if not "%ERRORLEVEL%" == "0" goto ERROR

    cmake --build . --config %BUILD_TYPE% --target INSTALL
    if not "%ERRORLEVEL%" == "0" goto ERROR
    
    cd %ROOT_DIR%
)

if "%BUILD_VMAF%" == "1" (
      cd vmaf
      git checkout %VMAF_BRANCH%
      if not "%ERRORLEVEL%" == "0" goto ERROR

      %VS_DEVENV% vmaf.sln /build "%BUILD_TYPE%|x64"
      if not "%ERRORLEVEL%" == "0" goto ERROR

      mkdir %ROOT_DIR%result\win\%BUILD_TYPE%\include\vmaf
      xcopy /v /y wrapper\src\libvmaf.h %ROOT_DIR%result\win\%BUILD_TYPE%\include\vmaf
      if not "%ERRORLEVEL%" == "0" goto ERROR

      xcopy /v /y x64\%BUILD_TYPE%\*.lib %ROOT_DIR%result\win\%BUILD_TYPE%\lib
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


:DONE
endlocal
@echo ***************************************************
@echo Build Process Done...
@echo ***************************************************
@exit /b 0
