rem @echo off
setlocal enabledelayedexpansion

rem ###############################################################################
rem usage:
rem   autobuild.bat [build_type] > build.log 2>&1
rem      build_type: [Release] | Debug
rem   then use tail -f build.log to check the build log
rem     https://ericwengrowski.com/pycv/
rem  TODO: D:\Anaconda3;D:\Anaconda3\Library\mingw-w64\bin;D:\Anaconda3\Library\usr\bin;
rem     D:\Anaconda3\Library\bin;D:\Anaconda3\Scripts
rem ###############################################################################

set ROOT_DIR=%~dp0

rem change "\\" to "/" for python path
set ROOT_DIR_SLASH=%ROOT_DIR:\=/%
echo %ROOT_DIR_SLASH%

set BUILD_TYPE=Debug
if not "%1" == "" set BUILD_TYPE=%1
set RESULT_OUTPUT=%ROOT_DIR%result\win\%BUILD_TYPE%
set RESULT_OUTPUT_SLASH=%ROOT_DIR_SLASH%result/win/%BUILD_TYPE%

set CMAKE_GENERATOR="Visual Studio 14 2015 Win64"
set VS_DEVENV="%VS140COMNTOOLS%/../IDE/devenv.com"

set PYTHON_PATH=D:/Python3
if "%BUILD_TYPE%" == "Debug" set PYTHON_LIB_NAME=python38_d.lib
if "%BUILD_TYPE%" == "Release" set PYTHON_LIB_NAME=python38.lib
echo "python library value is %PYTHON_PATH%/libs/%PYTHON_LIB_NAME%"

set BUILD_LEPTONICA=1
set LEPTONICA_BRANCH=branch_1.74.4
set BUILD_TESSERACT=1
set TESSERACT_BRANCH=3.05
set BUILD_OPENCV=1
rem set OPENCV_BRANCH=branch_3.4.2_fixbug
rem set OPENCV_CONTRIB_BRANCH=3.4.2
set OPENCV_BRANCH=branch_3.4.2_fixbug
set OPENCV_CONTRIB_BRANCH=branch_3.4.2
set BUILD_OPENCV_PYTHON=1
set BUILD_VMAF=1
set VMAF_BRANCH=dynamic_win
rem set CMAKE_COMMON_OPTS=-Wdev --trace
set CMAKE_COMMON_OPTS=

if "%BUILD_LEPTONICA%" == "1" (
    rem now will build for leptonica
    cd %ROOT_DIR%leptonica
    git checkout %LEPTONICA_BRANCH%
    if not "!ERRORLEVEL!" == "0" (
      echo "checkout leptonica error"
      goto ERROR
    )

    rem build zlib for leptonica 
    cd %ROOT_DIR%leptonica\libs\zlib-1.2.11
    mkdir build_%BUILD_TYPE%
    cd build_%BUILD_TYPE%
    cmake ^
        -G %CMAKE_GENERATOR% ^
        -DCMAKE_BUILD_TYPE=%BUILD_TYPE% ^
        -DCMAKE_INSTALL_PREFIX=%RESULT_OUTPUT% ^
        ..
    if not "!ERRORLEVEL!" == "0" (
      echo "cmake for zlib error"
      goto ERROR
    )

    cmake --build . --config %BUILD_TYPE% --target INSTALL
    if not "!ERRORLEVEL!" == "0" (
      echo "build for zlib error"
      goto ERROR
    )
    
    rem build png for leptonica 
    cd %ROOT_DIR%leptonica\libs\lpng1637
    mkdir build_%BUILD_TYPE%
    cd build_%BUILD_TYPE%
    echo "now will call cmake for lpng"
    cmake ^
        -G %CMAKE_GENERATOR% ^
        -DCMAKE_BUILD_TYPE=%BUILD_TYPE% ^
        -DCMAKE_INSTALL_PREFIX=%RESULT_OUTPUT% ^
        ..
    if not "!ERRORLEVEL!" == "0" (
      echo "cmake for lpng error"
      goto ERROR
    )

    echo "now will build for lpng"
    cmake --build . --config %BUILD_TYPE% --target INSTALL
    if not "!ERRORLEVEL!" == "0" (
      echo "build for lpng error"
      goto ERROR
    )

    rem now build for leptonica
    cd %ROOT_DIR%leptonica
    mkdir build_%BUILD_TYPE%
    cd build_%BUILD_TYPE%

    cmake ^
        -G %CMAKE_GENERATOR% ^
        -DNO_SYSTEM_ENVIRONMENT_PATH=ON ^
        -DCMAKE_BUILD_TYPE=%BUILD_TYPE% ^
        -DCMAKE_INSTALL_PREFIX=%RESULT_OUTPUT% ^
        ..
    if not "!ERRORLEVEL!" == "0" (
      echo "cmake for leptonica error"
      goto ERROR
    )

    rem "%VS140COMNTOOLS%/../IDE/devenv.com" videoAnalyzer.sln /build "%BUILD_TYPE%|x64"
    cmake --build . --config %BUILD_TYPE% --target INSTALL
    if not "!ERRORLEVEL!" == "0" (
      echo "build for leptonica error"
      goto ERROR
    )
    cd %ROOT_DIR%
)

