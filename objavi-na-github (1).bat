@echo off
setlocal EnableExtensions
title Objava projekta RPS na GitHub
cd /d "%~dp0"
echo.
echo ===== Objava projekta RPS na GitHub =====
echo Mapa: %CD%
echo.

if exist "index.html" goto foundhtml
echo NAPAKA: v tej mapi ni datoteke index.html.
echo Datoteko objavi-na-github.bat morate zagnati iz RAZPAKIRANE mape rps,
echo ne neposredno iz ZIP-a. Desni klik na ZIP, Izvleci vse, nato zazenite znova.
goto end
:foundhtml

echo %CD% | findstr /i /c:"\AppData\Local\Temp" >nul
if errorlevel 1 goto gitcheck
echo NAPAKA: datoteka je zagnana iz zacasne mape, verjetno neposredno iz ZIP-a.
echo Razpakirajte ZIP in jo zazenite iz razpakirane mape.
goto end

:gitcheck
where git >nul 2>nul
if not errorlevel 1 goto gitfound
if exist "C:\Program Files\Git\cmd\git.exe" set "PATH=%PATH%;C:\Program Files\Git\cmd"
where git >nul 2>nul
if not errorlevel 1 goto gitfound
echo NAPAKA: Git ni namescen.
echo Prenesite ga z https://git-scm.com/download/win , namestite z vsemi privzetimi
echo nastavitvami, zaprite to okno in zazenite datoteko znova.
goto end

:gitfound
git --version
echo.

set "GN="
for /f "delims=" %%i in ('git config --get user.name') do set "GN=%%i"
if defined GN goto haveemail
set /p GN=Vpisite svoje ime in priimek: 
if not defined GN goto noname
git config --global user.name "%GN%"
:haveemail
set "GE="
for /f "delims=" %%i in ('git config --get user.email') do set "GE=%%i"
if defined GE goto identok
set /p GE=Vpisite svoj e-postni naslov, isti kot na GitHubu: 
if not defined GE goto noname
git config --global user.email "%GE%"
:identok

echo.
echo Na github.com ustvarite PRAZEN repozitorij: New repository, brez README in brez .gitignore.
echo Nato prilepite njegovo povezavo, npr. https://github.com/uporabnik/rps.git
echo.
set "URL="
set /p URL=Povezava do repozitorija: 
if not defined URL goto nourl
set "URL=%URL:"=%"

echo.
if not exist ".git" git init
if errorlevel 1 goto gitfail
git symbolic-ref HEAD refs/heads/main
git add -A
if errorlevel 1 goto gitfail
git commit -m "Koncna oddaja projekta RPS: prototip HTML/CSS in dokumentacija"
git rev-parse --verify HEAD >nul 2>nul
if errorlevel 1 goto gitfail
git remote remove origin >nul 2>nul
git remote add origin "%URL%"
if errorlevel 1 goto gitfail

echo.
echo Posiljam na GitHub. Ob prvi uporabi se lahko odpre okno za prijavo...
git push -u origin main
if not errorlevel 1 goto pushok

echo.
echo Posiljanje ni uspelo. Ce ste v repozitoriju na GitHubu ze ustvarili README ali
echo drugo datoteko, lahko njegovo vsebino prepisete z vasim projektom.
set "F="
set /p F=Prepisati vsebino repozitorija na GitHubu? Vpisite d ali n: 
if /i not "%F%"=="d" goto pushfail
git push -u origin main --force
if errorlevel 1 goto pushfail

:pushok
git tag -f v1.0 >nul 2>nul
git push -f origin v1.0
git branch -f develop main
git push -u origin develop
echo.
echo ===== KONCANO. Projekt je na GitHubu: %URL% =====
echo Dodajte mentorja: Settings - Collaborators. Javna stran: Settings - Pages - veja main.
goto end

:noname
echo NAPAKA: ime ali e-postni naslov nista vpisana. Zazenite datoteko znova.
goto end

:nourl
echo NAPAKA: povezava ni vpisana. Zazenite datoteko znova.
goto end

:gitfail
echo.
echo NAPAKA pri ukazu Git. Prepisite zadnje sporocilo zgoraj in ga posljite.
goto end

:pushfail
echo.
echo NAPAKA: posiljanje na GitHub ni uspelo.
echo Preverite povezavo, ali ste prijavljeni v GitHub in ali imate pravico pisanja.

:end
echo.
pause
