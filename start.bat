echo off
set venv_name=venvi
set env=%venv_name%\Scripts\activate

cd test
call %env%
python manage.py runserver   
pause