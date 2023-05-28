@echo off

cd /D %~dp0
python neural_style.py -style_image="examples/inputs/brad_pitt.jpg" -content_image="examples/inputs/woman-with-hat-matisse.jpg"

@pause