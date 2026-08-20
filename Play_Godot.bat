@echo off
chcp 65001 >nul
echo 正在啟動《水滸英雄錄：天導108星》純 2D 等角 (Isometric 2.5D) 復古戰略版...
set GODOT="C:\Users\Sam\AppData\Local\Microsoft\WinGet\Packages\GodotEngine.GodotEngine_Microsoft.Winget.Source_8wekyb3d8bbwe\Godot_v4.7.2-stable_win64.exe"
set PROJECT="c:\Users\Sam\Documents\antigravity\Game Developing\HeroesOfTheLake_Godot"

start "" %GODOT% --path %PROJECT%
