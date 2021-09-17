Contains three changeLog repositories :

1. Репозиторій ініціації бази даних реєстру, відповідає за базові налаштування БД (changelog-master-pre-deploy.xml):
    - недоступний адміністратору реєстру
    - містить domains та version control.
    - статичний й незмінний для усіх реєстрів
    - використовує стандартну функціональність liquibase
    - застосовується першим зразу після створення БД реєстру
2. Репозиторій, створений адміністратором реєстру (changelog-master.xml):
    - наповнюється відповідальним адміністратором
    - містить об'єкти, що відповідають моделі даних реєстру
    - використовує додатково розроблену функціональність liquibase
    - застосовується наступним після репозиторію ініціації
3. Репозиторій ініціації бази даних реєстру, відповідає за базові налаштування БД (changelog-master-post-deploy.xml):
    - недоступний адміністратору реєстру
    - містить дії, що необхідно виконати постфактум
    - статичний й незмінний для усіх реєстрів
    - використовує стандартну функціональність liquibase
    - застосовується останнім після репозиторію розгортання моделі даних реєстру
