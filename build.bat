@if exist "%~dp0cefcapi.exe" (
    @del "%~dp0cefcapi.exe"
)

gcc -Wall -Werror -I. -L. main_windows.c -o cefcapi.exe -lcef
call "cefcapi.exe"

:end
@echo exit code = %ERRORLEVEL%
