#Использовать asserts
#Использовать logos

Перем Лог;

Функция ОбернутьВКавычки(Знач Строка)
    Возврат """" + Строка + """";
КонецФункции

Процедура ВыполнитьКоманду(Знач КомандаЗапуска, Знач ТекстОшибки = "", Знач РабочийКаталог = "")
    
    Лог.Информация("Выполняю команду: " + КомандаЗапуска);
    
    Процесс = СоздатьПроцесс("cmd.exe /C " + ОбернутьВКавычки(КомандаЗапуска), РабочийКаталог, Истина, , КодировкаТекста.UTF8);
    Процесс.Запустить();
    
    Процесс.ОжидатьЗавершения();
    
    Пока НЕ Процесс.Завершен ИЛИ Процесс.ПотокВывода.ЕстьДанные Цикл
        СтрокаВывода = Процесс.ПотокВывода.ПрочитатьСтроку();
        Сообщить(СтрокаВывода);
    КонецЦикла;
    
    Если Процесс.КодВозврата <> 0 Тогда
        Лог.Ошибка("Код возврата: " + Процесс.КодВозврата);
        ВызватьИсключение ТекстОшибки + Символы.ПС + Процесс.ПотокОшибок.Прочитать();
    КонецЕсли;
    
КонецПроцедуры

Процедура Инициализация()
    
    Лог = Логирование.ПолучитьЛог("oscript.app.crowdin-create-new-branch");
    
КонецПроцедуры

Процедура ЗапускВКоманднойСтроке()
    
    СистемнаяИнформация = Новый СистемнаяИнформация;
    // DEBUG
    // СистемнаяИнформация.УстановитьПеременнуюСреды("GIT_LOCAL_BRANCH", "6.0");
    // СистемнаяИнформация.УстановитьПеременнуюСреды("CROWDIN_API_KEY", "YOUR_API_TOKEN");
    
    ИмяВеткиГит = СистемнаяИнформация.ПолучитьПеременнуюСреды("GIT_LOCAL_BRANCH");
    
    Ожидаем.Что(ИмяВеткиГит, "Переменная окружения GIT_LOCAL_BRANCH не установлена").Заполнено();
	Ожидаем.Что(ИмяВеткиГит, "Переменная окружения CROWDIN_API_KEY не установлена").Заполнено();

	Лог.Информация("GIT_LOCAL_BRANCH=" + ИмяВеткиГит);

	КаталогСФайламиКПереводу = ОбъединитьПути(ТекущийКаталог(), "src");
	ФайлыКПереводу = НайтиФайлы(КаталогСФайламиКПереводу, "*.properties", Истина);

	СтрокаДляДобавления = "#ü";
	Для Каждого ФайлКПереводу Из ФайлыКПереводу Цикл
		
        Если СтрЗаканчиваетсяНа(ФайлКПереводу.ПолноеИмя, "_ru.properties") Тогда
            Продолжить;
        КонецЕсли;
        
        Лог.Информация("Найден файл " + ФайлКПереводу.ПолноеИмя);
        Лог.Информация("Добавляем служебные символы");

        Текст = Новый ТекстовыйДокумент;
        Текст.Прочитать(ФайлКПереводу.ПолноеИмя);
        Текст.ДобавитьСтроку(СтрокаДляДобавления);
        Текст.Записать(ФайлКПереводу.ПолноеИмя, КодировкаТекста.UTF8NoBom);

    КонецЦикла;

	КомандаЗапуска = СтрШаблон("crowdin upload sources -b %1", ИмяВеткиГит);
	ВыполнитьКоманду(КомандаЗапуска);

	Для Каждого ФайлКПереводу Из ФайлыКПереводу Цикл
		
        Если СтрЗаканчиваетсяНа(ФайлКПереводу.ПолноеИмя, "_ru.properties") Тогда
            Продолжить;
        КонецЕсли;
        
        Лог.Информация("Найден файл " + ФайлКПереводу.ПолноеИмя);
        Лог.Информация("Убираем служебные символы");

        Текст = Новый ТекстовыйДокумент;
        Текст.Прочитать(ФайлКПереводу.ПолноеИмя);
        Текст.УдалитьСтроку(Текст.КоличествоСтрок());
        Текст.Записать(ФайлКПереводу.ПолноеИмя, КодировкаТекста.UTF8NoBom);

    КонецЦикла;

	КомандаЗапуска = СтрШаблон("crowdin upload sources -b %1", ИмяВеткиГит);
	ВыполнитьКоманду(КомандаЗапуска);

	Лог.Информация("Работа завершена.");

КонецПроцедуры

Инициализация();
ЗапускВКоманднойСтроке();
