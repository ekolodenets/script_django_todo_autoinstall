echo off
set project_name=testi
set core=core
set venv_name=venvi
set app_name=todo
set user=admin
set mail=admin@admin.com
set pass=off
set logfile=log.txt



if not exist %project_name% md %project_name%
cd %project_name%


::Virtual Environment
if not exist "%venv_name%" (echo Preparing Virtual Environment...
python -m venv %venv_name%
echo %time%  virtual environment succesfully installed>> %logfile%  
goto upgrading)


:virtual_exists
echo %time%  virtual environment exists>> %logfile%   


:upgrading
echo Installing and Upgrading files...
set env=%venv_name%\Scripts\activate
call %env% & python.exe -m pip install --upgrade pip & pip install django


::Creating Project
if not exist "%core%" (echo Creating core of the project...
django-admin startproject %core% .
echo %time%  core of the project succesfully created>> %logfile%
goto app_creating)


if exist "%core%" (echo Project already exists
echo %time%	 core of the project already exists>> %logfile%)


:app_creating
if not exist "%app_name%" (echo Creating app %app_name%...
py manage.py startapp %app_name%
echo %time%  app %app_name% succesfully created>> %logfile%
goto configuration)


if exist %app_name% (echo App already exists
echo %time%	 app %app_name% already exists>> %logfile%)


 



::Settings Configuration
:configuration
>nul find "add project name to settings" %logfile% && (
  echo %time%  project name already added to settings file>> %logfile%
) || (
setlocal enabledelayedexpansion
cd %core%
set /a count=1
for /f "tokens=* delims=" %%a in (settings.py) do (
    if !counter!==26 (
        echo     '%app_name%', >> output.txt
    )
    echo %%a >> output.txt
    set /a counter+=1
)
del settings.py
ren output.txt settings.py
cd ..
echo %time%	 add project name to settings>> %logfile%
)



::MAIN URLS
>nul find "main urls file modified" %logfile% && (
  echo %time%  main urls file was already modified>> %logfile%
) || (
cd %core%
setlocal enableExtensions disableDelayedExpansion
ren urls.py temp 
(for /F "tokens=1* delims=:" %%a in ('findstr /N "^" temp') do (
   if %%a equ 17 (
      echo(%%b, include
   ) else (
      if %%a equ 21 (
      echo(    path('', include('%app_name%.urls'^)^),
	echo(%%b
   ) else (
      echo(%%b
   )
   )
)) > urls.py
del temp
cd ..
echo %time%  main urls file modified>> %logfile%  
)



::App URLS
>nul find "app urls file created" %logfile% && (
  echo %time%  app urls file already exists>> %logfile%
) || (
cd %app_name%
(
echo from django.urls import path
echo\ 
echo from . import views
echo\ 
echo urlpatterns = [
echo     path('', views.index, name='index'^),
echo     path('add', views.add, name='add'^),
echo     path('delete/^<int:todo_id^>/', views.delete, name='delete'^),
echo     path('update/^<int:todo_id^>/', views.update, name='update'^),
echo ]
) > urls.py
cd..
echo %time%  app urls file created>> %logfile% 
)


::Models
>nul find "models file modified" %logfile% && (
  echo %time%  models file was already modified>> %logfile%
) || (
cd %app_name%
(
echo from django.db import models
echo\
echo class Todo(models.Model^):
echo     title = models.CharField(max_length=350^)
echo     completed = models.BooleanField(default=False^)
echo\
echo     def __str__(self^):
echo         return self.title
) > models.py
cd ..
echo %time%  models file modified>> %logfile%  
)


::Views
>nul find "views file modified" %logfile% && (
  echo %time%  views file was already modified>> %logfile%
) || (
cd %app_name%
(
echo from django.shortcuts import render, redirect
echo\from django.views.decorators.http import require_http_methods
echo\
echo\from .models import Todo
echo\
echo\
echo\def index(request^):
echo\    todos = Todo.objects.all(^).order_by('-id'^)
echo\    return render(request, 'index.html', {'todo_list':todos}^)
echo\
echo\
echo\@require_http_methods(['POST']^)
echo\def add(request^):
echo\    title = request.POST['title']
echo\    todo = Todo(title=title^)
echo\    todo.save(^)
echo\    return redirect('index'^)
echo\
echo\
echo\def update(request, todo_id^):
echo\    todo = Todo.objects.get(id=todo_id^)
echo\    todo.completed = not todo.completed
echo\    todo.save(^)
echo\    return redirect('index'^)
echo\
echo\
echo\def delete(request, todo_id^):
echo\    todo = Todo.objects.get(id=todo_id^)
echo\    todo.delete(^)
echo\    return redirect('index'^)
)> views.py
cd ..
echo %time%  views file modified>> %logfile%  
)




::Making Templates
>nul find "templates created" %logfile% && (
  echo %time%  templates already exists>> %logfile%
) || (
cd %app_name%
mkdir templates
cd templates
(
echo ^<!DOCTYPE html^>
echo ^<html lang="en"^>
echo ^<head^>
echo     ^<meta charset="UTF-8"^>
echo     ^<meta name="viewport" content="width=device-width, initial-scale=1.0"^>
echo     ^<title^>Todo App^</title^>
echo     ^<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/semantic-ui@2.4.2/dist/semantic.min.css"^>
echo     ^<script src="https://cdn.jsdelivr.net/npm/semantic-ui@2.4.2/dist/semantic.min.js"^>^</script^>
echo ^</head^>
echo ^<body^>
echo ^<div style="margin-top: 50px;" class="ui container "^>
echo     ^<div class="ui one column stackable center aligned page grid"^>
echo         ^<div class="column ten wide"^>
echo             ^<h1 class="ui header"^>To Do App^</h1^>
echo             ^<form class="ui form" action="/add" method="post"^>
echo                 {%% csrf_token %%}
echo             ^<div class="field"^>
echo             ^<label^>Todo Title^</label^>
echo             ^<input type="text" name="title" placeholder="Enter Todo..."^>^<br^>
echo             ^</div^>
echo         ^<button class="ui blue button " type="submit"^>Add^</button^>
echo             ^</form^>
echo         ^<hr^>
echo                 {%% for todo in todo_list %%}
echo             ^<div class="ui segment left aligned"^>
echo             ^<p class="ui big header"^>{{ todo.id }} ^| {{ todo.title }}
echo                 {%% if todo.completed == False %%}
echo             ^<span class="ui gray label"^>Not Complete^</span^>^</p^>
echo                 {%% else %%}
echo             ^<span class="ui green label"^>Completed^</span^>^</p^>
echo                 {%% endif %%}
echo             ^<a class="ui blue button" href="/update/{{ todo.id }}"^>On/Off^</a^>
echo             ^<a class="ui red button" href="/delete/{{ todo.id }}"^>Delete^</a^>
echo             ^</div^>
echo                 {%% endfor %%}
echo         ^</div^>
echo     ^</div^>
echo ^</div^>
echo ^</body^>
echo ^</html^>
)> index.html
cd ..
cd ..
echo %time%  templates created>> %logfile%
)



python manage.py makemigrations
python manage.py migrate

if %pass% == on python manage.py createsuperuser --username %user% --email %mail% --noinput & py manage.py changepassword %user%

>nul find "===project succesfully installed===" %logfile% && (
  echo %time%  project was reinstalled>> %logfile%
) || (
echo  ===project succesfully installed===
echo %time%  ===project succesfully installed===>> %logfile%
)
python manage.py runserver