if "%BUILD_TESSERACT%" == "1" (
    rem now will build for tesseract
    cd tesseract
    mkdir build_%BUILD_TYPE% 
    cd build_%BUILD_TYPE%

    cmake ^
        -G %CMAKE_GENERATOR% ^
        -DCMAKE_BUILD_TYPE=%BUILD_TYPE% ^
        -DBUILD_TRAINING_TOOLS=OFF ^
        -DLeptonica_Dir=%ROOT_DIR%result\win\cmake ^
        -DCMAKE_INSTALL_PREFIX=%RESULT_OUTPUT% ^
        ..
    if not "!ERRORLEVEL!" == "0" (
      echo "cmake for tesseract error"
      goto ERROR
    )

    cmake --build . --config %BUILD_TYPE% --target INSTALL
    if not "!ERRORLEVEL!" == "0" (
      echo "build for tesseract error"
      goto ERROR
    )

    cd %ROOT_DIR%
)

if "%BUILD_OPENCV%" == "1" (
    rem now will build for opencv
    cd %ROOT_DIR%opencv_contrib
    git checkout %OPENCV_CONTRIB_BRANCH%
    if not "!ERRORLEVEL!" == "0" (
      echo "checkout for opencv_contrib error"
      goto ERROR
    )

    cd %ROOT_DIR%opencv
    git checkout %OPENCV_BRANCH%
    if not "!ERRORLEVEL!" == "0" (
      echo "checkout for opencv error"
      goto ERROR
    )

    mkdir build_%BUILD_TYPE%
    cd build_%BUILD_TYPE%

    echo "now will cmake for opencv"
    rem -DPYTHON3_PACKAGES_PATH=%PYTHON_PATH%/lib/site-packages ^
    cmake %CMAKE_COMMON_OPTS% ^
        -G %CMAKE_GENERATOR% ^
        -DCMAKE_BUILD_TYPE=%BUILD_TYPE% ^
        -DCMAKE_INSTALL_PREFIX=%RESULT_OUTPUT% ^
        -DOPENCV_EXTRA_MODULES_PATH=%ROOT_DIR%opencv_contrib\modules ^
        -DOPENCV_ENABLE_NONFREE=ON ^
        -DBUILD_SHARED_LIBS=ON ^
        -DBUILD_WITH_STATIC_CRT=OFF ^
        -DBUILD_opencv_world=ON ^
        -DBUILD_opencv_python2=OFF ^
        -DBUILD_opencv_python3=OFF ^
        -DPYTHON_EXECUTABLE:FILEPATH=%PYTHON_PATH%/python.exe ^
        -DPYTHON3_PACKAGES_PATH=%RESULT_OUTPUT%/python/site-packages ^
        -DPYTHON3_INCLUDE_DIR=%PYTHON_PATH%/include ^
        -DPYTHON3_EXECUTABLE=%PYTHON_PATH%/python.exe ^
        -DPYTHON3_LIBRARY=%PYTHON_PATH%/libs/%PYTHON_LIB_NAME% ^
        -DPYTHON3_NUMPY_INCLUDE_DIRS=%PYTHON_PATH%/Lib/site-packages/numpy/core/include ^
        -DINSTALL_PYTHON_EXAMPLES=OFF ^
        -DBUILD_TESTS=OFF ^
        -DBUILD_EXAMPLES=OFF ^
        -DWITH_IPP=OFF ^
        ..

    if not "!ERRORLEVEL!" == "0" (
      echo "cmake for opencv error"
      goto ERROR
    )

    echo "now will build for opencv"
    cmake --build . --config %BUILD_TYPE% --target INSTALL
    if not "!ERRORLEVEL!" == "0" (
      echo "build for opencv error"
      goto ERROR
    )

    cd %ROOT_DIR%
)

if "%BUILD_VMAF%" == "1" (
    cd vmaf
    git checkout %VMAF_BRANCH%
    if not "!ERRORLEVEL!" == "0" (
      echo "checkout for vmaf error"
      goto ERROR
    )

    %VS_DEVENV% vmaf.sln /build "%BUILD_TYPE%|x64"
    if not "!ERRORLEVEL!" == "0" (
      echo "build for vmaf error"
      goto ERROR
    )
      
    mkdir %RESULT_OUTPUT%\include\vmaf
    xcopy /v /y wrapper\src\libvmaf.h %RESULT_OUTPUT%\include\vmaf
    if not "!ERRORLEVEL!" == "0" (
      echo "copy for libvmaf.h error"
      goto ERROR
    )

    xcopy /v /y x64\%BUILD_TYPE%\*.lib %RESULT_OUTPUT%\lib
    if not "!ERRORLEVEL!" == "0" (
      echo "copy for vmaf libraries error"
      goto ERROR
    )
    cd %ROOT_DIR%
)

goto DONE

:ERROR
cd %ROOT_DIR%
endlocal
@echo on
@echo autobuild.cmd failed
@exit /b 1


:DONE
endlocal
@echo ***************************************************
@echo Build Process Done...
@echo ***************************************************
@exit /b 0
