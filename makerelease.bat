rmdir /s Release
mkdir Release

mkdir Release\Art
mkdir Release\Art\Audio
copy Art\Audio\*.ogg Release\Art\Audio
mkdir Release\Art\Game
copy Art\Game\*.png Release\Art\Game
mkdir Release\Art\Fonts
copy Art\Fonts\*.ttf Release\Art\Fonts
mkdir Release\Art\Splash
copy Art\Splash\*.png Release\Art\Splash

mkdir Release\Cars
copy Cars\*.* Release\Cars
mkdir Release\Crowd
copy Crowd\*.* Release\Crowd
mkdir Release\Dudes
copy Dudes\*.* Release\Dudes
mkdir Release\Scenes
copy Scenes\*.* Release\Scenes
mkdir Release\Scripts
copy Scripts\*.* Release\Scripts
mkdir Release\Shaders
copy Shaders\*.* Release\Shaders

mkdir Release\osx
copy osx\*.* Release\osx
mkdir Release\win32
copy win32\*.* Release\win32

copy Main.lua Release\
copy run.command Release\
copy Run.cmd Release\

del Release.zip
7z a Release.zip Release\