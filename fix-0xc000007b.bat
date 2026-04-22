@echo off
rem ============================================================
rem  File:        fix-0xc000007b.bat
rem  Description: Diagnose 0xC000007B (STATUS_INVALID_IMAGE_FORMAT)
rem               by comparing csrss-related DLLs between two
rem               Windows System32 directories via SHA256 hash.
rem               Reports files that are missing or differ from
rem               the reference directory.
rem
rem  Background:  0xC000007B typically indicates a bitness mismatch
rem               or corruption in DLLs loaded by csrss.exe at boot:
rem               csrsrv.dll, basesrv.dll, winsrv.dll, sxssrv.dll
rem
rem  Author:      Linden
rem  Created:     2026-04-21
rem
rem  Requires:    certutil (built-in on Windows)
rem
rem  License:     MIT License
rem               Copyright (c) 2026 Linden
rem ============================================================
setlocal enabledelayedexpansion

set "dir1=X:\Windows\System32"
set "dir2=C:\Windows\System32"

set "files=csrsrv.dll basesrv.dll winsrv.dll sxssrv.dll"

for %%N in (%files%) do (
    set "f1=!dir1!\%%N"
    set "f2=!dir2!\%%N"

    if not exist "!f1!" (
        echo NOT FOUND  !f1!
    ) else if not exist "!f2!" (
        echo NOT FOUND  !f2!
    ) else (
        set "hashX="
        set "hashC="

        for /f "delims=" %%A in (
            'certutil -hashfile "!f1!" SHA256 2^>nul ^| findstr /n "." ^| findstr "^2:"'
        ) do (
            if not defined hashX set "hashX=%%A"
        )

        for /f "delims=" %%A in (
            'certutil -hashfile "!f2!" SHA256 2^>nul ^| findstr /n "." ^| findstr "^2:"'
        ) do (
            if not defined hashC set "hashC=%%A"
        )

        if not "!hashX!"=="!hashC!" (
            echo DIFF  !f1!  ^<^>  !f2!
        )
    )
)

endlocal
