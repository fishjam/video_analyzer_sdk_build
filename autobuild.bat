@echo on
setlocal 

set ROOT_DIR=%~dp0
set BUILD_LEPTONICA=1
set LEPTONICA_BRANCH=branch_1.74.4

set BUILD_TESSERACT=1
set TESSERACT_BRANCH=3.05

if "%BUILD_LEPTONICA%" == "1" (
    rem now will build for leptonica
    cd leptonica
    git checkout %LEPTONICA_BRANCH%
    if not "%ERRORLEVEL%" == "0" goto ERROR
    
    mkdir build
    cd build
    if not "%ERRORLEVEL%" == "0" goto ERROR

    cmake ^
        -G "Visual Studio 14 2015 Win64" ^
        -DCMAKE_INSTALL_PREFIX=%ROOT_DIR%result\win ^
        ..
        
    if not "%ERRORLEVEL%" == "0" goto ERROR

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
        -G "Visual Studio 14 2015 Win64" ^
        -DBUILD_TRAINING_TOOLS=OFF ^
        -DLeptonica_Dir=%ROOT_DIR%result\win\cmake ^
        -DCMAKE_INSTALL_PREFIX=%ROOT_DIR%result\win ^
        ..
        
    if not "%ERRORLEVEL%" == "0" goto ERROR

    cmake --build . --config Release --target INSTALL
    if not "%ERRORLEVEL%" == "0" goto ERROR
    
    cd %ROOT_DIR%
)

goto Done

:ERROR
cd %ROOT_DIR%
endlocal
@echo on
@echo autobuild.cmd failed
pause
@exit /b 1

:Done
endlocal
@echo ***************************************************
@echo Build Process Done...
@echo ***************************************************
pause
