@echo off
chcp 65001 > nul

git add .
git commit -m "Экзаменационные вопросы: обновлено"
git push origin main --force